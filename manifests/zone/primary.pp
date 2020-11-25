# @summary Manage a primary zone
#
# @example Create a primary zone
#
#   bind::zone::primary { 'example.com':
#     source => 'puppet:///modules/profile/example.com.zone',
#   }
#
# @example Use DNSSEC inline signing for a primary zone
#
#   bind::zone::primary { 'example.com':
#     inline_signing => true,
#     auto_dnssec    => 'maintain',
#     source         => 'puppet:///modules/profile/example.com.zone',
#   }
#
# @param dnssec
#   Enable DNSSEC for the zone.
#
# @param inline_signing
#   Enable inline signing for the zone.
#
# @param auto_dnssec
#   How to sign and resign the DNSSEC zone. Can be one of `allow`, `maintain`
#   or `off`.
#
# @param also_notify
#   Secondary servers that should be notified in addition to the
#   nameservers that are listed in the zone file.
#
# @param notify_secondaries
#   Should NOTIFY messages be sent out to the name servers defined in the NS
#   records for the zone. The messages are sent to all name servers except
#   itself and the primary name server defined in the SOA record and to any
#   IPs listed in any also-notify statement. Can be either `yes`, `no` or
#   `explicit`.
#
# @param view
#   The name of the view that should include this zone. Must be set if views
#   are used.
#
# @param source
#   The source for the zone file. See the standard Puppet file type.
#
# @param content
#   The content for the zone file. See the standart Puppet file type.
#
# @param zone_statistics
#   Collect statistics for this zone.
#
# @param zone
#   The name of the zone.
#
#
define bind::zone::primary (
  Boolean                            $dnssec             = false,
  Boolean                            $inline_signing     = false,
  Bind::Auto_dnssec                  $auto_dnssec        = 'off',
  Array[String]                      $also_notify        = [],
  Optional[Bind::Notify_secondaries] $notify_secondaries = undef,
  Optional[String]                   $view               = undef,
  Optional[String]                   $file               = undef,
  Optional[String]                   $source             = undef,
  Optional[String]                   $content            = undef,
  Optional[Boolean]                  $zone_statistics    = undef,
  Optional[String]                   $comment            = undef,
  String                             $zone               = $name,
  Bind::Zone::Class                  $class              = 'IN',
  String                             $order              = '20',
) {
  $zonebase = "${::bind::vardir}/primary"

  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  unless ($file =~ NotUndef) or ($source =~ NotUndef) or ($content =~ NotUndef) {
    fail('One of the parameters "file", "source" or "content" must be defined')
  }

  if $file {
    $zonefile = $file
  }
  else {
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

    file { $zonefile:
      ensure       => file,
      owner        => $::bind::bind_user,
      group        => $::bind::bind_group,
      mode         => '0640',
      source       => $source,
      content      => $content,
      validate_cmd => "/usr/sbin/named-checkzone -k fail -m fail -M fail -n fail ${zone} %",
      require      => Concat['named.conf.zones'],
    }

    if $::bind::views_enable {
      exec { "bind::reload::${view}::${zone}":
        command     => "${::bind::rndc_program} reload ${zone} ${class} ${view}",
        user        => 'root',
        cwd         => '/',
        refreshonly => true,
        subscribe   => File[$zonefile],
        require     => Service['bind'],
      }
    }
    else {
      exec { "bind::reload::${zone}":
        command     => "${::bind::rndc_program} reload ${zone} ${class}",
        user        => 'root',
        cwd         => '/',
        refreshonly => true,
        subscribe   => File[$zonefile],
        require     => Service['bind'],
      }
    }
  }

  $params = {
    'zone'           => $zone,
    'file'           => $zonefile,
    'also_notify'    => $also_notify,
    'notify'         => $notify_secondaries,
    'dnssec'         => $dnssec,
    'auto_dnssec'    => $auto_dnssec,
    'inline_signing' => $inline_signing,
    'key_directory'  => "${::bind::confdir}/keys",
    'statistics'     => $zone_statistics,
    'class'          => $class,
    'comment'        => $comment,
    'indent'         => bool2str($::bind::views_enable, '  ', ''),
    'zone_in_view'   => ($view =~ NotUndef),
  }

  if $::bind::views_enable {
    assert_type(String, $view) |$expected,$actual| {
      fail('The parameter view must be a String if views are enabled')
    }

    @concat::fragment { "named.conf.views-${view}-50-${zone}":
      target  => 'named.conf.views',
      order   => $order,
      content => epp("${module_name}/zone-primary.epp", $params),
      tag     => [ "named.conf.views-${view}", ],
    }
  }
  else {
    concat::fragment { "named.conf.zones-${zone}":
      target  => 'named.conf.zones',
      order   => $order,
      content => epp("${module_name}/zone-primary.epp", $params),
    }
  }
}
