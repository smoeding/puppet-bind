# @summary Manage an inet control channel
#
# @example Using the defined type
#
#   bind::controls::inet { '*':
#     keys => [ 'rndc.key', ],
#   }
#
# @param allow
#   The client addresses that are allowed to access this control channel.
#
# @param keys
#   The name of the keys that will be used to authenticate access to this
#   control channel.
#
# @param read_only
#   Should the control channel only allow read-only access.
#
# @param address
#   The IPv4 or IPv6 address where the control channel will be created. This
#   can also be the string `*` for all local IPv4 addresses or the string `::`
#   for all local IPv6 addresses.
#
# @param port
#   The port where the control channel will be listening. The default port 953
#   will be ised if this is unset.
#
#
define bind::controls::inet (
  Bind::AddressMatchList $allow     = [],
  Array[String]          $keys      = [],
  Boolean                $read_only = false,
  String                 $address   = $name,
  Optional[Stdlib::Port] $port      = undef,
) {

  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  # Ignore control channel definition unless control_channels_enable is true
  if $::bind::control_channels_enable {

    $_allow = empty($allow) ? {
      true    => undef,
      default => $allow.reduce('') |$memo,$k| { "${memo}${k}; " },
    }

    $_keys = empty($keys) ? {
      true    => undef,
      default => $keys.reduce('') |$memo,$k| { "${memo}\"${k}\"; " },
    }

    $params = {
      'allow'     => $_allow,
      'keys'      => $_keys,
      'read_only' => $read_only,
      'address'   => $address,
      'port'      => $port,
    }

    $content = epp("${module_name}/controls-inet.epp", $params)

    concat::fragment { "named.conf.controls-inet-${title}":
      target  => 'named.conf.options',
      order   => '92',
      content => "${content};",
    }

    # Include controls fragments from main config
    Concat::Fragment <| tag == 'named.conf.controls' |> { }
  }
}
