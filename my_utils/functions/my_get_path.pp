
# *********************************************************************************************************
# function to return the actual path if substitution variables are used in the path
# Takes 2 argument - dummy_path - path with a substitution variable like $ENVNAME$ 
# base_path - Usaully the ps_cfg_home path 
# The cfg_home dir name is assummed to be the emvironment name and $ENVNAME$ is subtituted 
# with the cfg_homedir name
# Returns the actual path with substitution variables repalced by actual dir names/paths
# Handle raise condition - when either of the argument is a null string or space - returns empty string
# - Nevin Prasannan - 17/10/2018
# *********************************************************************************************************

function my_utils::my_get_path(Variant[String, Boolean] $dummy_path, Variant[String, Boolean] $base_path) >> String {
  # notify {"get path encoded_path: ${encoded_path}" :}
  # notify {"get path base_path: ${base_path}" :}
  if($dummy_path) and ($dummy_path!='') and ($base_path) and ($base_path!=''){
    if "\$ENVNAME\$" in $dummy_path {
      # notify {"get path target_list: ${target_list}" :}
      $str_base_path_list=split($base_path,'/')
      # notify {"get path str_base_path_list: ${str_base_path_list}" :}
      $str_base_env =$str_base_path_list[-1]
      # notify {"get path str_base_env: ${str_base_env}" :}
      $str_base_env_path = regsubst($dummy_path,'\$ENVNAME\$',$str_base_env)
      # notify {"get path str_base_env_path: ${str_base_env_path}" :}
      $str_return_path = $str_base_env_path
    }
    else {
      $str_return_path = $dummy_path
    }
  }
  else{
    notice('Invalid parameters passed to my_utils::my_get_path, returning empty string')
    $str_return_path = ' '
  }
}
