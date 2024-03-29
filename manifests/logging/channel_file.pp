# @summary Manage logging channel to a logfile
#
# @example Define a logfile channel for Bind9
#
#   bind::logging::channel_file { 'security':
#     logfile => '/var/lob/bind/security',
#   }
#
# @param logfile
#   The filename where the logs are written to.
#
# @param mode
#   The file mode of the logfile. The default allows access only for the user
#   and group runnung the daemon.
#
# @param channel
#   The name of the channel for the logfile. Use bind::logging::category to
#   route a given category to this channel.
#
# @param severity
#   The severity of log messages that are written to the file. Valid values:
#   `critical`, `error`, `warning`, `notice`, `info`, `debug`, `dynamic`.
#
# @param print_category
#   Should the category of the message be logged to the file.
#
# @param print_severity
#   Should the severity of the message be logged to the file.
#
# @param print_time
#   Should a timestamp be logged to the file.
#
# @param size
#   The maximum size of the logfile. Log rotation takes place if this size is
#   reached. If the size is undefined then the logfile will not be rotated.
#
# @param versions
#   The number of logfiles to keep if log rotation is used.
#
#
define bind::logging::channel_file (
  Stdlib::Absolutepath   $logfile,
  Stdlib::Filemode       $mode           = '0640',
  String                 $channel        = $name,
  Bind::Syslog::Severity $severity       = 'notice',
  Boolean                $print_category = true,
  Boolean                $print_severity = true,
  Boolean                $print_time     = true,
  Optional[String]       $size           = undef,
  Optional[Integer]      $versions       = undef,
) {
  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  file { $logfile:
    ensure => file,
    owner  => $bind::bind_user,
    group  => $bind::bind_group,
    mode   => $mode,
    before => Concat['named.conf.logging'],
  }

  $params = {
    'channel'        => $channel,
    'logfile'        => $logfile,
    'severity'       => $severity,
    'size'           => $size,
    'versions'       => $versions,
    'print_category' => $print_category,
    'print_severity' => $print_severity,
    'print_time'     => $print_time,
  }

  concat::fragment { "named.conf-channel-${title}":
    target  => 'named.conf.logging',
    order   => "30-${channel}",
    content => epp("${module_name}/logging-channel-file.epp", $params),
  }
}
