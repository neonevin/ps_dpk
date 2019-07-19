# ***************************************************************
# UQ - Nevin Prasannan - 15/01/2019
# V 1.0 - This for managing configuration.properties for webservers ONLY
# ***************************************************************
define my_cfg_man::my_psigw_prop (
  $ensure          = present,
  $igw_settings  = undef,
  $cfg_home_path        = undef,
  $domain_name     = undef,
  $tools_install_user = undef,
  $tools_install_group = undef,
  $cfg_log_file    = undef,
) {
    $cfg_file   = "${cfg_home_path}/webserv/${domain_name}/applications/peoplesoft/PSIGW.war/WEB-INF/integrationGateway.properties"

    $defaults = {
      'path'    => $cfg_file,
      'section' => '',
    }

    # create_ini_settings($igw_settings,  $defaults)


      if $igw_settings { #if non-empty
        $igw_settings.each | $setting, $val | {
          if ($setting =~ /(?i)pwd$/) or ($setting =~ /(?i)password$/) or ($setting =~ /(?i)Passwd$/){
            if $facts['os']['family'] == 'windows' {
              $enc_strin_cmd="${cfg_home_path}/webserv/${domain_name}/piabin/PSCipher.sh ${val}"
              $enc_cmd = "for /f \"tokens 3\" %a in ('${enc_strin_cmd}') do echo %a"
            }
            else {
              $enc_cmd="${cfg_home_path}/webserv/${domain_name}/piabin/PSCipher.sh ${val}|awk \'{print \$3}\'"
            }
            if(!defined(Ini_Settings_Encrypt["${domain_name} PSIGW ${setting}"])){
              @ini_settings_encrypt{"${domain_name} PSIGW ${setting}" :
                ensure            => present,
                path              => $cfg_file,
                setting           => $setting,
                show_diff         => false,
                value             => $enc_cmd,
                key_val_separator => '=',
                # value     => "${cfg_home_path}/webserv/${domain_name}/piabin/PSCipher.sh ${val}|awk \'{print \$3}\'",
              }
            }
            realize(Ini_Settings_Encrypt["${domain_name} PSIGW ${setting}"])
          }
          else{
            if (!defined(INI_SETTING["${domain_name} PSIGW ${setting}"])){
              @ini_setting { "${domain_name} PSIGW ${setting}" :
                ensure            => present,
                path              => $cfg_file,
                # section           => '',
                setting           => $setting,
                value             => $val,
                key_val_separator => '=',
              }
            }
            realize(INI_SETTING["${domain_name} PSIGW ${setting}"])
          }
        }
      }
      if $::kernel =='Linux' {
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
