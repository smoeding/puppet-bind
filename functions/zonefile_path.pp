# @summary Generate the zonefile name from zone
#
# @private
#
# @param zone [String]
#   The name of the zone for which the path should be returned.  Example:
#   'example.com'
#
# @param view Optional[String]
#   The name of the view for which the path should be returned.  Example:
#   'internal'
#
# @return [String]
#   The relative path and filename where the zonefile should be stored.
#   Example: 'com/example/db.example.com_internal'
#
function bind::zonefile_path(String $zone, Optional[String] $view = '') >> String {
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

  if ($view and length($view) > 0 ) {
    $viewpart = "_${view}"
  } else {
    $viewpart = ''
  }

  "${dir}/db.${part}${viewpart}"
}
