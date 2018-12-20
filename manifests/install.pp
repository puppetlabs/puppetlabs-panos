# @summary This class installs dependencies of this module
#          into the puppet agent, and/or the puppetserver service.
#
# @example Declaring the class
#   include panos::install
class panos::install {

  include panos::install::agent

  if $facts['puppetserver_installed'] {
    include panos::install::master
  }
}
