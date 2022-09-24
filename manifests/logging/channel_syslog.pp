# @summary Manage logging channel to syslog
#
# @example Define a syslog channel for Bind9
#
#   bind::logging::channel_syslog { 'syslog':
#     facility => 'local0',
#     severity => 'info',
#   }
#
# @param channel
#   The name of the channel. Use bind::logging::category to route a given
#   category to this channel.
#
# @param facility
#   The syslog facility to use. Valid value: `auth`, `authpriv`, `cron`,
#   `daemon`, `ftp`, `kern`, `local0`, `local1`, `local2`, `local3`,
#   `local4`, `local5`, `local6`, `local7`, `lpr`, `mail`, `news`, `syslog`,
#   `user`, `uucp`.
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
#
define bind::logging::channel_syslog (
  String                 $channel        = $name,
  Bind::Syslog::Facility $facility       = 'daemon',
  Bind::Syslog::Severity $severity       = 'notice',
  Optional[Boolean]      $print_category = undef,
  Optional[Boolean]      $print_severity = undef,
  Optional[Boolean]      $print_time     = undef,
) {
  # The base class must be included first
  unless defined(Class['bind']) {
    fail('You must include the bind base class before using any bind defined resources')
  }

  $params = {
    'channel'        => $channel,
    'facility'       => $facility,
    'severity'       => $severity,
    'print_category' => $print_category,
    'print_severity' => $print_severity,
    'print_time'     => $print_time,
  }

  concat::fragment { "named.conf-channel-${title}":
    target  => 'named.conf.logging',
    order   => "20-${channel}",
    content => epp('bind/logging-channel-syslog.epp', $params),
  }
}
