# Run Puppet device commands

Now that you have set up your node as a proxy to the device, you can run the `puppet device` commands. If you are using Puppet Enterprise (PE), these commands are executed from here to being your device nodes under management. 

1. From the command line of the node on which your device is configured, run `puppet device --resource address --target firewall.example.com` to return the addresses configured in the PANOS firewall. The output is Puppet code, similar to:

```
panos_address { 'newaddressrange':
    ensure => 'present',
    ip_range => '10.0.0.1-10.0.0.5',
    tags => [],
}
```

2. You can also apply changes using `puppet device --apply`. Create a manifest called `manifest.pp` and run `puppet device --apply manifest.pp --target panos`. This command applies the manifest to create the address range.

> Note: Remember that you can use `noop` mode to simulate proposed changes before running in full apply mode.

# Next steps

That's it! You have configured a node to run `puppet device` to manage an agentless firewall. To take this workflow further, you can set up the node to work with PE. For more information, take a look at the following resources:

* Use the [Device Manager module](https://forge.puppet.com/puppetlabs/device_manager) to set up `puppet device` nodes to work with Puppet Enterprise.
* Try using `puppet device` with the [Cisco IOS module](https://forge.puppet.com/puppetlabs/cisco_ios).
* Watch Rick Sherman speaking at [Puppetize Live 2018](https://www.youtube.com/watch?v=yQH11ngrxuQ) using `puppet device` for agentless management of Cisco Nexus and Cisco IOS devices.
