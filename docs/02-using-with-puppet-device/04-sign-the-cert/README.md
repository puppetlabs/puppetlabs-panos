# Sign the certificate

To manage a device with Puppet, you need to sign a certificate. This is normal for all server based infrastructure, and is also required for devices.

1. From the command line on the host where you installed the module, run: 

`puppet device --verbose --target firewall.example.com`.

The `firewall.example.com` is the alias from the configuration files in the previous step. 

If you receive errors at this stage, declare the panos module in a class and apply it to the proxy agent, and then run the previous command again. 

> Note: Notice that the facts gathered are from your workstation and not the device under management. We are currently working on rectifying this and providing a simple way to gather facts from device nodes to include in your Puppet Enterprise deployment. Keep up-to-date on developments by checking the puppet.com/blog.


# Next steps

You are now all the set up! Next you will run the `--resource` and `--apply` commands to see `puppet device` in action.

[Run Puppet Device Commands](./../05-run-puppet-device-commands/README.md)
