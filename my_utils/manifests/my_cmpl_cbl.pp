# *********************************************************************************************
# pupppet class for compiling COBOL
# - Nevin Prasannan - 10/11/2018
# V 1.0 - NP - Compiles cobol source files 
# Compiles ps_home, App home and cust home based on existence of files in the cblbin directory
# *********************************************************************************************


define my_utils::my_cmpl_cbl (
  $ensure         = present,
  $ps_home        = undef,
  $app_home       = undef,
  $cust_home      = undef,
  $env_cfg_script = undef,
  $install_user   = 'psoft',#default user, if nothing provided, is  psoft
  $install_group  = undef,
)
{
  notice ('Applying my_utils::my_cmpl_cbl')

  # NP - fail if windows - Begin
  # Remove this block if  windows compilations neede to be supported and modify the execs arguments accordingly
  if $facts['os']['family'] == 'windows' {
    fail('Sorry... COBOL complation for Windows based hosts are not supported at the moment')
  }
  # NP - fail if windows - Begin

  if $ensure=='present' {
    if !defined(EXEC["CBLBIN_${ps_home}"]){
      # compile ALL(ps_home,ps_app_home, ps_cust_home) if PS_HOME/cblbin is empty
      exec { "CBLBIN_${ps_home}":
        command => ". ${env_cfg_script} && .${ps_home}/setup/pscbl.mak}",
        unless  => "test \" \$(find ${ps_home/cblbin} -maxdepth 0 -type d -empty)\"",
        path    => '/bin:/usr/bin',
        user    => $install_user,
      }
      realize (EXEC["CBLBIN_${ps_home}"])
    }
    if !defined(EXEC["CBLBIN_${app_home}"]){
      # compile APP and CUST Home clsbls  if app_home/cblbin is empty
      exec { "CBLBIN_${app_home}":
        command => ". ${env_cfg_script} && .${ps_home}/setup/pscbl.mak PS_APP_HOME}",
        unless  => "test \" \$(find ${app_home/cblbin} -maxdepth 0 -type d -empty)\"",
        path    => '/bin:/usr/bin',
        user    => $install_user,
      }
      realize (EXEC["CBLBIN_${app_home}"])
    }
    if !defined(EXEC["CBLBIN_${cust_home}"]){
      # compile CUST Home clsbls  if cust_home/cblbin is empty
      exec { "CBLBIN_${cust_home}":
        command => ". ${env_cfg_script} && .${ps_home}/setup/pscbl.mak PS_CUST_HOME}",
        unless  => "test \" \$(find ${cust_home/cblbin} -maxdepth 0 -type d -empty)\"",
        path    => '/bin:/usr/bin',
        user    => $install_user,
      }
      realize (EXEC["CBLBIN_${cust_home}"])
    }
  }
  elsif $ensure=='absent' {
    # NP - 
      # delete the ps_cust_home/cblbin and contents if exists
    file { "rmdir_${cust_home}":
      ensure  => absent,
      path    => "${cust_home/cblbin}",
      recurse => true,
      purge   => true,
      force   => true,
    }
  }
  else{
    fail('Ensure value for my_utils::my_cmpl_cbl should be present or absent')
  }
}
