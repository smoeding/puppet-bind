# @summary Manage configuration files
#
# @api private
#
# @example Install the named.conf config file
#
#   bind::config { 'named.conf':
#     source => "puppet:///modules/local/named.conf",
#   }
#
# @param ensure
#   The state of the resource. Must be either `present` or `absent`.
#
# @param file
#   The name of the configuration file. This must be only the basename of the
#   file and not an absolute pathname. Default is the name of the resource.
#
# @param owner
#   The file owner for the config file.
#
# @param group
#   The file group for the key file. Default is the value of the class
#   parameter `bind::bind_group`.
#
# @param mode
#   The file mode for the key file.
#
# @param source
#   The file source for the configuration file. Either the parameter `source`
#   or `content` should be set to actually manage any file content. See the
#   Puppet standard `file` type.
#
# @param content
#   The file content for the configuration file. Either the parameter
#   `source` or `content` should be set to actually manage any file content.
#   See the Puppet standard `file` type.
#
#
define bind::config (
  Enum['present','absent'] $ensure  = 'present',
  String                   $file    = $name,
  String                   $owner   = 'root',
  String                   $group   = $::bind::bind_group,
  Stdlib::Filemode         $mode    = '0640',
  Optional[String]         $source  = undef,
  Optional[String]         $content = undef,
) {

  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  $_ensure = $ensure ? {
    'present' => 'file',
    default   => 'absent',
  }

  file { "${::bind::confdir}/${file}":
    ensure  => $_ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    source  => $source,
    content => $content,
    notify  => Service['bind'],
  }
}
