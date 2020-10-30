# @summary Manage a secondary zone
#
# @example Create a secondary zone
#
#   bind::zone::secondary { 'example.com':
#     masters => [ '192.168.1.1', ],
#   }
#
# @param masters
#   An array of strings that define the master servers for this zone.
#   There must be at least one master server for a secondary zone.
#
# @param view
#   The name of the view that should include this zone. Must be set if views
#   are used.
#
# @param zone_statistics
#   Collect statistics for this zone.
#
# @param multi_master
#   If the zone has multiple primaries and the serial might be
#   different for the masters then named normally logs a message. Set
#   this to `true` to disable the message in this case.
#
# @param zone
#   The name of the zone.
#
#
define bind::zone::secondary (
  Array[String,1]   $masters,
  Optional[String]  $view            = undef,
  Optional[Boolean] $zone_statistics = undef,
  Optional[Boolean] $multi_master    = undef,
  Optional[String]  $comment         = undef,
  String            $zone            = $name,
  Bind::Zone::Class $class           = 'IN',
  String            $order           = '30',
) {
  $zonebase = "${::bind::vardir}/secondary"

  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  $zonepath = bind::zonefile_path($zone)
  $zonefile = "${zonebase}/${zonepath}"

  $zonedir1 = dirname($zonefile)
  if ($zonedir1 != $zonebase) {
    unless defined(File[$zonedir1]) {
      file { $zonedir1:
        ensure => directory,
        owner  => $::bind::bind_user,
        group  => $::bind::bind_group,
        mode   => '0750',
        before => Concat['named.conf.zones'],
      }
    }
  }

  $zonedir2 = dirname($zonedir1)
  unless defined(File[$zonedir2]) {
    file { $zonedir2:
      ensure => directory,
      owner  => $::bind::bind_user,
      group  => $::bind::bind_group,
      mode   => '0750',
      before => Concat['named.conf.zones'],
    }
  }

  $params = {
    'zone'         => $zone,
    'file'         => $zonefile,
    'masters'      => join($masters, '; '),
    'multi_master' => $multi_master,
    'statistics'   => $zone_statistics,
    'class'        => $class,
    'comment'      => $comment,
    'indent'       => bool2str($::bind::views_enable, '  ', ''),
  }

  if $::bind::views_enable {
    assert_type(String, $view) |$expected,$actual| {
      fail('The parameter view must be a String if views are enabled')
    }

    @concat::fragment { "named.conf.views-${view}-60-${zone}":
      target  => 'named.conf.views',
      content => epp("${module_name}/zone-secondary.epp", $params),
      order   => $order,
      tag     => [ "named.conf.views-${view}", ],
      notify  => Exec["bind::reload::${zone}"],
    }

    exec { "bind::reload::${zone}":
      command     => "${::bind::rndc_program} reload ${zone} ${class} ${view}",
      user        => 'root',
      cwd         => '/',
      refreshonly => true,
      require     => Service['bind'],
    }
  }
  else {
    concat::fragment { "named.conf.zones-${zone}":
      target  => 'named.conf.zones',
      content => epp("${module_name}/zone-secondary.epp", $params),
      order   => $order,
      notify  => Exec["bind::reload::${zone}"],
    }

    exec { "bind::reload::${zone}":
      command     => "${::bind::rndc_program} reload ${zone} ${class}",
      user        => 'root',
      cwd         => '/',
      refreshonly => true,
      require     => Service['bind'],
    }
  }
}
