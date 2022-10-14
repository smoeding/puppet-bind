# dnssec_key.rb --- The dnssec_key type

Puppet::Type.newtype(:dnssec_key) do
  desc <<-EOT
    @summary Create, delete and maintain DNSSEC key files on the DNS server

    *Notice*: Automatic key rollover using this type is not thoroughly
    tested. Use `bind::dnssec_policy` to define a DNSSEC policy (available
    with Bind 9.16) and let Bind handle the heavy lifting instead of Puppet.

    All intervals are interpreted as seconds if no unit is given. The
    following interval units can be used: `y` (year), `mo` (months), `w`
    (weeks), `d` (days), `h` (hours), `mi` (minutes).

    Examples for valid intervals: `1y`, `12mo`, `1w`, `7d`, `24h`, `720mi`

    The following diagram illustrates the lifecycle of the keys:

    ```
    key-1 ---- active ----------><-- retired --><-- deleted --

    key-2     <--- published ---><---------- active ----------><-- retired

              <----------------->
                prepublication
                   interval
    ```

    Key-2 is published with a prepublication interval while key-1 is still
    active. The activation time of key-2 matches the deactivation time of
    key-1. Key-1 changes state to retired when it is deactivated and is
    deleted eventually. The cycle continues with additional keys.

    @example Create a Key Signing Key using defaults
      dnssec_key { 'example.com':
        key_directory => '/etc/bind/keys',
        ksk           => true,
      }

    @example Create a Zone Signing Key using a specified algorithm and key size
      dnssec_key { 'ZSK/example.com':
        zone          => 'example.com',
        key_directory => '/etc/bind/keys',
        algorithm     => 'RSASHA256',
        bits          => 2048,
      }

    @example Create Zone Signing Keys using automatic key rollover
      dnssec_key { 'ZSK/example.com':
        zone          => 'example.com',
        key_directory => '/etc/bind/keys',
        publish       => '2w',
        active        => '1y',
        retire        => '4w',
        delete        => '1w',
        successor     => true,
      }
  EOT

  def munge_duration(value)
    return nil if value.nil?

    match = value.match(%r{^([0-9]+)(y|mo|w|d|h|mi)?$})

    if match.nil?
      raise(Puppet::Error, "Conversion of duration failed: #{value}")
    end

    time, unit = match.captures
    case unit
    when 'y'
      time.to_i * 365 * 24 * 60 * 60
    when 'mo'
      time.to_i * 30 * 24 * 60 * 60
    when 'w'
      time.to_i * 7 * 24 * 60 * 60
    when 'd'
      time.to_i * 24 * 60 * 60
    when 'h'
      time.to_i * 60 * 60
    when 'mi'
      time.to_i * 60
    else
      time.to_i
    end
  end

  ensurable do
    desc 'Specifies whether the destination file should exist. Setting this to
      "absent" tells Puppet to delete the destination file if it exists, and
      negates the effect of any other parameters.'

    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc 'The name of the resource.'
  end

  newparam(:zone) do
    desc 'The zone for which the key should be generated. This must be a valid
      domain name. Defaults to the resource title if unset.'

    newvalues(%r{^[a-zA-Z][a-zA-Z0-9.-]+\.[a-zA-Z]+$})

    defaultto { @resource[:name] }
  end

  newparam(:key_directory) do
    desc 'The directory where the key should be created. This parameter is
      mandatory.'
  end

  newparam(:algorithm) do
    desc 'The cryptographic algorithm that the key should use.'

    newvalues(:DSA)
    newvalues(:ECCGOST)
    newvalues(:ECDSAP256SHA256)
    newvalues(:ECDSAP384SHA384)
    newvalues(:ED25519)
    newvalues(:ED448)
    newvalues(:NSEC3DSA)
    newvalues(:NSEC3RSASHA1)
    newvalues(:RSAMD5)
    newvalues(:RSASHA1)
    newvalues(:RSASHA256)
    newvalues(:RSASHA512)

    defaultto :RSASHA1
  end

  newparam(:nsec3, boolean: true) do
    desc 'Whether the key should be NSEC3-capable.'

    newvalues(:true, :false)

    defaultto :false
  end

  newparam(:bits) do
    desc "The number of bits in the key. The possible range depends on the
      selected algorithm:

      RSA  : 512 .. 2048
      DH   : 128 .. 4096
      DSA  : 512 .. 1024 and an exact multiple of 64
      HMAC :   1 ..  512

      Elliptic curve algorithms don't need this parameter."

    newvalues(%r{^[0-9]+$})

    defaultto do
      case @resource[:algorithm]
      when :NSEC3RSASHA1, :RSAMD5, :RSASHA1, :RSASHA256, :RSASHA512
        2048
      when :DSA, :NSEC3DSA
        1024
      else
        nil
      end
    end
  end

  newparam(:rrtype) do
    desc 'The resource record type to use for the key.'

    newvalues(:DNSKEY)
    newvalues(:KEY)

    defaultto :DNSKEY
  end

  newparam(:ksk, boolean: true) do
    desc 'Whether the key should be a Key Signing Key.'

    newvalues(:true, :false)

    defaultto :false
  end

  newparam(:successor, boolean: true) do
    desc 'Whether the key should be created as an explicit successor to an
      existing key. In this case the name, algorithm, size and type of the key
      will be take from the existing key. The activation date will match the
      inactivation date of the existing key.'

    newvalues(:true, :false)

    defaultto :false
  end

  newparam(:purge, boolean: true) do
    desc 'Whether old keys should be purged after they are retired.'

    newvalues(:true, :false)

    defaultto :false
  end

  newparam(:precreate) do
    desc 'The time interval before prepublication in which the key will be
      created. The interval must be long enough to ensure Puppet will run
      during this interval.'

    newvalues(%r{^[0-9]+(y|mo|w|d|h|mi)?$})
    munge { |value| @resource.munge_duration(value) }
  end

  newparam(:prepublish) do
    desc 'The time interval before activation when the key will be published.'

    newvalues(%r{^[0-9]+(y|mo|w|d|h|mi)?$})
    munge { |value| @resource.munge_duration(value) }
  end

  newparam(:active) do
    desc 'The time interval that the key will be used for signing the zone.'

    newvalues(%r{^[0-9]+(y|mo|w|d|h|mi)?$})
    munge { |value| @resource.munge_duration(value) }
  end

  newparam(:revoke) do
    desc 'The time interval that the key will have the revoke bit set. This
      parameter may only be used for zone-signing keys.'

    newvalues(%r{^[0-9]+(y|mo|w|d|h|mi)?$})
    munge { |value| @resource.munge_duration(value) }
  end

  newparam(:retire) do
    desc 'The time interval that the key is still published after it became
      inactive.'

    newvalues(%r{^[0-9]+(y|mo|w|d|h|mi)?$})
    munge { |value| @resource.munge_duration(value) }
  end

  validate do
    if self[:key_directory].nil?
      raise(Puppet::Error, 'key_directory is a required attribute')
    end

    if self[:revoke] && (self[:ksk].to_s != 'true')
      raise(Puppet::Error, 'revoke is only supported if ksk => true')
    end

    if self[:precreate] && self[:prepublish] && (self[:precreate] < self[:prepublish])
      raise(Puppet::Error, 'precreate interval must be longer than the prepublish interval')
    end
  end

  autorequire(:file) do
    [@parameters[:key_directory].value]
  end
end
