# ***************************************************************
# UQ pupppet profile for setting up config log file
# UQ - Nevin Prasannan - 25/01/2019
# V 1.0 - This for config logs ONLY
# ***************************************************************
class my_cfg_profiles::my_cfg_notify{
  notify { 'my_cfg_profiles::my_cfg_notify': }
  $cfg_hiera = hiera('cfg_notify')
  if $cfg_hiera {
    $log_path=$cfg_hiera[logpath]
    if $log_path == undef{
      fail ('No log path defined for config manager')
    }
    else
    {
      $log_file=$log_path
    }

    $timestamp = Timestamp().strftime('%Y%m%d%H%M%S%Z')
    file_line { "${log_file} end":
      ensure  => present,
      line    => "\nEnd of logging for host:${facts['fqdn']} - ${timestamp}",
      path    => $log_file,
      require => FILE[$log_file],
    }
    #NP  - email - notification - Begin
    $notify=$cfg_hiera[notify]
    if $notify {

      $email_to=$cfg_hiera[email_to]
      if $email_to == undef{
        fail ('No email recepient defined for config manager')
      }

      $email_from=$cfg_hiera[email_from]
      if $email_from == undef{
        fail ('No email sender defined for config manager')
      }
      # notify{"debug line : test \" grep -q 'changed to' ${log_file} && test \$?\"" :}
      exec { 'Notify user':
        command  => "cat ${log_file} | mailx -s 'Config updated | host - ${facts['fqdn']}' -r ${email_from}  ${email_to} && echo nofitied ${email_to} >>/tmp/cfg_email.log",
        onlyif   => "test \$(grep -c changed ${log_file}) -gt 0",
        path     => '/bin:/usr/bin',
        provider =>'shell',
      }
      #NP  - email - notification - Ends
    }

  }
  else {
    # notice('No notification settings defined')
    notify {'No notification settings defined': }
  }
}
