

# panos [![Build Status](https://travis-ci.com/puppetlabs/puppetlabs-panos.svg?token=EgyaCjCqJtXUWAZqypZQ&branch=master)](https://travis-ci.com/puppetlabs/puppetlabs-panos)


#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with PANOS](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with PANOS](#beginning-with-panos)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Module Description

The PANOS module allows for the configuration of Palo Alto firewalls running PANOS 7.1.0 or PANOS 8.1.0.

Any changes made by this module to the various resources must be committed before they are made available to the running configuration. This can be done by including `panos_commit` within your manifest, or alternatively executing the `commit` task.

This module provides a Puppet task to manually `commit`, `store_config` to a file and `set_config` from a file.

## Setup

Install the module on either a Puppet Master or Puppet Agent machine, by running `puppet module install puppetlabs-panos`. To install from source download the tar file from GitHub and run `puppet module install <file_name>.tar.gz --force`.

### Setup Requirements

This module requires a user that can access the device's web management interface and the dependences will need to be installed.

The PANOS module has a dependency on the `resource_api` - it will be installed when the module is installed. Alternatively, it can be manually installed by running `puppet module install puppetlabs-resource_api` or following the setup instructions [on the Resource API README](https://github.com/puppetlabs/puppetlabs-resource_api#resource_api).

Once the module has been installed it is necessary to classify the appropriate class, by following the instructions below:

* on each puppetserver or PE master that needs to manage PANOS devices, classify or apply the `panos::server` class; run this command: `puppet apply -e 'include panos::server'`.
* on each puppet agent that needs to manage PAOS devices, classify or apply the `panos::agent` class; run this command: `puppet apply -e 'include panos::agent'`.

### Beginning with PANOS

To get started, create or edit `/etc/puppetlabs/puppet/device.conf`, add a section for the device (this will become the device's `certname`), specify a type of `panos`, and specify a `url` to a credentials file. For example:

```INI
[firewall.example.com]
type panos
url file:////etc/puppetlabs/puppet/devices/firewall.example.com.conf`
```

Next, create a credentials file, following the [HOCON documentation](https://github.com/lightbend/config/blob/master/HOCON.md) regarding quoted/unquoted strings, with connection information for the device.

There are two valid type of credential file, examples below.

* (a) A file containing the host, username and password in plain text, for example:
  ```
  host: 10.0.10.20
  user: admin
  password: admin
  ```
* (b) A file containing the host and an API key obtained from the device, for example:
  ```
  host: 10.0.10.20
  apikey: LUFRPT10cHhRNXMyR2wrYW1MSzg5cldhNElodmVkL1U9OEV1cGY5ZjJyc2xGL1Z4Qk9TNFM2dz09
  ```

To obtain an API key for the device, it is possible to use the `panos::apikey` task. The required creditials file should be in the format of (a) above. After which it can be discarded. To run this task the module must first be installed on your machine, along with [Puppet Bolt](https://puppet.com/docs/bolt/0.x/bolt_installing.html). When complete execute the following command:

```
bolt task run panos::apikey --nodes <IP_address_of_PAN_device> --modulepath <module_installation_dir> --params @credentials.json
```

The `--modulepath` param can be retrieved by typing `puppet config print modulepath`. The credentials file needs to be valid JSON containing host, username and password for the Palo Alto firewall. Note that for the above command to work the Palo Alto device must firstly have its host key verified.

Test your setup and get the certificate signed. Run the following command:

`puppet device --verbose --target firewall.example.com`

This will sign the certificate and set up the device ready for use with Puppet.

More information on the usage of `puppet device` is available in the [Puppet Documentation](https://puppet.com/docs/puppet/5.5/puppet_device.html)

## Usage
Once the above is done you can manage resources on the Palo Alto device. The module gives access to various resources on the Palo Device as listed in [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-panos/blob/master/REFERENCE.md).

The repo's acceptance tests examples contain a [useful reference](https://github.com/puppetlabs/puppetlabs-panos/blob/master/spec/fixtures/create.pp) on the use of the module's Types.

__NOTE:__ pw_hash function in the above example requires [puppetlabs-stdlib](https://forge.puppet.com/puppetlabs/stdlib)

### Puppet Device

To get information from the device you can use the `puppet device --resource` command. For example, to retrieve addresses on the device type the following:

`puppet device --resource --target firewall.example.com panos_address`

To create a new address, you will need to create a manifest. Below is a very basic manifest, create a file named `manifest.pp` containing the following:

```
panos_address { 'somenewaddress':
  ensure => 'present',
  ip_range => '10.0.0.1-10.0.0.5',
  tags => [],
}
```

Now, execute the following command:

`puppet device  --target firewall.example.com --apply manifest.pp`

This will apply the manifest. Puppet will firstly check if the address already exists and if it is absent it will create it (idempotency check). now that is done, when you query for addresses you will see that the new address is available. To do this run the following command again:

`puppet device --resource --target firewall.example.com panos_address`

Note that if you get errors try running the above commands with `--verbose` to get the errors messages output.

## Reference

Full Type reference documentation availble. See [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-panos/blob/master/REFERENCE.md)

## Limitations

This module has been tested using PANOS 7.1.0 and 8.1.0

## Development

Contributions are welcome, especially if they can be of use to other users.

Checkout the [repo](https://github.com/puppetlabs/puppetlabs-panos) by forking and creating your feature branch.

### Type

Add new types to the type directory.
We use the [Resource API format](https://github.com/puppetlabs/puppet-resource_api/blob/master/README.md).


These PANOS types extend the Resource API by adding in `xpath` values, which are used by their respective providers when retireving data from the PANOS API. If the atrribute expects multiple values to be returned, `xpath_array` will be declared.


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

Add a provider — see existing examples. Parsing logic is contained each types respective provider directory with a common [base provider](https://github.com/puppetlabs/puppetlabs-panos/blob/master/lib/puppet/provider/panos_provider.rb) available.

### Testing

There are 2 levels of testing found under `spec`.

To test this module you will need to have a Palo Alto machine available. The virtual machine images from their support area work fine in virtualbox and vmware. Alternatively you can use the PAYG offering on AWS. Note that the VMs do not have to have a license deployed to be usable for development.

* [XML API docs](https://www.paloaltonetworks.com/documentation/81/pan-os/xml-api)
* [Palo Alto on AWS](https://aws.amazon.com/marketplace/search/results?x=0&y=0&searchTerms=palo+alto&page=1&ref_=nav_search_box)


#### Unit Testing

Unit tests test the parsing and command generation logic executed locally.

First execute `bundle exec rake spec_prep` to ensure that the local types are made available to the spec tests.

Then execute with `bundle exec rake spec`.

#### Acceptance Testing

Acceptance tests are executed on actual devices.

Use test values and make sure that these are non-destructive.

The acceptance tests locate the Palo Alto box used for testing through environment variables. The current test setup allows for three different scenarios:

* Static configuration: the VM or physical box is already running somewhere.
  Set `PANOS_TEST_HOST` to the FQDN/IP of the box and `PANOS_TEST_PLATFORM` to a platform string in the form of `palo-alto-VERSION-x86_64`.
* VMPooler: if you have a VMPooler instance available, set `VMPOOLER_HOST` to the hostname of your VMPooler instance (it defaults to Puppet's internal service), and `PANOS_TEST_PLATFORM` to the platform string of VMPooler you want to use.
* ABS: When running on Puppet's internal infrastructure, reserved instances are passed into the job through `ABS_RESOURCE_HOSTS`.

To specify the username and password used to connect to the box, set `PANOS_TEST_USER` and `PANOS_TEST_PASSWORD` respectively. Palo Alto's VMs default to `admin`/`admin`, which is also used as a default, if you don't specify anything.

After you have configured the system under test, you can run the acceptance tests directly using

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
* Execute the [Puppet Strings](https://puppet.com/docs/puppet/5.5/puppet_strings.html) rake task to update [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-panos/blob/master/REFERENCE.md)

```
bundle exec rake strings:generate[,,,,,REFERENCE.md,true]
```
