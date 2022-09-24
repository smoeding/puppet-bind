# @summary Manage logging category
#
# @example Use a single channel
#
#   bind::logging::category { 'default':
#     channels => 'syslog',
#   }
#
# @example Use multiple channels
#
#   bind::logging::category { 'default':
#     channels => [ 'syslog', 'file', ],
#   }
#
# @param channels
#   A string or an array of strings to define the channels to use for this
#   category.
#
# @param category
#   The logging category.
#
# @param order
#   A string to use for ordering different categories in the configuration
#   file.
#
#
define bind::logging::category (
  Variant[String,Array[String]] $channels,
  String                        $category = $name,
  String                        $order    = '50',
) {
  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  # Ensure final ';' and convert to string if parameter is an array
  $chans = $channels ? {
    Array   => join(suffix($channels, ';'), ' '),
    default => "${channels};",
  }

  concat::fragment { "bind-logging-category-${category}":
    target  => 'named.conf.logging',
    order   => "60-${order}-${category}",
    content => "  category ${category} { ${chans} };",
  }
}
