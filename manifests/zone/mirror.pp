# @summary Manage a mirror zone
#
# @example Using the defined type
#
#   bind::zone::mirror { '.':
#   }
#
# @param zone
#   The name of the zone.
#
#
define bind::zone::mirror (
  Optional[String]  $view    = undef,
  Optional[String]  $comment = undef,
  String            $zone    = $name,
  Bind::Zone::Class $class   = 'IN',
  String            $order   = '50',
) {

  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  if ('named_version' in $facts and versioncmp($facts['named_version'], '9.14.0') >= 0) {
    $params = {
      'zone'    => $zone,
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
        content => epp("${module_name}/zone-mirror.epp", $params),
        order   => $order,
        tag     => [ "named.conf.views-${view}", ],
      }
    }
    else {
      concat::fragment { "named.conf.zones-${zone}":
        target  => 'named.conf.zones',
        content => epp("${module_name}/zone-mirror.epp", $params),
        order   => $order,
      }
    }
  }
}
