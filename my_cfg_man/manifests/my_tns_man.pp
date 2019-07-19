# ***************************************************************
# UQ pupppet Role for managing tnsnames.ora
# UQ - Nevin Prasannan - 24/10/2018
# V 1.0 - This for tnsnames.ora ONLY
# ***************************************************************
define my_cfg_man::my_tns_man (
  $ensure   = present,
  $tns_file = undef,
  $oracle_user      = undef,
  $oracle_group     = undef,
)
{

  notify { 'Applying my_cfg_man::my_tns_man': }

  $tns_source = hiera('tns_source')

  file{ $title:
    ensure => $ensure,
    path   => $tns_file,
    source => [$tns_source['path'],
                  $tns_source['alt_path1'],
                  $tns_source['alt_path2']
                ],
    mode   => '0755',
    owner  => $oracle_user,
    group  => $oracle_group,
    # require => File[$tns_dir],
  }

}
