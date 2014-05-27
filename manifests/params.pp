# Class: selinux::params
#
# This class defines default parameters used by the main module class selinux
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to selinux class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class selinux::params {

  ### Application related parameters

  $package = $::operatingsystem ? {
    default => 'libselinux-utils',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/selinux',
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/selinux/config',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $default_template = $::operatingsystem ? {
    default => 'selinux/selinux.config.erb',
  }

}
