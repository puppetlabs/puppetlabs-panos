# @summary This class installs dependencies of this module into puppet agent
#
# @example Declaring the class
#   include panos::agent
#
# @note Deprecated, use panos::install::agent
class panos::agent {

  package { 'builder':
    ensure   => present,
    provider => 'puppet_gem',
  }
}
