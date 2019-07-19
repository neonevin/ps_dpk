# *******************************************************************
# UQ pupppet profile for managing application server  domain config
# UQ - Nevin Prasannan - 25/10/2018
# V 1.0 - This for process schedulersONLY
# *******************************************************************
class my_cfg_profiles::my_appdom_cfg{

  notify { 'Applying my_cfg_profiles::my_appdom_cfg': }

  $ensure   = hiera('ensure')
  $env_type = hiera('env_type')
  if $ensure== present  {
    $kernel_val =  downcase($facts['kernel'])
    $cfg_hiera = hiera('cfg_notify')
    if $cfg_hiera {
      $log_path=$cfg_hiera[logpath]
      if $log_path == undef{
        fail ('No log path defined for config manager')
      }
      else {
        $log_file="${log_path}/ps_cfgman.log"
      }
    }
    else {
      $log_path = undef
    }

  $users_hiera = hiera('users')
  $psft_single_installer = $users_hiera['psft_user']
  if ($psft_single_installer) and ($psft_single_installer != '') {
    $psft_single_user = $psft_single_installer['name']
    $psft_single_user_home = $psft_single_installer['home_dir']
    include ::pt_setup::params
    if $psft_single_user_home and $psft_single_user_home!=''{
      $user_home_dir = $psft_single_user_home
    }
    else {
      $user_home_dir = "${::pt_setup::params::user_home_dir}/${psft_single_user}"
    }

    $pscfg_location     = hiera('ps_config_home_base')
    $ps_app_type     = hiera('psft_app_type')
    if ($pscfg_location) and ($pscfg_location != '') {
      $ps_app_cfg_base_norm="${pscfg_location}/${ps_app_type}"
    }
    else {
      $ps_app_cfg_base_norm = undef
    }

    if $facts['os']['family'] != 'windows' {
      if !defined(FILE["${user_home_dir}/.bashrc"]){
      #NP  - manage .bashrc
      # file { $title:
          @file { "${user_home_dir}/.bashrc":
          ensure  => file,
          path    => "${user_home_dir}/.bashrc",
          content => template("my_cfg_man/${kernel_val}_bashrc.erb"),
          mode    => '0754',
          owner   => $psft_single_user,
          # require => ::my_utils::my_dir_tree[$ps_cfg_home_dir],
        }
    }
    realize (FILE["${user_home_dir}/.bashrc"])
  }

  }

    # UQ Nevin Prasannan - 26/10/2018 
    $appserver_domain_list = hiera('appserver_domain_list') # List of all the app server domains
    #NP  - Begin loop for domain list
    $appserver_domain_list.each |$domain_name, $appserver_domain_info| {
      notify {"Checking Config for AppServer domain ${domain_name}":}

      $db_settings        = $appserver_domain_info['db_settings']
      validate_hash($db_settings)
      # $db_settings_array  = join_keys_to_values($db_settings, '=')
      # notify {"AppServer domain ${domain_name} with the Database settings\n":}

      $config_settings    = $appserver_domain_info['config_settings']
      validate_hash($config_settings)
      # $config_settings_array = join_keys_to_values($config_settings, '=')
      # notify {"AppServer domain ${domain_name} Config settings: [${config_settings_array}]\n":}

      # $feature_settings   = $appserver_domain_info['feature_settings']
      # validate_hash($feature_settings)
      # $feature_settings_array = join_keys_to_values($feature_settings, '=')
      # notify {"AppServer domain ${domain_name} Feature settings: ${feature_settings_array}\n":}
      # UQ NP - env_settings is not managed in psprcs.cfg, it is stored in psprcsrv.env. psprcsrv.env may become a managed file later
      # $env_settings   = $appserver_domain_info['env_settings']
      # if $env_settings {
      #   validate_hash($env_settings)
      #   $env_settings_array = join_keys_to_values($env_settings, '=')
      #   notify {"AppServer domain ${domain_name} Env settings: ${env_settings_array}\n":}
      # }
      # get the database platform

      # Manage env config script 
      # $db_platform       = upcase($db_settings['db_type'])
      if (!defined(::my_cfg_man::my_Envcfg_Man["app_${domain_name}"])){
        @::my_cfg_man::my_envcfg_man{ "app_${domain_name}":
          ensure             => present,
          dom_settings_array => $appserver_domain_info,
          domain_name        => $domain_name,
          domain_type        => 'appserver',
          cfg_log_file       => $log_path,
        }
      }
      realize(::my_cfg_man::my_Envcfg_Man["app_${domain_name}"])

      $appserver_cfg_file = "${appserver_domain_info['ps_cfg_home_dir']}/appserv/${domain_name}/psappsrv.cfg"
      if (!defined(::my_cfg_man::my_Tuxdomcfg_Man["app_${domain_name}"])){
        @::my_cfg_man::my_tuxdomcfg_man{ "app_${domain_name}":
          ensure              => present,
          cfg_file            => $appserver_cfg_file,
          cfg_settings_array  => $config_settings,
          db_settings_array   => $db_settings,
          domain_name         => $domain_name,
          domain_type         => 'app',
          tools_install_user  => 'psoft',
          tools_install_group => 'psoft',
          cfg_log_file        => $log_path,
        }
      }
      realize(::my_cfg_man::my_Tuxdomcfg_Man["app_${domain_name}"])
    }
    #NP  - END loop for domain list
  }
  elsif $ensure == absent {
# 
  }
  else {
    fail("Invalid value for 'ensure'. It needs to be either 'present' or 'absent'.")
  }
}
