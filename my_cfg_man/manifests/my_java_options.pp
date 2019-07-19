# ***************************************************************
# UQ - Nevin Prasannan - 15/01/2019
# V 1.0 - This for java options for webservers ONLY
# ***************************************************************
define my_cfg_man::my_java_options (
  $ensure          = present,
  # $pia_domain_list = $pia_domain_list,
  $settings_array  = undef,
  $cfg_path        = undef,
  $domain_name     = undef,
  $tools_install_user = undef,
  $tools_install_group = undef,
  $cfg_log_file    = undef,
) {
    if $settings_array { #if non-empty
    $settings_array.each | $file_name, $hash | {
      # notify {"java opt ${$cfg_path } : ${file_name}":}
      if $facts['os']['family'] != 'windows' {
        $cfg_file = "${cfg_path}/${file_name}.sh"
      }
      else {
        $cfg_file = "${cfg_path}\\${file_name}.bat"
      }
      case $file_name {
        'setEnv':{
          $setting = 'JAVA_OPTIONS_LINUX'
        }
        'startPIA':{
          $setting = 'JAVA_OPTIONS'
          if (!defined(FILE_LINE[$cfg_file])){
            $java_opt="\${${setting}}" # evaluates to ${JAVA_OPTIONS}
            @file_line { $cfg_file:
              ensure  =>  $ensure,
              path    =>  $cfg_file, #cfg_home/webserv/domname/bin/startPIA.sh
              # line   =>  "JAVA_OPTIONS=\"\${JAVA_OPTIONS}\"",
              line    =>  "JAVA_OPTIONS=\"${java_opt}\"",
              match   => "^\\s*JAVA_OPTIONS=\"\\\${JAVA_OPTIONS}.*",
              after   => "^\\s*echo \"Attempting to start WebLogic Server",
              replace => false,
            }
          }
          realize(FILE_LINE[$cfg_file])
        }
        default:{ $setting=undef}
      }
      if $hash{
      $hash.each | $subset, $val | {
        if (!defined(INI_SUBSETTING["${domain_name} WLS ${setting}, ${subset}, ${val}"])){
          @ini_subsetting { "${domain_name} WLS ${setting}, ${subset}, ${val}" :
            path       => $cfg_file,
            setting    => $setting,
            subsetting => $subset,
            value      => $val,
          }
        }
        realize(INI_SUBSETTING["${domain_name} WLS ${setting}, ${subset}, ${val}"])
    }
    }
  }
  } #settings_array if non-empty
}
