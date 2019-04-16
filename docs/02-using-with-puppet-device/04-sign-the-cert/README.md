# Sign the Certificate

In order to manage a device with Puppet it is necessary to sign a certificate. This is normal for all server based infrastructure, and is required for devices also.

1. At the command line on your host that you installed the module, type: `puppet device --verbose --target firewall.example.com` where `firewall.example.com` is the alias from the configuration files in the previous step. If you receive some errors at this stage it will be necessary to declare the panos module in a class and apply to the proxy agent, and then rerun the previous command. You will notice that the facts that are gathered are those of your work station and not the device under management. We are currently working to rectify this and give a simple way to gather facts from device nodes for inclusion in your Puppet Enterprise deployment. Please keep watching puppet.com/blog for announcements regarding this.

# Next steps

So, that's all the set up done! Now we'll run some --resource and --apply commands to see `puppet device` in action.

[Run Puppet Device Commands](./../05-run-puppet-device-commands/README.md)
