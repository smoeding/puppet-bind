# @summary Manage a hint zone
#
# @example Using the defined type
#
#   bind::zone::hint { '.':
#     file => '/etc/bind/db.root',
#   }
#
# @param file
#   The filename of the hint file.
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
define bind::zone::hint (
  String            $file,
  Optional[String]  $view    = undef,
  Optional[String]  $comment = undef,
  String            $zone    = $name,
  Bind::Zone::Class $class   = 'IN',
  String            $order   = '10',
) {
  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  $params = {
    'zone'    => $zone,
    'file'    => $file,
    'class'   => $class,
    'comment' => $comment,
    'indent'  => bool2str($bind::views_enable, '  ', ''),
  }

  if $bind::views_enable {
    assert_type(String, $view) |$expected,$actual| {
      fail('The parameter view must be a String if views are enabled')
    }

    @concat::fragment { "named.conf.views-${view}-50-${zone}":
      target  => 'named.conf.views',
      content => epp("${module_name}/zone-hint.epp", $params),
      order   => $order,
      tag     => ["named.conf.views-${view}",],
    }
  }
  else {
    concat::fragment { "named.conf.zones-${zone}":
      target  => 'named.conf.zones',
      content => epp("${module_name}/zone-hint.epp", $params),
      order   => $order,
    }
  }
}
