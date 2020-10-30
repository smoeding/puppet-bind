# @summary Manage statistics channel
#
# @example Create a statistics channel for localhost access
#
#   bind::statistics_channel { '127.0.0.1':
#     port  => 8053,
#     allow => [ '127.0.0.1', ],
#   }
#
# @param port
#   The port number to listen on. If no port is specified , port 80 is used.
#
# @param allow
#   An array of IP addresses that are allowed to query the statistics. If
#   this parameter is not set, all remote addresses are permitted to use the
#   statitiscs channel.
#
# @param ip
#   The IP address to listen on. This can be an IPv4 address or an IPv6
#   address if IPv6 is in use. An address of `*` is interpreted as the IPv4
#   wildcard address.
#
#
define bind::statistics_channel (
  Optional[Stdlib::Port] $port  = undef,
  Array[String]          $allow = [],
  String                 $ip    = $name,
) {

  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  $params = {
    'ip'    => $ip,
    'port'  => $port,
    'allow' => $allow,
  }

  concat::fragment { "named.conf.statistics-${title}":
    target  => 'named.conf.options',
    order   => '90',
    content => epp("${module_name}/statistics.epp", $params),
  }
}
