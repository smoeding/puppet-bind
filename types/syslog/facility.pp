# Type to match allowed values for the syslog facility
type Bind::Syslog::Facility = Enum['auth','authpriv','cron','daemon','ftp','kern',
  'local0','local1','local2','local3','local4','local5','local6','local7',
  'lpr','mail','news','syslog','user','uucp',
]
