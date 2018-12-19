# Install device module dependencies on a puppet agent.

# @summary Install dependencies into the puppet agent
#
# @example
#   include panos::install::agent

class panos::install::agent {
  include resource_api::install

  package { 'builder':
    ensure   => present,
    provider => 'puppet_gem',
  }

}

