require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_admin',
  docs: <<-EOS,
This type provides Puppet with the capabilities to manage "administrator" user accounts on Palo Alto devices.
EOS
  base_xpath: '/config/mgt-config/users',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:      'Pattern[/^[a-zA-z0-9\-_\.]{1,31}$/]',
      desc:      'The username.',
      behaviour: :namevar,
      xpath:     'string(@name)',
    },
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    password_hash: {
      type:  'Optional[String]',
      desc:  'Provide a password hash.',
      xpath: 'phash/text()',
    },
    authentication_profile: {
      type:  'Optional[String]',
      desc:  'Provide an authentication profile. You can use this setting for RADIUS, TACACS+, LDAP, Kerberos, or local database authentication.',
      xpath: 'authentication-profile/text()',
    },
    client_certificate_only: {
      type:    'Boolean',
      desc:    <<DESC,
Enable this option to use client certificate authentication for web access.
If you select this option, a username and password are not required; the certificate is sufficient to authenticate access to the firewall.
DESC
      default: false,
      xpath:   'client-certificate-only/text()',
    },
    ssh_key: {
      type:  'Optional[String]',
      desc:  'Provide the users public key in plain text',
      xpath: 'public-key/text()',
    },
    role: {
      type:  'Enum["superuser", "superreader", "devicereader", "deviceadmin", "custom"]',
      desc:  <<DESC,
Specify the access level for the administrator.

* superuser: Has full access to the firewall and can define new administrator accounts and virtual systems. You must have superuser privileges to create an administrative user with superuser privileges.

* superreader: Has read-only access to the firewall.

* deviceadmin: Has full access to all firewall settings except for defining new accounts or virtual systems.

* devicereader: Has read-only access to all firewall settings except password profiles (no access) and administrator accounts (only the logged in account is visible).
DESC
      xpath: 'local-name(permissions/role-based/*[1])',
    },
    role_profile: {
      type:  'Optional[String]',
      desc:  <<DESC,
Specify the role profile for the user
The following built in roles are available:

* auditadmin: The Audit Administrator is responsible for the regular review of the firewall’s audit data.

* cryptoadmin: The Cryptographic Administrator is responsible for the configuration and maintenance of cryptographic elements related to the establishment of secure connections to the firewall.

* securityadmin: The Security Administrator is responsible for all other administrative tasks (e.g. creating the firewall’s security policy) not addressed by the other two administrative roles.
DESC
      xpath: 'permissions/role-based/custom/profile/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
