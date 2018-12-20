

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

Install the module on either a Puppet master or Puppet agent, by running `puppet module install puppetlabs-panos`. To install from source, download the tar file from GitHub and run `puppet module install <file_name>.tar.gz --force`.

This module installs the Builder and Puppet Resource API gems, if necessary. To activate the Puppet Resource API gem on the master, reload the puppetserver service. In most cases, this happens automatically and causes little to no interruption to service.

### Setup Requirements

#### Device access

The PANOS module requires access to the device's web management interface.

#### Proxy Puppet agent

Since a Puppet agent is not available for Palo Alto devices, we need a proxy Puppet agent (either a compile master, or another agent) to run Puppet on behalf of the device.

#### Install dependencies

Once the module has been installed, install dependencies of the module:

1. Classify or apply the `panos` class on each master (master of masters, and if present, compile masters and replica master) that serves catalogs for this module.
1. Classify or apply the `panos` class on each proxy Puppet agent that proxies for Palo Alto devices.

Run puppet agent -t on the master(s) before using the module on the agent(s).

### Getting started with PANOS

To get started, create or edit `/etc/puppetlabs/puppet/device.conf` on the proxy Puppet agent, add a section for the device (this will become the device's `certname`), specify a type of `panos`, and specify a `url` to a credentials file.

For example:

```INI
[firewall.example.com]
type panos
url file:////etc/puppetlabs/puppet/devices/firewall.example.com.conf
```

Next, create a credentials file. See the [HOCON documentation](https://github.com/lightbend/config/blob/master/HOCON.md) for information on quoted/unquoted strings and connecting the device.

There are two valid types of credential files:

* (a) A file containing the host, username and password in plain text, for example:
  ```
  address: 10.0.10.20
  username: admin
  password: admin
  ```
* (b) A file containing the address and an API key obtained from the device, for example:
  ```
  address: 10.0.10.20
  apikey: LUFRPT10cHhRNXMyR2wrYW1MSzg5cldhNElodmVkL1U9OEV1cGY5ZjJyc2xGL1Z4Qk9TNFM2dz09
  ```

__Note:__ v0.1.0 requires `host` instead of `address`

__Note:__ v0.1.0 requires `user` instead of `username`

To obtain an API key for the device, it is possible to use the `panos::apikey` task. The required creditials file should be in the format of (a) above. After which you can discard it. Before running this task, install the module on your machine, along with [Puppet Bolt](https://puppet.com/docs/bolt/0.x/bolt_installing.html). When complete, execute the following command:

```
bolt task run panos::apikey --nodes localhost --transport local --modulepath <module_installation_dir> --params @credentials.json
```

The `--modulepath` param can be retrieved by typing `puppet config print modulepath`. The credentials file needs to be valid JSON containing host, username and password for the Palo Alto firewall.

Test your setup and get the certificate signed:

`puppet device --verbose --target firewall.example.com`

This will sign the certificate and set up the device for Puppet.

See the [`puppet device` documentation](https://puppet.com/docs/puppet/5.5/puppet_device.html)

## Usage

Now you can manage resources on the Palo Alto device. The module gives you access to various resources on the Palo Alto device, listed in the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-panos/blob/master/REFERENCE.md).

The repo's acceptance test examples contain a [useful reference](https://github.com/puppetlabs/puppetlabs-panos/blob/master/spec/fixtures/create.pp) on the use of the module's Types.

__Note:__ pw_hash function in the above example requires [puppetlabs-stdlib](https://forge.puppet.com/puppetlabs/stdlib)

### Puppet Device

To get information from the device, use the `puppet device --resource` command. For example, to retrieve addresses on the device, run the following:

`puppet device --resource --target firewall.example.com panos_address`

To create a new address, write a manifest. Start by making a file named `manifest.pp` with the following content:

```
panos_address { 'somenewaddress':
  ensure => 'present',
  ip_range => '10.0.0.1-10.0.0.5',
  tags => [],
}
```

Execute the following command:

`puppet device  --target firewall.example.com --apply manifest.pp`

This will apply the manifest. Puppet will check if the address already exists and if it is absent it will create it (idempotency check). When you query for addresses you will see that the new address is available. To do this, run the following command again:

`puppet device --resource --target firewall.example.com panos_address`

Note that if you get errors, run the above commands with `--verbose` - this will give you error message output.

## Reference

For full type reference documentation, see the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-panos/blob/master/REFERENCE.md)

## Limitations

This module has only been tested with PANOS 7.1.0 and 8.1.0

## Development

Contributions are welcome, especially if they can be of use to other users.

Checkout the [repo](https://github.com/puppetlabs/puppetlabs-panos) by forking and creating your feature branch.

### Type

Add new types to the type directory.
We use the [Resource API format](https://github.com/puppetlabs/puppet-resource_api/blob/master/README.md).

These PANOS types extend the Resource API by adding in `xpath` values, which are used by their respective providers when retireving data from the PANOS API. If the attribute expects multiple values to be returned, it will declare `xpath_array`.


Here is a simple example:

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

To test this module you will need to have a Palo Alto machine available. The virtual machine images from their support area work fine in VirtualBox and VMware. Alternatively you can use the PAYG offering on AWS. Note that the VMs do not need to have license deployed that is usable for development.

* [XML API docs](https://www.paloaltonetworks.com/documentation/81/pan-os/xml-api)
* [Palo Alto on AWS](https://aws.amazon.com/marketplace/search/results?x=0&y=0&searchTerms=palo+alto&page=1&ref_=nav_search_box)


#### Unit Testing

Unit tests test the parsing and command generation logic, executed locally.

First execute `bundle exec rake spec_prep` to ensure that the local types are made available to the spec tests. Then execute with `bundle exec rake spec`.

#### Acceptance Testing

Acceptance tests are executed on actual devices.

Use test values and make sure that these are non-destructive.

The acceptance tests locate the Palo Alto box that is used for testing through environment variables. The current test setup allows for three different scenarios:

* Static configuration: the VM or physical box is already running somewhere.
  Set `PANOS_TEST_HOST` to the FQDN/IP of the box and `PANOS_TEST_PLATFORM` to a platform string in the form of `palo-alto-VERSION-x86_64`.
* VMPooler: if you have a VMPooler instance available, set `VMPOOLER_HOST` to the hostname of your VMPooler instance (it defaults to Puppet's internal service), and `PANOS_TEST_PLATFORM` to the platform string of VMPooler you want to use.
* ABS: when running on Puppet's internal infrastructure, it passes reserved instances into the job through `ABS_RESOURCE_HOSTS`.

To specify the username and password used to connect to the box, set `PANOS_TEST_USER` and `PANOS_TEST_PASSWORD` respectively. Palo Alto's VMs default to `admin`/`admin`, which is also used as a default, if you don't specify anything.

After you have configured the system under test, you can run the acceptance tests directly using:

```
bundle exec rspec spec/acceptance
```

or using the legacy rake task

```
bundle exec rake beaker
```

### Cutting a release

To cut a new release, from a current `master` checkout:

* Start the release branch with `git checkout -b release-prep`
* Execute the [Puppet Strings](https://puppet.com/docs/puppet/5.5/puppet_strings.html) rake task to update the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-panos/blob/master/REFERENCE.md):

```
bundle exec rake 'strings:generate[,,,,,REFERENCE.md,true]'
```

* Make sure that all PRs are tagged appropriately
