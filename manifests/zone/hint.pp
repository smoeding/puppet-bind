# @summary Manage a hint zone
#
# @example Using the defined type
#
#   bind::zone::hint { '.':
#     file => '/etc/bind/db.root',
#   }
#
# @param zone
#   The name of the zone.
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
    'indent'  => bool2str($::bind::views_enable, '  ', ''),
  }

  if $::bind::views_enable {
    assert_type(String, $view) |$expected,$actual| {
      fail('The parameter view must be a String if views are enabled')
    }

    @concat::fragment { "named.conf.views-${view}-50-${zone}":
      target  => 'named.conf.views',
      content => epp("${module_name}/zone-hint.epp", $params),
      order   => $order,
      tag     => [ "named.conf.views-${view}", ],
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
