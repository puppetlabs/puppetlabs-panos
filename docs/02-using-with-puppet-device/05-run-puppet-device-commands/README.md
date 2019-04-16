# Run Puppet Device Commands

Now that you've set up your node as a proxy to the device you will be able to run `puppet device` commands. These commands are those which are executed by Puppet Enterprise if you're using it to being your device nodes under management

1. At the command line of the node on which your device is configured type `puppet device --resource address --target firewall.example.com` and it will return all the addresses that are configured in the PANOS firewall. The output will appear as Puppet code, similar to what is below:
```
panos_address { 'newaddressrange':
    ensure => 'present',
    ip_range => '10.0.0.1-10.0.0.5',
    tags => [],
}
```

2. It is also possible to apply changes using `puppet device --apply`. To do this create a manifest entitled manifest.pp, similar to that which is below, and then run the command `puppet device --apply manifest.pp --target panos` and it will apply the manifest to create the address range.

3. Remember that it's possible use `noop` mode to simulate proposed changes if desired.

# Next steps

That's the end of this tutorial. You have now configured a node to run `puppet device` in order to manage an agentless firewall. The obvious next step is to set up this node to work with Puppet Enterprise. The links below are suggested next steps.

* Use the [Device Manager module](https://forge.puppet.com/puppetlabs/device_manager) to set up `puppet device` nodes to work with Puppet Enterprise
* Try using `puppet device` with the [Cisco IOS module](https://forge.puppet.com/puppetlabs/cisco_ios).
* Watch Rick Sherman speaking at [Puppetize Live 2018](https://www.youtube.com/watch?v=yQH11ngrxuQ) using `puppet device` for agentless management of Cisco Nexus and Cisco IOS devices.
