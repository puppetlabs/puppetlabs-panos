# Install Palo Alto Module

OK, now we're ready to install the module.

1. Check if any modules are currently installed on your machine. Type `puppet module list` and this will output a list of modules that are installed. If you have just starting using Puppet on your workstation you will not see any output from this command.

2. Install the module from the Forge. You will need internet connectivity to run this command. Type `puppet module install puppetlabs-panos`. This will bring down and install any associated dependencies that the module needs to run. Once complete, if you type `puppet module list` again, you will see output similar to that below:
```
[root@localhost]# puppet module install puppetlabs-panos
Notice: Preparing to install into /etc/puppetlabs/code/modules ...
Notice: Created target directory /etc/puppetlabs/code/modules
Notice: Downloading from https://forgeapi.puppet.com ...
Notice: Installing -- do not interrupt ...
/etc/puppetlabs/code/modules
└─┬ puppetlabs-panos (v1.0.0)
  └─┬ puppetlabs-resource_api (v1.0.0)
    └── puppetlabs-puppetserver_gem (v1.1.0)
```

3. You can check that the module and its dependencies are installed by typing `puppet module list` and you will receive output similar to that which is below:
```
[root@localhost bolt]# puppet module list
/etc/puppetlabs/code/modules
├── puppetlabs-panos (v1.0.0)
├── puppetlabs-puppetserver_gem (v1.1.0)
└── puppetlabs-resource_api (v1.0.0)
```
# Next steps

OK, next up we're going to configure `puppet device`

[Configure Puppet Device](./../03-configure-puppet-device/README.md)
