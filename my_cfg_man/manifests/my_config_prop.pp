# ***************************************************************
# UQ - Nevin Prasannan - 15/01/2019
# V 1.0 - This for managing configuration.properties for webservers ONLY
# ***************************************************************
define my_cfg_man::my_config_prop (
  $ensure          = present,
  $site_list  = undef,
  $cfg_home_path        = undef,
  $domain_name     = undef,
  $tools_install_user = undef,
  $tools_install_group = undef,
  $cfg_log_file    = undef,
) {
    $site_list.each | $site_name, $site_info | {
      # if $facts['os']['family'] != 'windows' {
      #   $cfg_file = "${cfg_path}/${file_name}.sh"
      # }
      # else {
      #   $cfg_file = "${cfg_path}\\${file_name}.bat"
      # }
      $cfg_file  = "${cfg_home_path}/webserv/${domain_name}/applications/peoplesoft/PORTAL.war/WEB-INF/psftdocs/${site_name}/configuration.properties"
      $webprof_settings=$site_info['webprofile_settings']
      $config_properties=$site_info['config_properties']
      if $webprof_settings { #if non-empty
        $webprof_settings.each | $setting, $val | {
          case $setting { #NP Oracle delivered hiera keys are not named same as the  properties in config.prop file
            'profile_name' : { $prop_name='WebProfile' }
            'profile_user': { #$prop_name=undef}
            $prop_name='WebUserId' }
            'profile_user_pwd' : {
              # $prop_name=undef }
              $prop_name='WebPassword'
            }
            default:{ $prop_name=undef }
          }

          if $prop_name{
            if ($prop_name =~ /(?i)pwd$/) or ($prop_name =~ /(?i)password$/) or ($prop_name =~ /(?i)userid$/){
              if $facts['os']['family'] == 'windows' {
                $enc_strin_cmd="${cfg_home_path}/webserv/${domain_name}/piabin/PSCipher.sh ${val}"
                $enc_cmd = "${cfg_home_path}/env_cfg.sh && for /f \"tokens 3\" %a in ('${enc_strin_cmd}') do echo %a"
              }
              else {
                $enc_cmd="${cfg_home_path}/webserv/${domain_name}/piabin/PSCipher.sh ${val}|awk \'{print \$3}\'"
              }
              if(!defined(Ini_Settings_Encrypt["${domain_name} ${site_name} ${setting}"])){
                @ini_settings_encrypt{"${domain_name} ${site_name} ${setting}" :
                  ensure    => present,
                  path      => $cfg_file,
                  setting   => $prop_name,
                  show_diff => false,
                  value     => $enc_cmd,
                  # value     => "${cfg_home_path}/webserv/${domain_name}/piabin/PSCipher.sh ${val}|awk \'{print \$3}\'",
                  }
              }
              realize(Ini_Settings_Encrypt["${domain_name} ${site_name} ${setting}"])
            }
            else {
              if (!defined(INI_SETTING["${domain_name} ${site_name} ${setting}"])){
                @ini_setting { "${domain_name} ${site_name} ${setting}" :
                  ensure  => present,
                  path    => $cfg_file,
                  # section => '',
                  setting => $prop_name,
                  value   => $val,
                }
              }
              realize(INI_SETTING["${domain_name} ${site_name} ${setting}"])
            }
          }
        }
      }
      if $config_properties { #if non-empty
        $config_properties.each | $setting, $val | {
          if ($setting =~ /(?i)pwd$/) or ($setting =~ /(?i)password$/) or ($setting =~ /(?i)userid$/){
              if $facts['os']['family'] == 'windows' {
                $enc_strin_cmd="${cfg_home_path}/webserv/${domain_name}/piabin/PSCipher.sh ${val}"
                $enc_cmd = "${cfg_home_path}/env_cfg.sh && for /f \"tokens 3\" %a in ('${enc_strin_cmd}') do echo %a"
              }
              else {
                $enc_cmd="${cfg_home_path}/webserv/${domain_name}/piabin/PSCipher.sh ${val}|awk \'{print \$3}\'"
              }
              if(!defined(Ini_Settings_Encrypt["${domain_name} ${site_name} ${setting}"])){
                @ini_settings_encrypt{"${domain_name} ${site_name} ${setting}" :
                  ensure    => present,
                  path      => $cfg_file,
                  setting   => $setting,
                  show_diff => false,
                  value     => $enc_cmd,
                  # value     => "${cfg_home_path}/webserv/${domain_name}/piabin/PSCipher.sh ${val}|awk \'{print \$3}\'",
                  }
              }
              realize(Ini_Settings_Encrypt["${domain_name} ${site_name} ${setting}"])
            }
            else{
              if (!defined(INI_SETTING["${domain_name} ${site_name} ${setting}"])){
                @ini_setting { "${domain_name} ${site_name} ${setting}" :
                  ensure  => present,
                  path    => $cfg_file,
                  # section => '',
                  setting => $setting,
                  value   => $val,
                }
              }
              realize(INI_SETTING["${domain_name} ${site_name} ${setting}"])
            }
        }
      }
      if $::kernel == 'Linux'{
          # $sed_cmd="sed -i -e \'s/\\r\$//\' ${psigwprop_file_path}"
          $sed_cmd="sed -i -e \'s/\\r//g\' ${cfg_file}" #managing CR LF
        if (!defined(EXEC["sed_${cfg_file}"])){
          @exec { "sed_${cfg_file}" :
            command => $sed_cmd,
            onlyif  => "test \$(grep -c \$\'\\r\' ${cfg_file}) -gt 0",
            path    => '/usr/bin/',
          }
        }
        realize (EXEC["sed_${cfg_file}"])
      }
  }
}
