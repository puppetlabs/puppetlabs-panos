# @summary This class installs dependencies of this module into puppetserver,
#          and restarts the puppetserver service to activate.
#
# @example Declaring the class
#   include panos::server
#
# @note Deprecated, use panos::install::master
class panos::server {
  include resource_api::server
}
