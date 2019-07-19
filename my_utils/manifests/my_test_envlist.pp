# NO 15 10 2018
#Test clsss for get env list
class my_utils::my_test_envlist {
  notify {'listed':}



$str_path=my_utils::my_get_path('/psoft/share/batch/$ENVNAME$/em_tmp', '/psoft/oracle/psoft/SA92SBOX')
notify {"new path: ${str_path}" :}
notify {'Parsing 2ns string' :}
$str_path2=my_utils::my_get_path('/psoft/share/batch/somepath/em_tmp', '/psoft/oracle/psoft/SA92SBOX/')

# notify {"new path1: ${str_path2}" :}
#   @::pt_setup::my_setup_dir{'sa92sbox':
#     ensure   => present,
#     env_path => '/psoft/oracle/psoft/SA92SBOX',
#   }
# realize (::Pt_setup::my_setup_dir('sa92sbox'))


$dir_hiera=hiera('dir_list')
        # notify {"Deploying mods hiera ${deploy_hiera}":}
        # $piadom_pshome= $pia_domain_info['ps_home_dir']
$dir_list=$dir_hiera['prcs']
#         # notify {"Deploying mods web  ${deploy_list}":}
# @::pt_setup::my_setup_dir { 'sa92sbox':
#   ensure      => present,
#   deploy_list => $dir_list,
#   env_path    => '/psoft/oracle/psoft/SA92SBOX',
# }
# realize (::Pt_setup::my_setup_dir['sa92sbox'])

              @my_utils::my_dir_tree {'/psoft/share/web/dir/test':
                ensure   => present,
                filepath => '/psoft/share/web/dir/test',
                # install_user  => undef,
                # install_group => undef,
              }
              realize (::my_utils::my_dir_tree['/psoft/share/web/dir/test'])
}
