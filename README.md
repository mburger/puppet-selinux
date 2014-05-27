# Puppet module: selinux

This is a Puppet module for selinux.

Based on a template defined in http://github.com/Example42-templates/

Released under the terms of Apache 2 License.


## USAGE - Basic management

* Install selinux with default settings

        class { 'selinux': }

* Install a specific version of selinux package

        class { 'selinux':
          version => '1.0.1',
        }

* Disable selinux service.

        class { 'selinux':
          disable => true
        }

* Remove selinux package

        class { 'selinux':
          absent => true
        }

* Enable auditing without without making changes on existing selinux configuration *files*

        class { 'selinux':
          audit_only => true
        }

* Module dry-run: Do not make any change on *all* the resources provided by the module

        class { 'selinux':
          noops => true
        }


## USAGE - Overrides and Customizations
* Use custom sources for main config file 

        class { 'selinux':
          source => [ "puppet:///modules/example42/selinux/selinux.conf-${hostname}" , "puppet:///modules/example42/selinux/selinux.conf" ], 
        }


* Use custom source directory for the whole configuration dir

        class { 'selinux':
          source_dir       => 'puppet:///modules/example42/selinux/conf/',
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file. Note that template and source arguments are alternative. 

        class { 'selinux':
          template => 'example42/selinux/selinux.conf.erb',
        }

* Automatically include a custom subclass

        class { 'selinux':
          my_class => 'example42::my_selinux',
        }

## TESTING
[![Build Status](https://travis-ci.org/example42/puppet-selinux.png?branch=master)](https://travis-ci.org/example42/puppet-selinux)

