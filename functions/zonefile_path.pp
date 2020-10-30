# zonefile_path.pp --- Generate zonefile name from zone
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
