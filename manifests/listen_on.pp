# @summary Manage listen-on option clause
#
# @example Listen on the loopback interface
#
#   listen_on { '127.0.0.1': }
#
# @example Listen on two interfaces
#
#   listen_on { 'IPv4':
#     address => [ '10.0.0.1', '192.168.0.1' ],
#   }
#
# @example Listen on a non-default port
#
#   listen_on { '127.0.0.1':
#     port    => 8053,
#   }
#
# @param address
#   A single string or an array of strings to define the port and IP
#   address(es) on which the daemon will listen for queries. The string `any`
#   may be used to listen on all available interfaces and addresses. The
#   string `none` may be used to disable IPv4.
#
# @param port
#   The port number on which the daemon will listen. Port 53 will be used if
#   this is not defined.
#
#
define bind::listen_on (
  Bind::AddressMatchList $address = $name,
  Optional[Stdlib::Port] $port    = undef,
) {
  $_resource = $port ? {
    undef   => 'listen-on',
    default => "listen-on port ${port}"
  }

  $_order = $port ? {
    undef   => '11',
    default => '12',
  }

  bind::aml { $_resource:
    address_match_list => $address,
    target             => 'named.conf.options',
    order              => $_order,
  }
}
