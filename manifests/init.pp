# = Class: selinux
#
# This is the main selinux class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, selinux class will automatically "include $my_class"
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, selinux main config file will have the param: source => $source
#
# [*source_dir*]
#   If defined, the whole selinux configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, selinux main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove all the resources installed by the module
#   Default: false
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet. Default: false
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: undef
#
class selinux (
  $my_class            = '',
  $source              = '',
  $source_dir          = '',
  $source_dir_purge    = '',
  $template            = '',
  $options             = '',
  $version             = 'present',
  $absent              = false,
  $audit_only          = false,
  $noops               = undef,
  $mode                = ''
  ) inherits selinux::params {

  # Validation
  validate_re($mode, [ '^$', '^disabled$', '^permissive$', '^enforcing$' ])

  #################################################
  ### Definition of modules' internal variables ###
  #################################################

  # Variables defined in selinux::params
  $package=$selinux::params::package
  $config_file=$selinux::params::config_file
  $config_dir=$selinux::params::config_dir
  $config_file_mode=$selinux::params::config_file_mode
  $config_file_owner=$selinux::params::config_file_owner
  $config_file_group=$selinux::params::config_file_group
  $default_template=$selinux::params::default_template

  # Calculate dependent Variables
  $real_template = $selinux::template ? {
    ''        => $selinux::mode ? {
      ''        => '',
      default   => $selinux::default_template,
    },
    default   => $selinux::template,
  }

  $current_mode = $::selinux? {
    'false' => 'disabled',
    default => $::selinux_current_mode,
  }

  # Variables that apply parameters behaviours
  $manage_package = $selinux::absent ? {
    true  => 'absent',
    false => $selinux::version,
  }

  $manage_file = $selinux::absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $selinux::audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $selinux::audit_only ? {
    true  => false,
    false => true,
  }

  $manage_file_source = $selinux::source ? {
    ''        => undef,
    default   => $selinux::source,
  }

  $manage_file_content = $selinux::real_template ? {
    ''        => undef,
    default   => template($selinux::real_template),
  }


  #######################################
  ### Resourced managed by the module ###
  #######################################

  # Package
  package { $selinux::package:
    ensure  => $selinux::manage_package,
    noop    => $selinux::noops,
  }


  # Configuration File
  file { 'selinux.conf':
    ensure  => $selinux::manage_file,
    path    => $selinux::config_file,
    mode    => $selinux::config_file_mode,
    owner   => $selinux::config_file_owner,
    group   => $selinux::config_file_group,
    require => Package[$selinux::package],
    source  => $selinux::manage_file_source,
    content => $selinux::manage_file_content,
    replace => $selinux::manage_file_replace,
    audit   => $selinux::manage_audit,
    noop    => $selinux::noops,
  }

  # Configuration Directory
  if $selinux::source_dir {
    file { 'selinux.dir':
      ensure  => directory,
      path    => $selinux::config_dir,
      require => Package[$selinux::package],
      source  => $selinux::source_dir,
      recurse => true,
      purge   => $selinux::source_dir_purge,
      force   => $selinux::source_dir_purge,
      replace => $selinux::manage_file_replace,
      audit   => $selinux::manage_audit,
      noop    => $selinux::noops,
    }
  }


  # Set the Selinux Mode if given
  if $mode != '' and $current_mode != $mode {
    case $mode {
      'disabled': {
        notify { 'reboot_required':
          message => "a reboot is required to change selinux mode to ${mode}"
        }
        if $current_mode == 'enforcing' {
          exec { '/usr/sbin/setenforce permissive':
            require => Package['libselinux-utils']
          }
        }
      }
      /^(permissive|enforcing)$/: {
        if $current_mode == 'disabled' {
          notify { 'reboot_required':
            message => "a reboot is required to change selinux mode to ${mode}"
          }
        } else {
          exec { "/usr/sbin/setenforce ${mode}":
            require => Package['libselinux-utils'],
          }
        }
      }
    }
  }

  #######################################
  ### Optionally include custom class ###
  #######################################
  if $selinux::my_class {
    include $selinux::my_class
  }

}
