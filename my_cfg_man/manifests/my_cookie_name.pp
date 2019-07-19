# ***************************************************************
# UQ - Nevin Prasannan - 15/01/2019
# Based on io_portalwar::cookie_name - psadmin.io
# https://github.com/psadmin-io/psadminio-io_portalwar
# V 1.0 - This for cookie name for webservers ONLY
# ***************************************************************
define my_cfg_man::my_cookie_name (
  $ensure          = present,
  $pia_cookie_name  = undef,
  $cfg_home_path        = undef, # CFG_HOME path
  $domain_name     = undef,
  $tools_install_user = undef,
  $tools_install_group = undef,
  $cfg_log_file    = undef,
) {
    $cfg_file = "${cfg_home_path}/webserv/${domain_name}/applications/peoplesoft/PORTAL.war/WEB-INF/weblogic.xml"
    if (!$pia_cookie_name) {
      $cookie_name = "${domain_name}-PSJSESSIONID"
    }

        # if (!defined(FILE_LINE["${domain_name} weblogic.xml cookie-name"])){
        #   # ini_subsetting { "${domain_name} WLS ${setting}, ${subset}, ${val}" :
        #   #   path       => $cfg_file,
        #   #   setting    => $setting,
        #   #   subsetting => $subset,
        #   #   value      => $val,
        #   # }
        #   @file_line { "${domain_name} weblogic.xml cookie-name" :
        #     ensure             => $ensure,
        #     path               => $cfg_file,
        #     line               => "  <cookie-name>${pia_cookie_name}</cookie-name>",
        #     match              => '^\s\s<cookie-name>',
        #     append_on_no_match => false,
        #   }
        # }
        # realize(FILE_LINE["${domain_name} weblogic.xml cookie-name"])
    if $facts['os']['family'] != 'windows' {
      if (!defined(AUGEAS["${domain_name} weblogic.xml cookie-name"])){
        @augeas { "${domain_name} weblogic.xml cookie-name" :
          lens    => 'Xml.lns',
          incl    => $cfg_file,
          context => "/files/${cfg_file}/weblogic-web-app/session-descriptor/cookie-name",
          changes => "set #text ${cookie_name}",
        }
      }
      realize(AUGEAS["${domain_name} weblogic.xml cookie-name"])
    }
    else {
      notify{"Updating cookie name is not implemented for Windows - Domain ${domain_name}":}
    }
}
