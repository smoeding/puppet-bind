# @summary Manage a view
#
# @example Create a view for a guest network
#
#   bind::view { 'guest':
#     match_clients   => [ 'guest' ],
#     allow_recursion => [ 'any' ],
#   }
#
# @param match_clients
#   An array of ACL names or networks that this view will be used for.
#
# @param match_destinations
#   An array of ACL names or networks. The view is used if the query
#   destination matches this list.
#
# @param allow_query
#   An array of ACL names or networks that are allowed to query the view.
#
# @param allow_query_on
#   An array of interfaces on the DNS server from which queries are accepted.
#
# @param recursion
#   Should recursion be enabled for this view.
#
# @param match_recursive_only
#   Should this view be used for recursive queried only.
#
# @param allow_recursion
#   An array of ACL names or networks for which recursive queries are
#   allowed.
#
# @param allow_recursion_on
#   An array of interfaces on the DNS server from which recursive queries are
#   accepted.
#
# @param allow_query_cache
#   An array of ACL names or networks for which access to the cache is
#   allowed.
#
# @param allow_query_cache_on
#   An array of interfaces on the DNS server from which access to the cache
#   is allowed.
#
# @param allow_transfer
#   An array of ACL names or networks that are allowed to transfer zone
#   information from this server.
#
# @param root_hints_enable
#   Should a local copy of the list of servers that are authoritative for the
#   root domain "." be included. This is normally not needed since Bind
#   contains an internal list of root nameservers and `named` will query the
#   servers in the list until an authoritative response is received. Normally
#   this parameter can be left at default.
#
# @param root_mirror_enable
#   Should a mirror for the root domain "." be installed locally. See RFC
#   7706 for details.
#
# @param localhost_forward_enable
#   Should the forward zone for localhost be enabled in this view.
#
# @param localhost_reverse_enable
#  Should the reverse zone for localhost be enabled in this view.
#
# @param view
#   The name of the view.
#
# @param order
#   The order in which different views are configured. The first matching
#   view is used to answer the query for a client. If you use one view where
#   match_clients contains `any` then this view should probably have the
#   highest order value.
#
# @param response_policies
#   An array of response policy zones.
#
#
define bind::view (
  Array[String]     $match_clients            = ['any',],
  Array[String]     $match_destinations       = [],
  Array[String]     $allow_query              = ['any',],
  Array[String]     $allow_query_on           = [],
  Boolean           $recursion                = true,
  Boolean           $match_recursive_only     = false,
  Array[String]     $allow_recursion          = [],
  Array[String]     $allow_recursion_on       = [],
  Array[String]     $allow_query_cache        = [],
  Array[String]     $allow_query_cache_on     = [],
  Array[String]     $allow_transfer           = [],
  Boolean           $root_hints_enable        = false,
  Boolean           $root_mirror_enable       = false,
  String            $view                     = $name,
  String            $order                    = '10',
  Array[String]     $response_policies        = [],
  Optional[Boolean] $localhost_forward_enable = undef,
  Optional[Boolean] $localhost_reverse_enable = undef,
) {
  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  unless $bind::views_enable {
    fail('Views can only be used if views_enable is true in the main bind class')
  }

  $params = {
    'view'                 => $view,
    'confdir'              => $bind::confdir,
    'match_clients'        => $match_clients,
    'match_destinations'   => $match_destinations,
    'match_recursive_only' => $match_recursive_only,
    'allow_query'          => $allow_query,
    'allow_query_on'       => $allow_query_on,
    'recursion'            => bool2str($recursion, 'yes', 'no'),
    'allow_recursion'      => $allow_recursion,
    'allow_recursion_on'   => $allow_recursion_on,
    'allow_query_cache'    => $allow_query_cache,
    'allow_query_cache_on' => $allow_query_cache_on,
    'allow_transfer'       => $allow_transfer,
    'response_policies'    => $response_policies,
  }

  concat::fragment { "named.conf.views-${view}-00":
    target  => 'named.conf.views',
    content => epp("${module_name}/view.epp", $params),
    order   => $order,
  }

  if $root_hints_enable {
    bind::zone::hint { "${view}/.":
      zone    => '.',
      view    => $view,
      file    => "${bind::confdir}/db.root",
      comment => 'Prime server with knowledge of the root servers',
    }
  }

  if $root_mirror_enable {
    bind::zone::mirror { "${view}/.":
      zone    => '.',
      view    => $view,
      comment => 'Local copy of the root zone (see RFC 7706)',
      order   => '11',
    }
  }

  if pick($localhost_forward_enable, $bind::localhost_forward_enable) {
    bind::zone::primary { "${view}/localhost":
      zone  => 'localhost',
      view  => $view,
      file  => "${bind::confdir}/db.localhost",
      order => '15',
    }
  }

  if pick($localhost_reverse_enable, $bind::localhost_reverse_enable) {
    bind::zone::primary { "${view}/127.in-addr.arpa":
      zone  => '127.in-addr.arpa',
      view  => $view,
      file  => "${bind::confdir}/db.127",
      order => '15',
    }
  }

  # Collect all zones for this view
  Concat::Fragment <| tag == "named.conf.views-${view}" |> {
    order => $order,
  }

  concat::fragment { "named.conf.views-${view}-99":
    target  => 'named.conf.views',
    content => '};',
    order   => $order,
  }
}
