
# *********************************************************************************************************
# function to return the archive file name from hiera hash
# Takes 1 argument - archive_type - the hash key for archive e.g weblogic
# Returns the key value if persent in hiera else default value e.g <path>/pt_weblogic.tgx
# Handle raise condition - when the argument is a null string or space - returns null string
# - Nevin Prasannan - 05/10/2018
# *********************************************************************************************************

function my_utils::my_get_parent_dirs (String $path) >> Array {

  $archive_file_hiera = hiera('archive_files', '')
  $archive_locn = hiera('archive_location', '')
}
