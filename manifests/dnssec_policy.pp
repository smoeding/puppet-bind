# @summary Define a key and signing policy for zones
#
# @example Create a DNSSEC policy
#
#   bind::dnssec_policy { 'foo':
#     nsec3_enable => true,
#   }
#
# @param policy
#   The name of the policy.
#
# @param nsec3_enable
#   Should NSEC3 be used instead of NSEC.
#
# @param nsec3param_iterations
#   The number of iterations for NSEC3.
#
# @param nsec3param_optout
#   Set optout for NSEC3.
#
# @param nsec3param_salt_length
#   The length of the salt for NSEC3. Named creates a salt of the provided
#   length.
#
# @param dnskey_ttl
#   The TTL for DNSKEY resource records in ISO8601 format.
#
# @param purge_keys
#   The time in ISO8601 format after which keys will be purged from the
#   configuraton after they have been deleted.
#
# @param publish_safety
#   A safety margin in ISO8601 format that is added to the pre-publication
#   interval when rollover times are calculated.
#
# @param retire_safety
#   A safety margin in ISO8601 format that is added to the post-publication
#   interval when rollover times are calculated.
#
# @param signatures_refresh
#   The time in ISO8601 format after which RRSIG records are refreshed.
#
# @param signatures_validity
#   The time in ISO8601 format that an RRSIG record is valid.
#
# @param signatures_validity_dnskey
#   The time in ISO8601 format that an DNSKEY record is valid.
#
# @param max_zone_ttl
#   The maximum TTL in ISO8601 format allowed for the zone.
#
# @param zone_propagation_delay
#   The expected propagation delay in ISO8601 format between updating a zone
#   and all secondary servers catching up with the change.
#
# @param parent_ds_ttl
#   The TTL of the DS RRSET of the parent zone in ISO8601 format .
#
# @param parent_propagation_delay
#   The expected propagation delay in ISO8601 format between a parent zone
#   update and all secondary servers catching up with the change.
#
# @param csk_lifetime
#   The lifetime in ISO8601 format of a CSK key.
#
# @param csk_algorithm
#   The algorithm used to generate the CSK key.
#
# @param csk_keysize
#   The keysize used to generate the CSK key.
#
# @param ksk_lifetime
#   The lifetime in ISO8601 format of a KSK key.
#
# @param ksk_algorithm
#   The algorithm used to generate the KSK key.
#
# @param ksk_keysize
#   The keysize used to generate the KSK key.
#
# @param zsk_lifetime
#   The lifetime in ISO8601 format of a ZSK key.
#
# @param zsk_algorithm
#   The algorithm used to generate the ZSK key.
#
# @param zsk_keysize
#   The keysize used to generate the ZSK key.
#
#
define bind::dnssec_policy (
  String                         $policy                     = $name,
  Boolean                        $nsec3_enable               = false,
  Optional[Integer]              $nsec3param_iterations      = undef,
  Optional[Boolean]              $nsec3param_optout          = undef,
  Optional[Integer]              $nsec3param_salt_length     = undef,
  Optional[Bind::Duration]       $dnskey_ttl                 = undef,
  Optional[Bind::Duration]       $purge_keys                 = undef,
  Optional[Bind::Duration]       $publish_safety             = undef,
  Optional[Bind::Duration]       $retire_safety              = undef,
  Optional[Bind::Duration]       $signatures_refresh         = undef,
  Optional[Bind::Duration]       $signatures_validity        = undef,
  Optional[Bind::Duration]       $signatures_validity_dnskey = undef,
  Optional[Bind::Duration]       $max_zone_ttl               = undef,
  Optional[Bind::Duration]       $zone_propagation_delay     = undef,
  Optional[Bind::Duration]       $parent_ds_ttl              = undef,
  Optional[Bind::Duration]       $parent_propagation_delay   = undef,
  Optional[Bind::Key::Lifetime]  $csk_lifetime               = undef,
  Optional[Bind::Key::Algorithm] $csk_algorithm              = undef,
  Optional[Integer]              $csk_keysize                = undef,
  Optional[Bind::Key::Lifetime]  $ksk_lifetime               = undef,
  Optional[Bind::Key::Algorithm] $ksk_algorithm              = undef,
  Optional[Integer]              $ksk_keysize                = undef,
  Optional[Bind::Key::Lifetime]  $zsk_lifetime               = undef,
  Optional[Bind::Key::Algorithm] $zsk_algorithm              = undef,
  Optional[Integer]              $zsk_keysize                = undef,
) {
  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  #
  # Keys
  #

  if ($csk_lifetime and $csk_algorithm) {
    $csk = $csk_keysize ? {
      undef   => "csk lifetime ${csk_lifetime} algorithm ${csk_algorithm}",
      default => "csk lifetime ${csk_lifetime} algorithm ${csk_algorithm} ${csk_keysize}",
    }
  }
  else {
    $csk = undef
  }

  if ($ksk_lifetime and $ksk_algorithm) {
    $ksk = $ksk_keysize ? {
      undef   => "ksk lifetime ${ksk_lifetime} algorithm ${ksk_algorithm}",
      default => "ksk lifetime ${ksk_lifetime} algorithm ${ksk_algorithm} ${ksk_keysize}",
    }
  }
  else {
    $ksk = undef
  }

  if ($zsk_lifetime and $zsk_algorithm) {
    $zsk = $zsk_keysize ? {
      undef   => "zsk lifetime ${zsk_lifetime} algorithm ${zsk_algorithm}",
      default => "zsk lifetime ${zsk_lifetime} algorithm ${zsk_algorithm} ${zsk_keysize}",
    }
  }
  else {
    $zsk = undef
  }

  $keys = [ $csk, $ksk, $zsk ].filter |$val| { $val =~ NotUndef }

  #
  # NSEC3
  #

  $optout = $nsec3param_optout ? {
    undef   => undef,
    default => bool2str($nsec3param_optout, 'yes', 'no'),
  }

  $nsec3param_hash = {
    ' iterations'  => $nsec3param_iterations,
    ' optout'      => $optout,
    ' salt-length' => $nsec3param_salt_length,
  }

  $nsec3param_values = $nsec3param_hash.filter |$key, $val| { $val =~ NotUndef }

  $nsec3param = empty($nsec3param_values) ? {
    true    => '',
    default => join(join_keys_to_values($nsec3param_values, ' ')),
  }

  #
  #
  #

  $params = {
    'policy'                     => $policy,
    'nsec3_enable'               => $nsec3_enable,
    'nsec3param'                 => $nsec3param,
    'dnskey_ttl'                 => $dnskey_ttl,
    'purge_keys'                 => $purge_keys,
    'publish_safety'             => $publish_safety,
    'retire_safety'              => $retire_safety,
    'signatures_refresh'         => $signatures_refresh,
    'signatures_validity'        => $signatures_validity,
    'signatures_validity_dnskey' => $signatures_validity_dnskey,
    'max_zone_ttl'               => $max_zone_ttl,
    'zone_propagation_delay'     => $zone_propagation_delay,
    'parent_ds_ttl'              => $parent_ds_ttl,
    'parent_propagation_delay'   => $parent_propagation_delay,
    'keys'                       => $keys,
  }

  concat::fragment { "named.conf.policies-${policy}":
    target  => 'named.conf.policies',
    content => epp("${module_name}/policy.epp", $params),
  }
}
