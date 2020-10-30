# @summary Manage listen-on-v6 option clause
#
# @example Listen on the IPv6 loopback interface
#
#   listen_on_v6 { '::1': }
#
# @example Listen on a non-default port
#
#   listen_on_v6 { '::1':
#     port => 8053,
#   }
#
# @param address
#   A single string or an array of strings to define the port and IP
#   address(es) on which the daemon will listen for queries. The string `any`
#   may be used to listen on all available interfaces and addresses. The
#   string `none` may be used to disable IPv6.
#
# @param port
#   The port number on which the daemon will listen. Port 53 will be used if
#   this is not defined.
#
#
define bind::listen_on_v6 (
  Variant[String,Array[String,1]] $address = $name,
  Optional[Stdlib::Port]          $port    = undef,
) {
  $_resource = $port ? {
    undef => 'listen-on-v6',
    default => "listen-on-v6 port ${port}"
  }

  $_order = $port ? {
    undef   => '13',
    default => '14',
  }


  bind::aml { $_resource:
    address_match_list => $address,
    target             => 'named.conf.options',
    order              => $_order,
  }
}
