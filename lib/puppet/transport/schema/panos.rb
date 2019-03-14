require 'puppet/resource_api'

Puppet::ResourceApi.register_transport(
  name: 'panos',
  desc: <<-EOS,
This transport connects to Palo Alto Firewalls using their HTTP XML API.
EOS
  features: [],
  connection_info: {
    host: {
      type: 'String',
      desc: 'The FQDN or IP address of the firewall to connect to.',
    },
    port: {
      type: 'Optional[Integer]',
      desc: 'The port of the firewall to connect to.',
    },
    user: {
      type: 'Optional[String]',
      desc: 'The username to use for authenticating all connections to the firewall. Only one of `username`/`password` or `apikey` can be specified.',
    },
    password: {
      type: 'Optional[String]',
      sensitive: true,
      desc: 'The password to use for authenticating all connections to the firewall. Only one of `username`/`password` or `apikey` can be specified.',
    },
    apikey: {
      type: 'Optional[String]',
      sensitive: true,
      desc: <<-EOS,
The API key to use for authenticating all connections to the firewall.
Only one of `user`/`password` or `apikey` can be specified.
Using the API key is preferred, because it avoids storing a password
in the clear, and is easily revoked by changing the password on the associated user.
EOS
    },
  },
)
