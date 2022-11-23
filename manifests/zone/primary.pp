# @summary Manage a primary zone
#
# The parameters `source` or `content` can be used to have Puppet manage the
# content of the zone file. No content is managed if both parameters are left
# undefined. This is useful if the zone has dynamic updates enabled in which
# case `named` will need to rewrite the zone file.
#
# @example Create a primary zone
#
#   bind::zone::primary { 'example.com':
#     source => 'puppet:///modules/profile/example.com.zone',
#   }
#
# @example Use DNSSEC signing for a primary zone using a DNSSEC policy
#
#   bind::zone::primary { 'example.com':
#     dnssec_enable  => true,
#     dnssec_policy  => 'standard',
#     inline_signing => true,
#     source         => 'puppet:///modules/profile/example.com.zone',
#   }
#
# @param also_notify
#   Secondary servers that should be notified in addition to the
#   nameservers that are listed in the zone file.
#
# @param update_policy
#   Enable dynamic updates for the zone and define the update policy. This
#   can either be the string `local` or an array of strings. Using the string
#   `local` enables an automatically created session key `local-ddns` stored
#   on the server. Otherwise the array should contain individual `grant` or
#   `deny` rules.
#
#   The zone file can not be managed by Puppet (the parameters source or
#   content are not allowed) for a dynamic zone.
#
# @param dnssec_enable
#   Enable DNSSEC for the zone. This parameter is ignored for Bind 9.16.0 or
#   later.
#
# @param dnssec_dnskey_kskonly
#   Should only key-signing keys be used to to sign the DNSKEY, CDNSKEY and
#   CDSRRsets.
#
# @param dnssec_secure_to_insecure
#   Should the zone be allowed to got from signed to unsinged.
#
# @param inline_signing
#   Enable inline signing for the zone.
#
# @param dnssec_policy
#   The name of the DNSSEC policy to use for this zone. The policy must be
#   created using the `bind::dnssec_policy` defined type.
#
# @param dnskey_sig_validity
#   The number of days after which the signatures for generated DNSKEY RRsets
#   expire.
#
# @param dnssec_loadkeys_interval
#   The time interval after which key are checked if `auto_dnssec` is set to
#   `maintain`. The value is in minutes.
#
# @param dnssec_update_mode
#   Should RRSIG records be regenerated automatically (mode `maintain`) or
#   not (mode `no-resign`) for a zone which allows dynamic updates.
#
# @param auto_dnssec
#   How to sign and resign the DNSSEC zone. Can be one of `allow`, `maintain`
#   or `off`.
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
# @param file
#   The name of the user managed zone file on the DNS server. The file must
#   exist and have the correct format. Puppet does not manage the content or
#   the file permissions of this file.
#
# @param source
#   The source for the zone file. See the standard Puppet file type.
#
# @param content
#   The content for the zone file. See the standard Puppet file type.
#
# @param zone_statistics
#   Collect statistics for this zone.
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
define bind::zone::primary (
  Array[String]                        $also_notify               = [],
  Variant[Enum['local'],Array[String]] $update_policy             = [],
  Optional[Boolean]                    $dnssec_enable             = undef,
  Optional[Boolean]                    $dnssec_dnskey_kskonly     = undef,
  Optional[Boolean]                    $dnssec_secure_to_insecure = undef,
  Optional[Boolean]                    $inline_signing            = undef,
  Optional[String]                     $dnssec_policy             = undef,
  Optional[Integer]                    $dnskey_sig_validity       = undef,
  Optional[Integer]                    $dnssec_loadkeys_interval  = undef,
  Optional[Bind::DNSSEC::Updatemode]   $dnssec_update_mode        = undef,
  Optional[Bind::Auto_dnssec]          $auto_dnssec               = undef,
  Optional[Bind::Notify_secondaries]   $notify_secondaries        = undef,
  Optional[String]                     $view                      = undef,
  Optional[String]                     $file                      = undef,
  Optional[String]                     $source                    = undef,
  Optional[String]                     $content                   = undef,
  Optional[Boolean]                    $zone_statistics           = undef,
  Optional[String]                     $comment                   = undef,
  String                               $zone                      = $name,
  Bind::Zone::Class                    $class                     = 'IN',
  String                               $order                     = '20',
) {
  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  $zonebase = "${bind::vardir}/primary"

  if ($source and !empty($update_policy)) {
    fail('The parameter source may not be used for a dynamic zone (update_policy is set)')
  }

  if ($content and !empty($update_policy)) {
    fail('The parameter content may not be used for a dynamic zone (update_policy is set)')
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
          owner  => $bind::bind_user,
          group  => $bind::bind_group,
          mode   => '0750',
          before => Concat['named.conf.zones'],
        }
      }
    }

    $zonedir2 = dirname($zonedir1)
    unless defined(File[$zonedir2]) {
      file { $zonedir2:
        ensure => directory,
        owner  => $bind::bind_user,
        group  => $bind::bind_group,
        mode   => '0750',
        before => Concat['named.conf.zones'],
      }
    }

    file { $zonefile:
      ensure       => file,
      owner        => $bind::bind_user,
      group        => $bind::bind_group,
      mode         => '0644',
      source       => $source,
      content      => $content,
      validate_cmd => "${bind::checkzone_program} -k fail -m fail -M fail -n fail ${zone} %",
      require      => Concat['named.conf.zones'],
    }

    # Do not trigger a zone reload for a dynamic updatable zone
    if ($update_policy =~ Array and empty($update_policy)) {
      if $bind::views_enable {
        exec { "bind::reload::${view}::${zone}":
          command     => "${bind::rndc_program} reload ${zone} ${class} ${view}",
          user        => 'root',
          cwd         => '/',
          refreshonly => true,
          subscribe   => File[$zonefile],
          require     => Service['bind'],
        }
      }
      else {
        exec { "bind::reload::${zone}":
          command     => "${bind::rndc_program} reload ${zone} ${class}",
          user        => 'root',
          cwd         => '/',
          refreshonly => true,
          subscribe   => File[$zonefile],
          require     => Service['bind'],
        }
      }
    }
  }

  $version = ('named_version' in $facts) ? {
    true    => $facts['named_version'],
    default => '4.9.3',
  }

  $_dnssec_enable = (versioncmp($version, '9.16.0') < 0) ? {
    true    => $dnssec_enable,
    default => undef,
  }

  $_keydir = (($inline_signing == true) or ($dnssec_policy =~ NotUndef)) ? {
    true    => "${bind::confdir}/keys",
    default => undef,
  }

  $params = {
    'zone'                => $zone,
    'file'                => $zonefile,
    'dnssec_enable'       => $_dnssec_enable,
    'inline_signing'      => $inline_signing,
    'also_notify'         => $also_notify,
    'auto_dnssec'         => $auto_dnssec,
    'policy'              => $dnssec_policy,
    'loadkeys_interval'   => $dnssec_loadkeys_interval,
    'kskonly'             => $dnssec_dnskey_kskonly,
    'secure_to_insecure'  => $dnssec_secure_to_insecure,
    'update_mode'         => $dnssec_update_mode,
    'dnskey_sig_validity' => $dnskey_sig_validity,
    'notify'              => $notify_secondaries,
    'key_directory'       => $_keydir,
    'statistics'          => $zone_statistics,
    'update_policy'       => $update_policy,
    'class'               => $class,
    'comment'             => $comment,
    'indent'              => bool2str($bind::views_enable, '  ', ''),
    'zone_in_view'        => ($view =~ NotUndef),
  }

  if $bind::views_enable {
    assert_type(String, $view) |$expected,$actual| {
      fail('The parameter view must be a String if views are enabled')
    }

    @concat::fragment { "named.conf.views-${view}-50-${zone}":
      target  => 'named.conf.views',
      order   => $order,
      content => epp("${module_name}/zone-primary.epp", $params),
      tag     => ["named.conf.views-${view}",],
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
