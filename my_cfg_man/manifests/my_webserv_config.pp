# ***************************************************************
# UQ - Sunny Wu
# V 1.0 - The code enables extensive logging in weblogic (PSOPS-190)
# ***************************************************************
define my_cfg_man::my_webserv_config (
  $ensure          = present,
  $cfg_home_path   = undef,
  $domain_name     = undef,
) {
    $cfg_file = "${cfg_home_path}/webserv/${domain_name}/config/config.xml"

    if $facts['os']['family'] != 'windows' {
      if (!defined(AUGEAS["${domain_name} add config.xml WL-Proxy-Client-IP"])){
        @augeas { "${domain_name} add config.xml WL-Proxy-Client-IP" :
          lens    => 'Xml.lns',
          incl    => $cfg_file,
          context => "/files/${cfg_file}/domain/server",
          changes => [
            'ins weblogic-plugin-enabled after msi-file-replication-enabled',
            'set weblogic-plugin-enabled/#text true',
          ],
          onlyif  => 'match weblogic-plugin-enabled size == 0',
        }
      }
      realize(AUGEAS["${domain_name} add config.xml WL-Proxy-Client-IP"])

      if (!defined(AUGEAS["${domain_name} set config.xml WL-Proxy-Client-IP"])){
        @augeas { "${domain_name} set config.xml WL-Proxy-Client-IP" :
          lens    => 'Xml.lns',
          incl    => $cfg_file,
          context => "/files/${cfg_file}/domain/server",
          changes => 'set weblogic-plugin-enabled/#text true',
          require => Augeas["${domain_name} add config.xml WL-Proxy-Client-IP"]
        }
      }
      realize(AUGEAS["${domain_name} set config.xml WL-Proxy-Client-IP"])
    }
    else {
      notify{"Updating WL-Proxy-Client-IP is not implemented for Windows - Domain ${domain_name}":}
    }
}
