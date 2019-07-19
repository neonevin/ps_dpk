# *******************************************************************
# pupppet class for creating directory tree
# - Nevin Prasannan - 10/10/2018
# V 1.0 - NP - Creates directory (and parents) if they doesn't exist
# *******************************************************************


define my_utils::my_dir_tree (
  $ensure        = present,
  $filepath      = undef,
  $install_user  = undef,
  $install_group = undef,
)
{
  notice ('Applying my_utils::my_dir_tree')
  # notify {'Applying my_utils::my_dir_tree':}
  if $ensure=='present' {
    # $dir_tree=dirtree($filepath)
    # notify { "filepath ${filepath}": }
    # notify { "install_user ${install_user}": }
    # notify { "install_group ${install_group}": }
      # contain ::my_utils::mkdir_p
    ::my_utils::mkdir_p{ $filepath:
      path  => $filepath,
      user  => $install_user,
      group => $install_group,
    }
    #
    # file { $filepath:
    #   ensure  => directory,
    #   require => ::my_utils::Mkdir_p[$filepath],
    #   owner   => $install_user,
    #   group   => $install_group,
    # }
  }
  elsif $ensure=='absent' {
    if $facts['os']['family'] != 'windows'
    {
      # Check if the dir is empty
      # the find command returns the path if the directory is empty. 
      # i.e Test fails if the string is non-empty and returns a non-zero exit code
      exec { "rmdir_${name}":
        command => "rmdir ${name}",
        unless  => "test \" \$(find ${filepath} -maxdepth 0 -type d -empty)\"",
        path    => '/bin:/usr/bin',
      }
    }
    else{
      exec { "remove_dir_${name}":
        command  => "(New-Item -ItemType Directory -Path \"${filepath}\")",
        unless   => "If ( (Get-ChildItem -Path \"${filepath}\"| Measure-Object).Count -eq 0 ) { exit 1 } else { exit 0}",
      # environment => [ 'HOME=/home/username'],
        provider => powershell,
      }
    }
  }
  else{
    fail('Ensure value for my_utils::my_dir_tree should be present or absent')
  }
}
