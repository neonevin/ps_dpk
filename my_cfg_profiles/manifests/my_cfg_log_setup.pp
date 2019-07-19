# ***************************************************************
# UQ pupppet profile for setting up config log file
# UQ - Nevin Prasannan - 25/01/2019
# V 1.0 - This for config logs ONLY
# ***************************************************************
class my_cfg_profiles::my_cfg_log_setup{
  notify { 'Applying my_cfg_profiles::my_cfg_log_setup': }
  $cfg_hiera = hiera('cfg_notify')
  if $cfg_hiera {
    $log_path=$cfg_hiera[logpath]
    if $log_path == undef{
      fail ('No log path defined for config manager')
    }
    else
    {
      # $log_file="${log_path}/ps_cfgman.log"
      $log_file=$log_path
    }
    if $facts['os']['family'] != 'windows' {
      # $log_file='/var/log/puppet/ps_cfgman.log'
      exec { 'filecheck':
        command =>"touch ${log_file}",
        path    => '/bin:/usr/bin',
      }
    }
    else { #NP  untested code
      # $log_file='c:/temp/ps_cfgman.log'
      exec { 'filecheck':
        command =>"if not exist ${log_file} fsutil file CreateNew ${log_file} 0",
        path    => 'c:/windows',
      }
    }

    $timestamp = Timestamp().strftime('%Y%m%d%H%M%S%Z')

    # exec{ 'move_log_file':
    #   command => 'mv'
    # }
    file { "${log_file}.${timestamp}":
      ensure => present,
      source => $log_file,
    }
    file{$log_file:
      ensure  => present,
      content => '',
      require => FILE["${log_file}.${timestamp}"],
    }

    file_line { $log_file:
      ensure  => present,
      line    => "Start logging for host:${facts['fqdn']} - ${timestamp}",
      path    => $log_file,
      require => FILE[$log_file],
    }
  }
  else {
    # notice('No notification settings defined')
    notify {'No notification settings defined': }
  }
}
