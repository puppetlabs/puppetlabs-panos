# @summary This class install dependencies of this module into puppet agent
#
# @example Declaring the class
#   include panos::install::agent
class panos::install::agent {

  package { 'builder':
    ensure   => present,
    provider => 'puppet_gem',
  }
}
