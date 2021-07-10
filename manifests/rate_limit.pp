# @summary Manage rate limiting
#
# @example Establish a limit
#
#   class { 'bind::rate_limit':
#     all_per_second => 1000,
#   }
#
# @param window
#   The size of the rolling window measured in seconds over which the rate
#   limits are calculated.
#
# @param ipv4_prefix_length
#   Define the number of bits that are used to group IPv4 addresses (like a
#   netmask). The limits are applied to all requests having the same network
#   prefix.
#
# @param ipv6_prefix_length
#   Define the number of bits that are used to group IPv6 addresses (like a
#   netmask). The limits are applied to all requests having the same network
#   prefix.
#
# @param log_only
#   Do not really limit the queries but only log that it would happen. This
#   can be used to test limits before enforcing them.
#
# @param exempt_clients
#   An array of IP addresses/networks or ACL names that are never limited.
#
# @param all_per_second
#   Limit the number of total answers per second for an IP address to the
#   given value.
#
# @param errors_per_second
#   Limit the number of total error answers per second for an IP address to
#   the given value.
#
# @param responses_per_second
#   Limit the number of identical responses per second for an IP address to
#   the given value.
#
# @param referrals_per_second
#   Limit the number of referrals per second to the given value.
#
# @param nodata_per_second
#   Limit the number of NODATA responses per second to the given value.
#
# @param nxdomains_per_second
#   Limit the number of NXDOMAIN responses per second to the given value.
#
# @param qps_scale
#   Value to define the query per second scaling.
#
# @param slip
#   Set the rate at which queries over the defined limit are returned with
#   the truncate bit.
#
#
class bind::rate_limit (
  Integer[0,3600]           $window               = 0,
  Integer[0,32]             $ipv4_prefix_length   = 0,
  Integer[0,128]            $ipv6_prefix_length   = 0,
  Boolean                   $log_only             = false,
  Array[String]             $exempt_clients       = [],
  Optional[Integer[0,1000]] $all_per_second       = undef,
  Optional[Integer[0,1000]] $errors_per_second    = undef,
  Optional[Integer[0,1000]] $responses_per_second = undef,
  Optional[Integer[0,1000]] $referrals_per_second = undef,
  Optional[Integer[0,1000]] $nodata_per_second    = undef,
  Optional[Integer[0,1000]] $nxdomains_per_second = undef,
  Optional[Integer[0,1000]] $qps_scale            = undef,
  Optional[Integer[0,10]]   $slip                 = undef,
) {

  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  $limits = {
    'all_per_second'       => $all_per_second,
    'errors_per_second'    => $errors_per_second,
    'responses_per_second' => $responses_per_second,
    'referrals_per_second' => $referrals_per_second,
    'nodata_per_second'    => $nodata_per_second,
    'nxdomains_per_second' => $nxdomains_per_second,
    'qps_scale'            => $qps_scale,
    'slip'                 => $slip,
  }

  # Include rate limit config only if at least one parameter has been set
  $real_limits = $limits.filter |$key, $val| { $val =~ NotUndef }

  unless empty($real_limits) {
    $params = {
      'window'             => $window,
      'ipv4_prefix_length' => $ipv4_prefix_length,
      'ipv6_prefix_length' => $ipv6_prefix_length,
      'log_only'           => $log_only,
      'exempt_clients'     => $exempt_clients,
    }

    concat::fragment { 'named.conf.rate-limit':
      target  => 'named.conf.options',
      order   => '80',
      content => epp("${module_name}/rate-limit.epp", merge($params, $limits)),
    }
  }
}
