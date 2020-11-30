# dnssec_key.rb --- Provider for dnssec_key type

Puppet::Type.type(:dnssec_key).provide(:dnssec_key) do
  desc 'Caution: This functionality is in beta and is subject to change. The
    design and code is less mature than other features.'

  commands dnssec_keygen: 'dnssec-keygen'

  def initialize(value = {})
    super(value)

    @now = Time.now

    @keys = []
    @refkey = nil
  end

  def get_key(valid_at)
    @keys.each do |key|
      return key if key[:activate] <= valid_at && valid_at < key[:inactive]
    end
    nil
  end

  def algorithm(num)
    case num.to_i
    when 1
      :RSAMD5
    when 2
      :DH
    when 5
      :RSASHA1
    when 3
      :DSA
    when 6
      :NSEC3DSA
    when 7
      :NSEC3RSASHA1
    when 8
      :RSASHA256
    when 10
      :RSASHA512
    when 12
      :ECCGOST
    when 13
      :ECDSAP256SHA256
    when 14
      :ECDSAP384SHA384
    when 157
      :HMAC_MD5
    when 161
      :HMAC_SHA1
    when 162
      :HMAC_SHA224
    when 163
      :HMAC_SHA256
    when 164
      :HMAC_SHA384
    when 165
      :HMAC_SHA512
    else
      nil
    end
  end

  def private_key(base)
    File.absolute_path("#{base}.private", resource[:key_directory])
  end

  def public_key(base)
    File.absolute_path("#{base}.key", resource[:key_directory])
  end

  def zone
    resource[:zone]
  end

  def exists?
    Puppet.debug("dnssec_key: calling exists? for #{resource[:name]}")

    valid_now = false
    valid_later = false
    keydir = resource[:key_directory]

    Dir.foreach(keydir) do |file|
      activate = nil
      inactive = Time.at(2_147_483_648)
      delete = Time.at(2_147_483_648)

      match = file.match(%r{^K(#{resource[:zone]})\.\+(\d+)\+(\d+)\.key$})
      if match
        zone, algorithm, keytag = match.captures

        base = "K#{zone}.+#{algorithm}+#{keytag}"

        prv = private_key(base)
        key = public_key(base)

        next unless File.file?(key)

        Puppet.debug("dnssec_key: checking key file #{key}")

        File.readlines(key).each do |line|
          match = line.match(%r{Activate: (\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)})
          if match
            year, mon, day, hour, min, sec = match.captures
            activate = Time.utc(year, mon, day, hour, min, sec)
            next
          end

          match = line.match(%r{Inactive: (\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)})
          if match
            year, mon, day, hour, min, sec = match.captures
            inactive = Time.utc(year, mon, day, hour, min, sec)
            next
          end

          match = line.match(%r{Delete: (\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)})

          if match
            year, mon, day, hour, min, sec = match.captures
            delete = Time.utc(year, mon, day, hour, min, sec)
            next
          end

          match = line.match(%r{^#{zone}\.\s+IN\s+DNSKEY\s+(\d+)\s+(\d+)\s+(\d+)\s+})
          next if match.nil?

          flags, protocol, algorithm_id = match.captures

          # Test flag bit if this is a key signing key
          ksk = (flags.to_i & 1).odd?
          typ = ksk ? 'KSK' : 'ZSK'

          # Skip entry if properties do not match
          next if ksk ^ (resource[:ksk].to_s == 'true')
          next if algorithm(algorithm_id) != resource[:algorithm]

          Puppet.info("dnssec_key: found #{typ} key #{key} for zone #{zone}")
          Puppet.info("dnssec_key: key is valid from #{activate} to #{inactive}")
          if delete < @now
            Puppet.debug("dnssec_key: removing #{key} for zone #{zone}")
            FileUtils.rm key, force: true unless key.nil?

            Puppet.debug("dnssec_key: removing #{prv} for zone #{zone}")
            FileUtils.rm prv, force: true unless prv.nil?
            next
          end

          # Key is no longer active, so we ignore it
          next if inactive < @now

          Puppet.info("dnssec_key: candidate #{key} for zone #{zone}")

          if activate <= @now && @now <= inactive
            valid_now = true
            Puppet.info("dnssec_key: candidate #{key} is valid now")
          end

          if @now + resource[:prepublish].to_i <= inactive
            valid_later = true
            Puppet.info("dnssec_key: candidate #{key} is valid later")
          end

          @keys << {
            base: base,
            zone: zone,
            prv: prv,
            key: key,
            ksk: ksk,
            protocol: protocol,
            algorithm: algorithm,
            activate: activate,
            inactive: inactive,
          }
        end
      end
    end

    unless @keys.empty?
      refkey = nil
      reftime = @now

      loop do
        key = get_key(reftime)

        # No key valid at reference time?
        break if key.nil?

        # Remember this key as reference key and continue looking for a key
        # that is valid when the current key becomes inactive. When the loop
        # terminates the reference key will be the last key that is usable for
        # a continuous validity interval.
        refkey = key
        reftime = key[:inactive]
      end

      if refkey
        @refkey = refkey[:base]
        Puppet.info("dnssec_key: using reference key #{@refkey} for zone #{zone}")
      else
        Puppet.info("dnssec_key: no reference key for zone #{zone}")
      end
    end

    valid_now && valid_later
  end

  def create
    Puppet.debug("dnssec_key: calling create for #{resource[:name]}")
    args = ['-q']

    args << '-K' << resource[:key_directory]

    if resource[:successor].to_s == 'true' && @refkey
      # Create explicit successor to an existing key
      args << '-S' << @refkey
    else
      # Create a new key
      args << '-a' << resource[:algorithm].to_s
      args << '-b' << resource[:bits] if resource[:bits]
      args << '-3' if resource[:nsec3].to_s == 'true'
      args << '-n' << 'ZONE'
    end

    args << '-f' << 'KSK' if resource[:ksk].to_s == 'true'

    if resource[:active]
      duration = resource[:active]

      if resource[:revoke]
        args << '-R' << "+#{duration}"
        duration += resource[:revoke]
      end

      if resource[:retire]
        args << '-I' << "+#{duration}"
        duration += resource[:retire]
      end

      args << '-D' << "+#{duration}"
    end

    if @refkey.nil?
      args << resource[:zone]
    elsif resource[:prepublish]
      args << '-i' << resource[:prepublish]
    end

    Puppet.debug("dnssec_key: running dnssec_keygen #{args.join(' ')}")
    base = dnssec_keygen(args)

    return unless base

    base.chomp!
    Puppet.debug("dnssec_key: created private/public key #{base}")
    FileUtils.chown('bind', 'bind', private_key(base))
    FileUtils.chown('bind', 'bind', public_key(base))
  end

  def destroy
    Puppet.debug("dnssec_key: calling destroy #{resource[:name]}")

    @keys.each do |item|
      # Skip entry if ksk property does not match
      next if item[:ksk] ^ (resource[:ksk].to_s == 'true')

      Puppet.debug("dnssec_key: removing #{item[:key]} for zone #{resource[:zone]}")
      FileUtils.rm item[:key], force: true

      Puppet.debug("dnssec_key: removing #{item[:prv]} for zone #{resource[:zone]}")
      FileUtils.rm item[:prv], force: true
    end
  end
end
