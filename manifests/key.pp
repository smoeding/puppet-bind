# @summary Manage keys
#
# @example Using the defined type
#
#   bind::key { 'rndc-key':
#     secret  => 'secret',
#     keyfile => '/etc/bind/rndc.key',
#   }
#
# @param key
#   The name of the key.
#
# @param algorithm
#   The algorithm to use for the encoding of the secret key. Can be one of:
#   `hmac-md5`, `hmac-sha1`, `hmac-sha224`, `hmac-sha256`, `hmac-sha384`,
#   `hmac-sha512`. The default is `hmac-sha256`.
#
# @param owner
#   The file owner for the key file.
#
# @param group
#   The file group for the key file.
#
# @param mode
#   The file mode for the key file.
#
# @param manage_keyfile
#   Should the key file be managed by this defined type. Set this to `false`
#   if you need to manage the key file from your own Puppet code. The code to
#   include the key file in the daemon configuration is still generated when
#   this parameter is false.
#
# @param manage_content
#   Should the content of the key file be managed by this defined type. Set
#   this to `false` if you want to manage file permissions but do not want to
#   manage the content of the file. This is useful for the key file used by
#   the `rndc` utility. Normally a secret key for `rndc` is created during
#   installation. Updating this key with Puppet creates a problem since the
#   service can't be restarted cleanly after the file has been changed when
#   the daemon still uses the old secret. So the key for the `rndc` tool is
#   best left alone. The code to include the key file in the daemon
#   configuration is still generated when this parameter is false.
#
# @param keyfile
#   Set this parameter to a file name if you need to reference the key from
#   other tools (like 'rndc'). In this case the file with the key will be
#   saved in the named file. Otherwise a a system selected file will be used.
#
# @param base64_secret
#   A base64 encoded secret to copy verbatim into the key. The parameters
#   secret and seed are ignored if this parameter is set.
#
# @param secret
#   The secret to use for the key. A random secret is created internally if
#   this parameter is not set.
#
# @param seed
#   An optional seed to use if the random secret is created internally.
#
#
define bind::key (
  String                         $key            = $name,
  Bind::Key::Algorithm           $algorithm      = 'hmac-sha256',
  String                         $owner          = 'root',
  String                         $group          = $::bind::bind_group,
  Stdlib::Filemode               $mode           = '0640',
  Boolean                        $manage_keyfile = true,
  Boolean                        $manage_content = true,
  Optional[Stdlib::Absolutepath] $keyfile        = undef,
  Optional[String]               $base64_secret  = undef,
  Optional[String]               $secret         = undef,
  Optional[String]               $seed           = undef,
) {

  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  # Use default filename if unset
  $_keyfile = pick($keyfile, "${::bind::confdir}/keys/${key}.key")

  if $manage_keyfile {
    if $manage_content {
      if $base64_secret {
        $hash = $base64_secret
      }
      elsif $secret {
        $hash = base64('encode', $secret, 'strict')
      }
      else {
        $bits = $algorithm ? {
          'hmac-md5'    => 128,
          'hmac-sha1'   => 160,
          'hmac-sha224' => 224,
          'hmac-sha256' => 256,
          'hmac-sha384' => 384,
          'hmac-sha512' => 512,
        }

        $rand = fqdn_rand_string($bits / 8, '', pick($seed, $key))
        $hash = base64('encode', $rand, 'strict')
      }

      $params =  {
        'key'       => $key,
        'algorithm' => $algorithm,
        'hash'      => $hash,
      }

      file { $_keyfile:
        ensure  => file,
        owner   => $owner,
        group   => $group,
        mode    => $mode,
        content => epp('bind/key.epp', $params),
        before  => Concat::Fragment["bind::key::${title}"],
        notify  => Service['bind'],
      }
    }
    else {
      file { $_keyfile:
        ensure => file,
        owner  => $owner,
        group  => $group,
        mode   => $mode,
        before => Concat::Fragment["bind::key::${title}"],
      }
    }
  }

  # Add include statement for $keyfile to config
  concat::fragment { "bind::key::${title}":
    target  => 'named.conf.keys',
    content => "include \"${_keyfile}\";",
    order   => '10',
  }
}
