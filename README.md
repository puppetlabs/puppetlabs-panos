

# panos [![Build Status](https://travis-ci.com/puppetlabs/puppetlabs-panos.svg?token=EgyaCjCqJtXUWAZqypZQ&branch=master)](https://travis-ci.com/puppetlabs/puppetlabs-panos)


#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with PANOS](#setup)
    * [Setup requirements](#setup-requirements)
    * [Getting started with PANOS](#getting-started-with-panos)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Module Description

The PANOS module configures Palo Alto firewalls running PANOS 7.1.0 or PANOS 8.1.0.

When committing changes to resources, include `panos_commit` in your manifest, or execute the `commit` task. You must do this before they can be made available to the running configuration. 

The module provides a Puppet task to manually `commit`, `store_config` to a file, and `set_config` from a file.

## Setup

### Setup Requirements

The PANOS module requires access to the device's web management interface. You will also need to install the dependences.

The module has a dependency on the `resource_api`. See the [Resource API README](https://github.com/puppetlabs/puppetlabs-resource_api#resource_api) for setup instructions.

* On each Puppet Server or PE master that needs to manage PANOS devices, classify or apply the `panos::server` class.
* On each Puppet agent that needs to manage PANOS devices, classify or apply the `panos::agent` class.

### Getting started with PANOS

To get started, create or edit `/etc/puppetlabs/puppet/device.conf`, add a section for the device (this will become the device's `certname`), specify a type of `panos`, and specify a `url` to a credentials file. For example:

```INI
[firewall.example.com]
type panos
url file:////etc/puppetlabs/puppet/devices/firewall.example.com.conf`
```

Next, create a credentials file. See the [HOCON documentation](https://github.com/lightbend/config/blob/master/HOCON.md) for information on quoted/unquoted strings and connecting the device.

There are two valid types of creditial files:

* A file containing the host, username and password in plain text:
  ```
  host: 10.0.10.20
  user: admin
  password: admin
  ```
* A file containing the host and an API key obtained from the device:
  ```
  host: 10.0.10.20
  apikey: LUFRPT10cHhRNXMyR2wrYW1MSzg5cldhNElodmVkL1U9OEV1cGY5ZjJyc2xGL1Z4Qk9TNFM2dz09
  ```

To obtain an API key for the device, use the `panos::apikey` task. The required creditials file should be in the format of the former. After which you can discard it:

```
bolt task run panos::apikey credentials_file=spec/fixtures/test-password.conf
```


Test your setup:

`puppet device --verbose --target firewall.example.com`

See the [Puppet device documentation](https://puppet.com/docs/puppet/5.5/puppet_device.html) for more information.

## Usage

Create a manifest with the changes you want to apply. For example:

```Puppet
panos_admin {
  'frank':
    ensure        =>  'present',
    password_hash =>  pw_hash('password', 'MD5'),
    ssh_key       =>  'ssh-rsa AAAA... frank@firewall.example.com',
    role          =>  'superuser';
}
```

The repo's acceptance tests examples contain a [useful reference](https://github.com/puppetlabs/puppetlabs-panos/blob/master/spec/fixtures/create.pp) on using the module's Types.

__Note:__ The pw_hash function requires [puppetlabs-stdlib](https://forge.puppet.com/puppetlabs/stdlib)


### Puppet Device

Run Puppet device apply to apply the changes:

`puppet device  --target firewall.example.com --apply manifest.pp `

Run Puppet device resource to obtain the current values:

`puppet device --resource --target firewall.example.com panos_admin`

## Reference

Full Type reference documentation availble. See [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-panos/blob/master/REFERENCE.md)

## Limitations

This module has only been tested using PANOS 7.1.0 and 8.1.0.

## Development

Contributions are welcome, especially if they can be of use to other users.

Checkout the [repo](https://github.com/puppetlabs/puppetlabs-panos) by forking and creating your feature branch.

### Type

Add new types to the type directory. We use the [Resource API format](https://github.com/puppetlabs/puppet-resource_api/blob/master/README.md).

These PANOS types extend the Resource API by adding in `xpath` values, which are used by their respective providers when retireving data from the PANOS API. If the atrribute expects multiple values to be returned, it will declare `xpath_array`.


For example:

```Ruby
  require 'puppet/resource_api'

  Puppet::ResourceApi.register_type(
    name: 'new_thing',
    docs: 'Configure the new thing of the device',
    features: ['remote_resource'],
    base_xpath: 'some/xapth/to/the/type',
    attributes: {
      ensure:       {
        type:       'Enum[present, absent]',
        desc:       'Whether the new thing should be present or absent on the target system.',
        default:    'present',
      },
      name:         {
        type:      'String',
        desc:      'The name of the new thing',
        xpath:     'some/xapth/to/the/type',
        behaviour: :namevar,
      },
      # Other fields in resource API format
    },
  )

```

### Provider

Add a provider — see existing examples. Parsing logic is contained in each types respective provider directory with a common [base provider](https://github.com/puppetlabs/puppetlabs-panos/blob/master/lib/puppet/provider/panos_provider.rb) available.

### Testing

There are two levels of testing found under `spec`.

To test this module you need a Palo Alto machine. The virtual machine images from their support area work in VirtualBox and VMware. Alternatively you can use the PAYG offering on AWS. Note that the VMs do not have to have a license deployed that is usable for development.

* [XML API docs](https://www.paloaltonetworks.com/documentation/81/pan-os/xml-api)
* [Palo Alto on AWS](https://aws.amazon.com/marketplace/search/results?x=0&y=0&searchTerms=palo+alto&page=1&ref_=nav_search_box)


#### Unit Testing

Unit tests test the parsing and command generation logic that is executed locally.

First execute `bundle exec rake spec_prep` to ensure that the local types are made available to the spec tests. Then execute with `bundle exec rake spec`.

#### Acceptance Testing

Acceptance tests are executed on actual devices.

Use test values and make sure that these are non-destructive.

The acceptance tests locate the Palo Alto box that used for testing through environment variables. The current test setup allows for three different scenarios:

* Static configuration: the VM or physical box is already running somewhere.
  Set `PANOS_TEST_HOST` to the FQDN/IP of the box and `PANOS_TEST_PLATFORM` to a platform string in the form of `palo-alto-VERSION-x86_64`.
* VMPooler: if you have a VMPooler instance available, set `VMPOOLER_HOST` to the hostname of your VMPooler instance (it defaults to Puppet's internal service), and `PANOS_TEST_PLATFORM` to the platform string of VMPooler you want to use.
* ABS: when running on Puppet's internal infrastructure, it passes reserved instances into the job through `ABS_RESOURCE_HOSTS`.

To specify the username and password used to connect to the box, set `PANOS_TEST_USER` and `PANOS_TEST_PASSWORD` respectively. Palo Alto's VMs default to `admin`/`admin`, which is also used as a default, if you don't specify anything.

After you have configured the system under test, you can run the acceptance tests directly using:

```
bundle exec rspec spec/acceptance
```

Or using the legacy rake task:

```
bundle exec rake beaker
```

### Cutting a release

To cut a new release from a current `master`:

* Start the release branch with `git checkout -b release-prep`
* Execute the [Puppet Strings](https://puppet.com/docs/puppet/5.5/puppet_strings.html) rake task to update the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-panos/blob/master/REFERENCE.md):

```
bundle exec rake strings:generate[,,,,,REFERENCE.md,true]
```
