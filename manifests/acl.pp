# @summary Manage ACL entries
#
# @example Create an ACL for an internal network
#
#   bind::acl { 'internal':
#     address_match_list => [ '10.0.0.0/8', ],
#     comment            => 'internal network',
#   }
#
# @param address_match_list
#   An array of IP addresses/networks, which can be referenced in other Bind
#   configuration clauses to limit access to a component. The array parameter
#   must have at least one entry.
#
# @param comment
#   An optional string that is used as comment in the generated ACL file.
#
# @param order
#   The sorting order of the ACLs in the configuration file.
#
# @param acl
#   The name of the ACL. Defaults to the name of the resource.
#
#
define bind::acl (
  Array[String,1]  $address_match_list,
  Optional[String] $comment            = undef,
  String           $order              = '10',
  String           $acl                = $name,
) {

  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  $params = {
    'address_match_list' => $address_match_list,
    'comment'            => $comment,
    'acl'                => $name,
  }

  concat::fragment { "named.conf.acl.${title}":
    target  => 'named.conf.acls',
    content => epp("${module_name}/acl.epp", $params),
    order   => $order,
  }
}
