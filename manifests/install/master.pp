# @summary This class installs dependencies of this module into puppetserver,
#          and restarts the puppetserver service to activate.
#
# @example Declaring the class
#   include panos::install::master
class panos::install::master {
  include resource_api::install::master
}
