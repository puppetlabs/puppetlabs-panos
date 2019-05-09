# Download the Palo Alto module

Download the Palo Alto module from the Puppet forge.

1. First, check what modules you already have installed on your machine. Run `puppet module list` to see list. If you have just started using Puppet on your workstation, you may not see any output from this command.

2. Download the module from the Forge: 

`puppet module install puppetlabs-panos`. 

This command installs any associated dependencies that the module needs to run. 

3. Check that the module and its dependencies are installed by running `puppet module list` and you will receive output similar to that which is below:

```
[root@localhost bolt]# puppet module list
/etc/puppetlabs/code/modules
├── puppetlabs-panos (v1.0.0)
├── puppetlabs-puppetserver_gem (v1.1.0)
└── puppetlabs-resource_api (v1.0.0)
```
# Next steps

Now that you have installed the Palo Alto module, you will configure `puppet device`

[Configure Puppet Device](./../03-configure-puppet-device/README.md)
