# ***************************************************************
# UQ pupppet Role for managing web server config
# UQ - Nevin Prasannan - 13/06/2018
# V 1.0 - This for webservers ONLY
# ***************************************************************
class my_cfg_roles::my_pia{

  notify { 'Applying my_cfg_roles::my_pia': }

  $ensure   = hiera('ensure')
  $env_type = hiera('env_type')

  # UQ Nevin Prasannan - 13/07/2018 
  # UQ profile for webserver deployment - begin

  if $env_type != 'midtier' { # try midtier first - Might need to new classification webtier if doesnt work while testing 
    fail('The my_pia role can only be applied to env_type of midtier')
  }
  contain ::my_cfg_profiles::my_piadom_cfg
  contain ::my_cfg_profiles::my_cfg_log_setup
  contain ::my_cfg_profiles::my_cfg_notify

  if $ensure == present {
    Class['::my_cfg_profiles::my_cfg_log_setup']
    -> Class['::my_cfg_profiles::my_piadom_cfg']
    -> Class['::my_cfg_profiles::my_cfg_notify']

  }
  elsif $ensure == absent {
    Class['::my_cfg_profiles::my_piadom_cfg']
  }
  else {
    fail("Invalid value for 'ensure'. It needs to be either 'present' or 'absent'.")
  }
}
