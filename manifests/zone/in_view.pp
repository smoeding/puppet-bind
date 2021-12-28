# @summary Manage a in-view zone reference
#
# @example Using the defined type
#
#   bind::zone::in_view { 'example.com':
#     view    => 'internal',
#     in_view => 'external',
#   }
#
# @param in_view
#   The name of the view where the referenced view is defined.
#
# @param view
#   The name of the view that should include this zone.
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
define bind::zone::in_view (
  String            $in_view,
  String            $view,
  Optional[String]  $comment = undef,
  String            $zone    = $name,
  Bind::Zone::Class $class   = 'IN',
  String            $order   = '60',
) {

  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  unless $::bind::views_enable {
    fail('The parameter views_enable must be true in the main class.')
  }

  $params = {
    'zone'    => $zone,
    'in_view' => $in_view,
    'class'   => $class,
    'comment' => $comment,
    'indent'  => bool2str($::bind::views_enable, '  ', ''),
  }

  @concat::fragment { "named.conf.views-${view}-50-${zone}":
    target  => 'named.conf.views',
    content => epp("${module_name}/zone-in_view.epp", $params),
    tag     => [ "named.conf.views-${view}", ],
    order   => $order,
  }
}
