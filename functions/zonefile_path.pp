# zonefile_path.pp --- Generate zonefile name from zone
#
# @private
#
# @param zone [String] The name of the zone for which the path should be
#   returned.  Example: 'example.com'
#
# @return [String] The relative path and filename where the zonefile should be
#   stored.  Example: 'com/example/db.example.com'
#
function bind::zonefile_path(String $zone) >> String {
  $names = split($zone, '[.]')

  if (length($names) > 1) {
    $tld = $names[-1]
    $dom = $names[-2]

    $dir = "${tld}/${dom}"
    $part = $tld ? {
      'arpa'  => join(reverse($names[0, -3]), '.'),
      default => $zone,
    }
  }
  else {
    $dir = $zone
    $part = $zone
  }

  "${dir}/db.${part}"
}
