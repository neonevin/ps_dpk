# ***************************************************************
# UQ pupppet Role for managing web server config
# UQ - Nevin Prasannan - 13/06/2018
# V 1.0 - This for webservers ONLY
# ***************************************************************
class my_cfg_profiles::my_piadom_cfg{

  notify { 'Applying my_cfg_profiles::my_piadom_cfg': }

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
    $pia_domain_list = hiera('pia_domain_list') # List of all the pia server domains
    #NP  - Begin loop for domain list
    $pia_domain_list.each |$domain_name, $pia_domain_info| {
      notify {"Checking Config for PIA domain ${domain_name}":}

      $web_settings        = $pia_domain_info['webserver_settings']
      validate_hash($web_settings)

      $java_settings    = $pia_domain_info['java_settings']


      # Manage env config script 
      if (!defined(::my_cfg_man::my_Envcfg_Man["pia_${domain_name}"])){
        @::my_cfg_man::my_envcfg_man{ "pia_${domain_name}":
          ensure             => present,
          dom_settings_array => $pia_domain_info,
          domain_name        => $domain_name,
          domain_type        => 'pia',
          cfg_log_file       => $log_path,
        }
      }
      realize(::my_cfg_man::my_Envcfg_Man["pia_${domain_name}"])

      $bin_path = "${pia_domain_info['ps_cfg_home_dir']}/webserv/${domain_name}/bin"
      if $java_settings { #only if non-empty
        validate_hash($java_settings)

        if (!defined(::my_cfg_man::my_Java_Options["pia_${domain_name}"])){
          @::my_cfg_man::my_java_options{ "pia_${domain_name}":
            ensure              => present,
            settings_array      => $java_settings,
            cfg_path            => $bin_path,
            domain_name         => $domain_name,
            tools_install_user  => 'psoft',
            tools_install_group => 'psoft',
            cfg_log_file        => $log_path,
          }
        }
        realize(::my_cfg_man::my_Java_Options["pia_${domain_name}"])
      }

      #NP  - keystore - begin
      # $igw_settings = $pia_domain_info['igw_prop_list']
      if (!defined(::my_cfg_man::my_Pskeystore["pia_${domain_name}"])){
        @::my_cfg_man::my_pskeystore{ "pia_${domain_name}":
          ensure              => present,
          keystore_pass       => $pia_domain_info['pskey_pwd'],
          cfg_home_path       => $pia_domain_info['ps_cfg_home_dir'],
          domain_name         => $domain_name,
          java_home           => hiera('jdk_location'),
          tools_install_user  => 'psoft',
          tools_install_group => 'psoft',
          cfg_log_file        => $log_path,
        }
      }
      realize(::my_cfg_man::my_Pskeystore["pia_${domain_name}"])
      #NP  - keystore - ends

      #NP  - cookie -name - begin
      $pia_cookie_name=$pia_domain_info['pia_cookie_name']
      if (!defined(::my_cfg_man::my_Cookie_Name["pia_${domain_name}"])){
        @::my_cfg_man::my_cookie_name{ "pia_${domain_name}":
          ensure              => present,
          pia_cookie_name     => $pia_cookie_name,
          cfg_home_path       => $pia_domain_info['ps_cfg_home_dir'],
          domain_name         => $domain_name,
          tools_install_user  => 'psoft',
          tools_install_group => 'psoft',
          cfg_log_file        => $log_path,
        }
      }
      realize(::my_cfg_man::my_Cookie_Name["pia_${domain_name}"])
      #NP  - cookie -name - ends

      #NP  - site settings - config.properties - begin
      $site_list = $pia_domain_info['site_list']
      if (!defined(::my_cfg_man::my_Config_Prop["pia_${domain_name}"])){
        @::my_cfg_man::my_config_prop{ "pia_${domain_name}":
          ensure              => present,
          site_list           => $site_list,
          cfg_home_path       => $pia_domain_info['ps_cfg_home_dir'],
          domain_name         => $domain_name,
          tools_install_user  => 'psoft',
          tools_install_group => 'psoft',
          cfg_log_file        => $log_path,
          require             => ::my_cfg_man::my_Pskeystore["pia_${domain_name}"],
        }
      }
      realize(::my_cfg_man::my_Config_Prop["pia_${domain_name}"])
      #NP  - site settings - config.properties - ends

      #NP  - PSIGW settings - igw.properties - begin
      $igw_settings = $pia_domain_info['igw_prop_list']
      if (!defined(::my_cfg_man::my_Psigw_Prop["pia_${domain_name}"])){
        @::my_cfg_man::my_psigw_prop{ "pia_${domain_name}":
          ensure              => present,
          igw_settings        => $igw_settings,
          cfg_home_path       => $pia_domain_info['ps_cfg_home_dir'],
          domain_name         => $domain_name,
          tools_install_user  => 'psoft',
          tools_install_group => 'psoft',
          cfg_log_file        => $log_path,
          require             => ::my_cfg_man::my_Pskeystore["pia_${domain_name}"],
        }
      }
      realize(::my_cfg_man::my_Psigw_Prop["pia_${domain_name}"])
      #NP  - PSIGW settings - igw.properties - ends
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
