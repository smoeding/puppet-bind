# @summary Manage a unix control channel
#
# @example Using the defined type
#
#   bind::controls::unix { '/run/named.ctl':
#     owner => 0,
#     group => 0,
#     perm  => '0640',
#     keys  => [ 'rndc.key', ],
#   }
#
# @param owner
#   The owner of the unix control channel socket. This must be the integer
#   value of the owner's user id.
#
# @param group
#   The group of the unix control channel socket. This must be the integer
#   value of the owner's group id.
#
# @param perm
#  The file permisssions of the unix control channel socket.
#
# @param keys
#   The name of the keys that will be used to authenticate access to this
#   control channel.
#
# @param read_only
#   Should the control channel only allow read-only access.
#
# @param path
#   The file path of the unix control socket to create.
#
#
define bind::controls::unix (
  Integer              $owner,
  Integer              $group,
  Stdlib::Filemode     $perm,
  Array[String]        $keys      = [],
  Boolean              $read_only = false,
  Stdlib::AbsolutePath $path      = $name,
) {
  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  # Ignore control channel definition unless control_channels_enable is true
  if $bind::control_channels_enable {
    $_keys = empty($keys) ? {
      true    => undef,
      default => $keys.reduce('') |$memo,$k| { "${memo}\"${k}\"; " },
    }

    $params = {
      'owner'     => $owner,
      'group'     => $group,
      'perm'      => $perm,
      'keys'      => $_keys,
      'read_only' => $read_only,
      'path'      => $path,
    }

    $content = epp("${module_name}/controls-unix.epp", $params)

    concat::fragment { "named.conf.controls-unix-${title}":
      target  => 'named.conf.options',
      order   => '91',
      content => "${content};",
    }

    # Include controls fragments from main config
    Concat::Fragment <| tag == 'named.conf.controls' |> {}
  }
}
