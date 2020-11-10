# @summary This class installs dependencies of this module into puppetserver,
#          and restarts the puppetserver service to activate.
#
# @example Declaring the class
#   include panos::install::server
class panos::install::server {
  # Terminology update waiting on IAC-1006
  include resource_api::install::master
}
