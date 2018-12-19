# @summary
#   This resource manages the `resource_api::server` on the server.
#
# @example
#   include panos::server
#
# Deprecated by panos::install::master

class panos::server {
  include resource_api::server
}
