
# *********************************************************************************************************
# function to return the archive file name from hiera hash
# Takes 1 argument - archive_type - the hash key for archive e.g weblogic
# Returns the key value if persent in hiera else default value e.g <path>/pt_weblogic.tgx
# Handle raise condition - when the argument is a null string or space - returns null string
# - Nevin Prasannan - 05/10/2018
# *********************************************************************************************************

function my_utils::my_get_archive_list(Variant[String, Boolean] $archive_type) >> String {

  $archive_file_hiera = hiera('archive_files', '')
  $archive_locn = hiera('archive_location', '')
  if $archive_type !=undef and archive_type!='' { # If argument is defined and not empty -undef is not likely
    if $archive_file_hiera {
      $archive_file  = $archive_file_hiera[$archive_type] # Get value for hash key <archive_type> e.g java
    }
    # notify { "my_get_archive_list : ${}": } 
    if $archive_file  {
      $archive_file_name=$archive_file
    }
    else { # archive_type not found in hash, return default filename
      $archive_file_name="${archive_locn}/pt_${archive_type}.tgz"
    }
  }
  else{ #argument was undef or empty string - return empty string
    $archive_file_name=''
  }
}
