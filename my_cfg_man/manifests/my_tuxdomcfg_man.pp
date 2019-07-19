# *****************************************************************************
# UQ pupppet Role for managing tuxedo domains i.e app and prcs server domains
# UQ - Nevin Prasannan - 24/10/2018
# V 1.0 - This for tuxedo domains ONLY
# *****************************************************************************
define my_cfg_man::my_tuxdomcfg_man (
  $ensure              = present,
  $cfg_file            = undef,
  $cfg_settings_array  = undef,
  $db_settings_array   = undef,
  $domain_name         = undef, #used to make the config item a unique resource for puppet
  $domain_type         = undef,
  $tools_install_user  = undef, # Future expansion
  $tools_install_group = undef, # Future expansion
  $cfg_log_file        = undef,
)
{

  # notify { 'Applying my_cfg_man::my_tuxdomcfg_man': }
  # if $section_name{
  #   $prop_section='Startup' # UQ NP - this is to handle the DB setting array whene section is generally not defined
  # }

# notify{ "cfg log ${cfg_log_file}":}
    $db_settings_array.each |$dp_prop_name, $db_prop_value| {
      # notify{"config item: ${prop_value}":}
      # notice("config item: ${prop_value}")
      case $dp_prop_name {
        'db_name'  : { $prop_name='DBName'}
        'db_type'  : { $prop_name='DBType'}
        'db_opr_id'  : { $prop_name='UserId'}
        'db_opr_phash'  : { $prop_name='UserPswd'}
        'db_connect_id'  : { $prop_name='ConnectId'}
        'db_conn_phash'  : { $prop_name='ConnectPswd'}
        default :{ $prop_name=undef }
      }

      $prop_section = 'Startup'
      $prop_setting = $prop_name
      if $prop_name{
        #NP  security bit for not displaying passwords in the log
        if ($prop_setting =~ /(?i)pwd$/) or ($prop_setting =~ /(?i)pswd$/) { #NP  - if the property name ends with pwd (case insensitive)
          $show_diff=false
        }
        else {
          $show_diff=true
        }
        # # UQ NP -= Debug code - prints the values - begin
        # if (!defined(NOTIFY["title_${prop_value}"])){
        #   @notify{ "title_${prop_value}":
        #     # message => "array: ${cfg_settings_array} || cfg name : ${prop_name} || config item : ${prop_value}",
        #     message => "prop  : ${prop_section}:${prop_setting} || config item : ${prop_value}",
        #   }
        # }
        # realize (NOTIFY["title_${prop_value}"])
        # # UQ NP -= Debug code - prints the values - ends
        if (!defined( Ini_Setting["${domain_name}_${prop_name}"] )){
          @ini_setting { "${domain_name}_${prop_name}":
            ensure    => $ensure,
            path      => $cfg_file,
            section   => $prop_section,
            setting   => $prop_setting,
            value     => $db_prop_value,
            show_diff => $show_diff,
          }
        }
        realize ( Ini_Setting["${domain_name}_${prop_name}"] )
        if $facts['os']['family'] != 'windows' {
          exec {"${domain_name}_${prop_name}":
            command     => "echo Domain: ${domain_name}, Section : ${$prop_section}, Property: ${$prop_setting} :: changed to ${$db_prop_value} >> ${cfg_log_file}",
            subscribe   => Ini_Setting["${domain_name}_${prop_name}"],
            refreshonly => true,
            path        => '/bin:/usr/bin',
          }
        }
      }
    }

    $cfg_settings_array.each |$prop_name, $prop_value| {
      # notify{"config item: ${prop_value}":}
      # notice("config item: ${prop_value}")
      $prop_section = split($prop_name, '/')[0] # split the string with '/' - get the prop section from the LHS
      # split the string with '/' - get the prop setting from the RHS. 
      # If the actual parameter  string contains more than one '/' eg Log/Output Directory. Join them back to as string
      $prop_strings = join(split($prop_name, '/')[1,-1],'/')
      # notify{"prop ${prop_strings}":}
      # $prop_setting = split($prop_name, '/')[1] # split the string with '/' - get the prop setting from the RHS
      $prop_setting = $prop_strings
      #NP  security bit for not displaying passwords in the log
      if ($prop_setting =~ /(?i)pwd$/) or ($prop_setting =~ /(?i)pswd$/) { #NP  - if the property name ends with pwd (case insensitive)
        $show_diff=false
      }
      else {
        $show_diff=true
      }
      # # UQ NP -= Debug code - prints the values - begin
      # if (!defined(NOTIFY["title_${prop_value}"])){
      #   @notify{ "title_${prop_value}":
      #     # message => "array: ${cfg_settings_array} || cfg name : ${prop_name} || config item : ${prop_value}",
      #     message => "prop  : ${prop_section}:${prop_setting} || config item : ${prop_value}",
      #   }
      # }
      # realize (NOTIFY["title_${prop_value}"])
      # # UQ NP -= Debug code - prints the values - ends

      if (!defined( Ini_Setting["${domain_name}_${prop_name}"] )){
        @ini_setting { "${domain_name}_${prop_name}":
          ensure    => $ensure,
          path      => $cfg_file,
          section   => $prop_section,
          setting   => $prop_setting,
          value     => $prop_value,
          show_diff => $show_diff,
        }
      }
      realize ( Ini_Setting["${domain_name}_${prop_name}"] )
      if $facts['os']['family'] != 'windows' {
        exec {"${domain_name}_${prop_name}":
            command     => "echo Domain: ${domain_name}, Section : ${$prop_section}, Property: ${$prop_setting} :: changed to ${$prop_value} >> ${cfg_log_file}",
            subscribe   => Ini_Setting["${domain_name}_${prop_name}"],
            refreshonly => true,
            path        => '/bin:/usr/bin',
        }
      }
    }
}
