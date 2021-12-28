# @summary Manage a forward zone
#
# @example Using the defined type
#
#   bind::zone::forward { 'example.com':
#     forwarders => [ '192.168.1.1', '192.168.1.2', ],
#     forward    => 'only',
#   }
#
# @param forwarders
#   An array of strings that define the forwarding servers for this zone.
#   All queries for the zone will be forwarded to these servers.
#
# @param forward
#   Only forward queries (value `only`) or try to resolve if forwarders do
#   not answer the query (value `first`).
#
# @param view
#   The name of the view that should include this zone. Must be set if views
#   are used.
#
# @param comment
#   A comment to add to the zone file.
#
# @param zone
#   The name of the zone.
#
# @param class
#   The zone class.
#
# @param order
#   Zones are ordered by this parameter value in the zone file.
#
#
define bind::zone::forward (
  Array[String]           $forwarders = [],
  Optional[Bind::Forward] $forward    = undef,
  Optional[String]        $view       = undef,
  Optional[String]        $comment    = undef,
  String                  $zone       = $name,
  Bind::Zone::Class       $class      = 'IN',
  String                  $order      = '40',
) {

  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  $params = {
    'zone'       => $zone,
    'forwarders' => $forwarders,
    'forward'    => $forward,
    'class'      => $class,
    'comment'    => $comment,
    'indent'     => bool2str($::bind::views_enable, '  ', ''),
  }

  if $::bind::views_enable {
    assert_type(String, $view) |$expected,$actual| {
      fail('The parameter view must be a String if views are enabled')
    }

    @concat::fragment { "named.conf.views-${view}-60-${zone}":
      target  => 'named.conf.views',
      content => epp("${module_name}/zone-forward.epp", $params),
      order   => $order,
      tag     => [ "named.conf.views-${view}", ],
    }
  }
  else {
    concat::fragment { "named.conf.zones-${zone}":
      target  => 'named.conf.zones',
      content => epp("${module_name}/zone-forward.epp", $params),
      order   => $order,
    }
  }
}
