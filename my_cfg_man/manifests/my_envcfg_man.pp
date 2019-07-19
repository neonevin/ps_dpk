# ************************************************************************************
# UQ pupppet Role for managing environment config script for each domain/config home
# UQ - Nevin Prasannan - 24/10/2018
# V 1.0 - This for env config scripts ONLY
# ************************************************************************************
define my_cfg_man::my_envcfg_man (
  $ensure              = present,
  # $cfg_file            = undef,
  $dom_settings_array  = undef,
  # $db_settings_array   = undef,
  $domain_name         = undef, #used to make the config item a unique resource for puppet
  $domain_type         = undef,
  # $tools_install_user  = undef, # Future expansion
  # $tools_install_group = undef, # Future expansion
  $cfg_log_file        = undef,
)
{

  # notify { 'Applying my_cfg_man::my_tuxdomcfg_man': }
  # if $section_name{
  #   $prop_section='Startup' # UQ NP - this is to handle the DB setting array whene section is generally not defined
  # }
    if $dom_settings_array==undef{
    fail("Failed - No domain properties/settings found for domain ${domain_name}")
  }
  $os_user=$dom_settings_array['os_user']
  $dom_cfghome= $dom_settings_array['ps_cfg_home_dir']
  if ($dom_cfghome) and ($dom_cfghome!=''){
    $ps_cfg_home_dir  = $dom_cfghome
  }
  else{# UQ NP if no cfg_home provided fail
    fail("Failed - No PS_CFG_HOME location provided for domain ${domain_name}.")
  }

  #PS HOME
  $dom_pshome= $dom_settings_array['ps_home_dir']
  if ($dom_pshome) and ($dom_pshome!=''){
    $ps_home_dir  = $dom_pshome
  }
  else{
    # $ps_home_dir  = $pshome_location
    fail("Failed - No PS_HOME location provided for domain ${domain_name}.")
  }

  #PS APP HOME
  $dom_apphome= $dom_settings_array['ps_app_home_dir']
  if ($dom_apphome) and ($dom_apphome!=''){
    $ps_app_home_dir  = $dom_apphome
  }
  else{ # UQ NP - APP not required for pia
    $ps_app_home_dir = undef
  }

  #PS CUST HOME
  $dom_custhome= $dom_settings_array['ps_cust_home_dir']
  if ($dom_custhome) and ($dom_custhome!=''){
    $ps_cust_home_dir  = $dom_custhome
  }
  else{
    $ps_cust_home_dir  = undef
    notify {"Warning - No PS_APP_HOME location provided for domain ${domain_name}.":}
  }
  $ps_env_config_script_path    = $dom_settings_array['ps_env_config_script']
  # notify {"config script path : ${ps_env_config_script_path}":}
  if ($ps_env_config_script_path) and ($ps_env_config_script_path!='') {
    $ps_env_config_script=$ps_env_config_script_path
  }
  else{
    fail("Failed - No filename/path provided for env config script for ${domain_name}.")
    #  notify {"Warning : Environment config script/location not specified for Domain ${domain_name}":}
  }

  #file_dir
  $file_dir_hiera   = $dom_settings_array['file_dir']
  if ($file_dir_hiera) and ($file_dir_hiera != '') {
    $file_dir = $file_dir_hiera
  }
  else {
    $file_dir = undef
  }

  #temp
  $temp_dir_hiera   = $dom_settings_array['tmp']
  if ($temp_dir_hiera) and ($temp_dir_hiera != '') {
    $temp_dir = $temp_dir_hiera
  }
  else {
    $temp_dir = undef
  }

  if $domain_type =='pia'
  {
    $tns_location    = undef
    $oracle_location = undef
    $cobol_location  = undef
    $tuxedo_location = undef
    $oracle_tns_location = undef
    # $ps_app_home_dir = undef # No APP_HOME for pia

  }
  else {
    #ORACLE_HOME
    $oracle_hiera        = hiera('oracle_client_location')
    if ($oracle_hiera) and ($oracle_hiera != '') {
      $oracle_location    = $oracle_hiera
    }
    else {
      $oracle_location = undef
      fail("Failed - Processing domain  ${domain_name}  - No Oracle HOME/path defined.")
    }

    #TNS_ADMIN 
    $tns_location          = hiera('tns_dir')
    if ($tns_location) and ($tns_location != '') {
      $oracle_tns_location = $tns_location
    }
    else {
      $oracle_tns_location = undef
      fail("Failed - Processing domain  ${domain_name}  - No TNS path defined.")
    }

    #TUXDIR
    $tuxedo_hiera       = hiera('tuxedo_location')
    if ($tuxedo_hiera) and ($tuxedo_hiera != '') {
      $tuxedo_location    = $tuxedo_hiera
    }
    else {
      $tuxedo_location = undef
      fail("Failed - Processing domain  ${domain_name}  - No Tuxedo path defined.")
    }

    #COBDIR
    $cobol_hiera        = hiera('cobol', '')
    if ($cobol_hiera) and ($cobol_hiera != '') {
      $cobol_location = $cobol_hiera['location']
    }
    else {
      #NP  mod -- fix for strict_variables - begin
      $cobol_location = undef
      #NP  mod -- fix for strict_variables - end
    }
  }
  # JDK is common
  $jdk_hiera        = hiera('jdk_location')
  if ($jdk_hiera) and ($jdk_hiera != '') {
    $jdk_location = $jdk_hiera
  }
  else {
    #NP  mod -- fix for strict_variables - begin
    $jdk_location = undef
    #NP  mod -- fix for strict_variables - end
  }




  # UQ NP - Works only for single user install. CAn be expanded to multi-user install. Refer pt_profile::pt_psft_environment
  # if $facts['os']['family'] == 'windows' {

  #   $ps_env_config_script_norm=undef
  #   $ps_home_dir_norm=undef
  #   $ps_cfg_home_dir_norm=undef
  #   $ps_app_home_dir_norm=undef
  #   $tns_file_dir_norm=undef
  #   $cobol_home_dir_norm=undef
  #   $ps_cust_home_dir_norm = undef
  #   $file_dir_norm=undef
  #   $temp_dir_norm = undef
  #   $java_home_dir_norm = undef
  # }
  # else {
    $ps_env_config_script_norm=$ps_env_config_script
    $ps_home_dir_norm=$ps_home_dir
    $ps_cfg_home_dir_norm=$ps_cfg_home_dir
    $ps_app_home_dir_norm=$ps_app_home_dir
    $tns_file_dir_norm=$oracle_tns_location
    $cobol_home_dir_norm=$cobol_location
    $ps_cust_home_dir_norm = $ps_cust_home_dir
    $file_dir_norm=$file_dir
    $temp_dir_norm = $temp_dir
    $java_home_dir_norm = $jdk_location
    $tuxedo_home_dir = $tuxedo_location
    $oracle_home_dir=$oracle_location
  # }

  $kernel_val =  downcase($facts['kernel'])
  if !defined(FILE[$ps_env_config_script]){
      #NP  - create the ps_cfg_home dir if it doesnt exist
    #NP  - create the env_config script file
    # file { $title:
      @file { $ps_env_config_script:
        ensure  => file,
        path    => $ps_env_config_script,
        content => template("pt_setup/${kernel_val}_user_environment.erb"),
        mode    => '0754',
        owner   => $os_user,
        # require => ::my_utils::my_dir_tree[$ps_cfg_home_dir],
      }
  }
  realize (FILE[$ps_env_config_script])
    if $facts['os']['family'] != 'windows' {
    #Log message
      exec {"${domain_name} env cfg":
        command     => "echo File: ${ps_env_config_script} - contents changed >> ${cfg_log_file}",
        subscribe   => FILE[$ps_env_config_script],
        refreshonly => true,
        path        => '/bin:/usr/bin',
      }
    }
}

