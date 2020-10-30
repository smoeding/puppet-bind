# dnssec_key.rb --- Provider for dnssec_key type

Puppet::Type.type(:dnssec_key).provide(:dnssec_key) do
  desc '.'

  commands dnssec_keygen: 'dnssec-keygen'

  def initialize(value = {})
    super(value)
    @keys = []
    @now = Time.now
    @refkey = nil
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

    keydir = resource[:key_directory]

    valid_now = false
    valid_later = false

    Dir.foreach(keydir) do |file|
      activate = nil
      inactive = nil
      now = Time.now

      match = file.match(%r{^K(#{resource[:zone]})\.\+(\d+)\+(\d+)\.key$})
      if match
        zone, algorithm, keytag = match.captures

        base = "K#{zone}.+#{algorithm}+#{keytag}"

        prv = private_key(base)
        key = public_key(base)

        next unless File.file?(key)

        Puppet.debug("dnssec_key: checking key file #{key}")

        File.readlines(key).each do |line|
          match = line.match(%r{Inactive: (\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)})
          if match
            year, mon, day, hour, min, sec = match.captures
            inactive = Time.utc(year, mon, day, hour, min, sec)
            next
          end

          match = line.match(%r{Activate: (\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)})
          if match
            year, mon, day, hour, min, sec = match.captures
            activate = Time.utc(year, mon, day, hour, min, sec)
            next
          end

          match = line.match(%r{^#{zone}\.\s+IN\s+DNSKEY\s+(\d+)\s+(\d+)\s+(\d+)\s+})
          next if match.nil?

          flags, protocol, algorithm_id = match.captures
          inactive ||= Time.at(2_147_483_648)

          # Test flag bit if this is a key signing key
          ksk = (flags.to_i & 1).odd?

          # Skip entry if properties do not match
          next if ksk ^ (resource[:ksk].to_s == 'true')
          next if algorithm(algorithm_id) != resource[:algorithm]

          Puppet.info("dnssec_key: found key file #{key} for zone #{zone}")
          Puppet.info("dnssec_key: key valid from #{activate} to #{inactive}")

          # Key is no longer active, so we ignore it
          next if inactive < now

          Puppet.info("dnssec_key: candidate #{key} for zone #{zone}")

          valid_now = true if activate <= now && now <= inactive
          valid_later = true if now + resource[:publish].to_i <= inactive

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
      refkey = @keys.sort_by { |key| key[:inactive] }.last
      @refkey = refkey[:base]
      Puppet.info("dnssec_key: using reference key #{@refkey} for zone #{zone}")
    end

    valid_now && valid_later
  end

  def create
    Puppet.debug("dnssec_key: calling create for #{resource[:name]}")

    args = ['-q']

    args << '-3' if resource[:nsec3].to_s == 'true'
    args << '-a' << resource[:algorithm].to_s
    args << '-K' << resource[:key_directory]
    args << '-b' << resource[:bits] if resource[:bits]

    unless @keys.empty?
      args << '-P' << resource[:publish] if resource[:publish]
      args << '-A' << resource[:activate] if resource[:activate]
    end

    # args << '-R' << resource[:revoke] if resource[:revoke]
    # args << '-I' << resource[:retire] if resource[:retire]
    # args << '-D' << resource[:delete] if resource[:delete]
    args << '-f' << 'KSK' if resource[:ksk].to_s == 'true'
    args << '-n' << 'ZONE'
    args << resource[:zone]

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
