# ***************************************************************
# UQ - Nevin Prasannan - 15/01/2019
# based on io_psigwwar::igw_prop - psadmin.io
# https://github.com/psadmin-io/psadminio-io_psigwwar
# V 1.0 - This for managing configuration.properties for webservers ONLY
# ***************************************************************
define my_cfg_man::my_pskeystore (
  $ensure          = present,
  $keystore_pass  = undef,
  $cfg_home_path        = undef,
  $domain_name     = undef,
  $java_home   = undef,
  $tools_install_user = undef,
  $tools_install_group = undef,
  $cfg_log_file    = undef,
) {
    $pskey_location   = "${cfg_home_path}/webserv/${domain_name}/piaconfig/keystore/pskey"

    if(!defined(EXEC["Set pskey pwd ${cfg_home_path}/webserv/${domain_name}/piaconfig/keystore/pskey"]))
    {
      @exec { "Set pskey pwd ${cfg_home_path}/webserv/${domain_name}/piaconfig/keystore/pskey" :
        command => "keytool -keystore ${pskey_location} -storepass password -storepasswd -new ${keystore_pass}",
        unless  => "keytool -list -keystore ${pskey_location} -storepass ${keystore_pass}",
        path    => "${java_home}/jre/bin/",
      }
    }
    realize (EXEC["Set pskey pwd ${cfg_home_path}/webserv/${domain_name}/piaconfig/keystore/pskey"])

    if $facts['os']['family'] != 'windows'{
      # command for build pskey
      $buildkey_cmd="sh ${cfg_home_path}/webserv/${domain_name}/piabin/PSCipher.sh -buildkey"
      #gen envcypted pwd and check if it is Vx.1
      $testkey_cmd="test \$(sh ${cfg_home_path}/webserv/${domain_name}/piabin/PSCipher.sh ${keystore_pass} |awk \'{print \$3}\'|grep -c \'^{V..1}\') -gt 0"

      if(!defined(EXEC["build key ${cfg_home_path}/webserv/${domain_name}/piabin/psCipher"])){
        @exec { "build key ${cfg_home_path}/webserv/${domain_name}/piabin/psCipher" :
          command => $buildkey_cmd, # run command only if V1.1
          onlyif  => $testkey_cmd, # test if V1.1
          path    => "${cfg_home_path}/webserv/${domain_name}/piabin/:/bin:/usr/bin",
        }
      }
      realize (EXEC["build key ${cfg_home_path}/webserv/${domain_name}/piabin/psCipher"])
    }

}
