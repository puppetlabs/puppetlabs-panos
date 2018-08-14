
# panos [![Build Status](https://travis-ci.com/puppetlabs/puppetlabs-panos.svg?token=EgyaCjCqJtXUWAZqypZQ&branch=master)](https://travis-ci.com/puppetlabs/puppetlabs-panos)

Welcome to your new module. A short overview of the generated parts can be found in the PDK documentation at https://puppet.com/pdk/latest/pdk_generating_modules.html .

The README template below provides a starting point with details about what information to include in your README.







#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with panos](#setup)
    * [What panos affects](#what-panos-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with panos](#beginning-with-panos)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

Start with a one- or two-sentence summary of what the module does and/or what problem it solves. This is your 30-second elevator pitch for your module. Consider including OS/Puppet version it works with.

You can give more descriptive information in a second paragraph. This paragraph should answer the questions: "What does this module *do*?" and "Why would I use it?" If your module has a range of functionality (installation, configuration, management, etc.), this is the time to mention it.

## Setup

### What panos affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For example, folks can probably figure out that your mysql_instance module affects their MySQL instances.

If there's more that they should know about, though, this is the place to mention:

* Files, packages, services, or operations that the module will alter, impact, or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled, another module, etc.), mention it here.

If your most recent release breaks compatibility or requires particular steps for upgrading, you might want to include an additional "Upgrading" section here.

### Beginning with panos

The very basic steps needed for a user to get the module up and running. This can include setup steps, if necessary, or it can be an example of the most basic use of the module.

## Usage

This section is where you describe how to customize, configure, and do the fancy stuff with your module here. It's especially helpful if you include usage examples and code samples for doing things with your module.

## Reference

Users need a complete list of your module's classes, types, defined types providers, facts, and functions, along with the parameters for each. You can provide this list either via Puppet Strings code comments or as a complete list in the README Reference section.

* If you are using Puppet Strings code comments, this Reference section should include Strings information so that your users know how to access your documentation.

* If you are not using Puppet Strings, include a list of all of your classes, defined types, and so on, along with their parameters. Each element in this listing should include:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

## Limitations

This is where you list OS compatibility, version compatibility, etc. If there are Known Issues, you might want to include them under their own heading here.

## Development

To test this module you will need to have a Palo Alto machine available. The virtual machine images from their support area work fine in virtualbox and vmware. Alternatively you can use the PAYG offering on AWS. Note that the VMs do not have to have a license deployed to be usable for development.

* [xml api docs](https://www.paloaltonetworks.com/documentation/81/pan-os/xml-api)
* [Palo Alto on AWS](https://aws.amazon.com/marketplace/search/results?x=0&y=0&searchTerms=palo+alto&page=1&ref_=nav_search_box)

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

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
