# == Define: my_utils::mkdir_p
#
# Provide `mkdir -p` functionality for a directory
#
# Idea is to use this mkdir_p in conjunction with a file resource
#
# Example usage:
#
#  my_utils::mkdir_p { '/some/dir/structure': }
#
#  file { '/some/dir/structure':
#    ensure  => directory,
#    require => Common::Mkdir_p['/some/dir/structure'],
#  }
#
define my_utils::mkdir_p (
  $user  = undef,
  $group = undef,
  $path  = undef,
)
{
  notice ('Applying my_utils::mkdir_p')
  # notify { "user:  ${user}": }
  # notify { "group ${group}": }
  # notify { "path ${path}": }
  validate_absolute_path($path)
  if $facts['os']['family'] != 'windows' {
    exec { "mkdir_p-${name}":
      command => "mkdir -p ${path}",
      unless  => "test -d ${path}",
      path    => '/bin:/usr/bin',
      user    => $user,
      group   => $group,
    }
  }
  else {
    exec { "create_dir_${path}":
      command  => "(New-Item -ItemType Directory -Path \"${path}\")",
      unless   => "If (Test-Path -Path \"${path}\") { exit 0 } else { exit 1}",
    # environment => [ 'HOME=/home/username'],
      provider => powershell,
    }
  }
}
