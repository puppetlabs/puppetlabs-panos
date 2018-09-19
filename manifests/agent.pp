# @summary
#   This resource manages the `resource_api::agent` and the builder gem on an agent.
#
# @example
#   include panos::agent
class panos::agent {
  include resource_api::agent
  package { 'builder':
    ensure   => present,
    provider => 'puppet_gem',
  }
}
