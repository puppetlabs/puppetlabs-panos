# Apply a manifest

Apply a manifest against the Palo Alto firewall to create resources. This powerful Bolt feature allows you to use all the types and providers that are available in the module. 

1. Create a manifest file called `manifest.pp` and add the following address ranges:

```
panos_address { 'newaddressrange':
    ensure => 'present',
    ip_range => '10.0.0.1-10.0.0.5',
    tags => [],
}
```

2. Apply the manifest using the `bolt apply` command:

`bolt apply manifest.pp -n pan`

This command uses the manifest to add the new address ranges above. You should see output similar to:

```
Starting: install puppet and gather facts on <hostname or IP of Palo Alto device>
Finished: install puppet and gather facts with 0 failures in 2.51 sec
Starting: apply catalog on <hostname or IP of Palo Alto device>
Finished: apply catalog with 0 failures in 6.51 sec
Finished on <hostname or IP of Palo Alto device>:
  changed: 1, failed: 0, unchanged: 0 skipped: 0, noop: 0
Successful on 1 node: <hostname or IP of Palo Alto device>
Ran on 1 node
```

3. Navigate to the Palo Alto firewall web user interface and see the address ranges. 

You have just used Bolt and a module to perform some basic automation!

4. Lastly, if you want check what that manifest is going to do before running it full apply mode, you can the simulation mode `noop` - this highlights the idempotent capabilities of Puppet. To test with `noop`, update the previous manifest and set the ensure property of the address range as `absent` and run the following command: 

`bolt apply manifest.pp -n pan --noop --debug`. 

Check the output and notice that a corrective change was run in `noop` mode — this means that the address range would have been removed if you had run the command without `noop`. If you do want to remove the newly created address range, run the same command without `noop` mode: 

`bolt apply manifest.pp -n pan`

# Next steps

That's it! You have now performed network automation with Bolt and a network device module. 

There are many other network automation tasks you can perform with Bolt. To give you some ideas, take a look at the following resources:

* Run Bolt on a jumphost to access devices on different network segments to your localhost using the [run-on](https://puppet.com/docs/bolt/latest/bolt_configuration_options.html#remote-transport-configuration-options) option.
* Use a Bolt plan with the Puppet Palo Alto module by looking at Cas's [GitHub gist](https://gist.github.com/donoghuc/8a51243b809ebe5651ff15ae24cc4969).
* Learn more about tasks and Bolt using the [Bolt hands-on-lab](https://github.com/puppetlabs/tasks-hands-on-lab).
* Try some [Cisco IOS](https://github.com/DavidS/cisco_ios/tree/device-task-poc) automation with Bolt.
* Check out the [Panos](https://forge.puppet.com/puppetlabs/panos/reference) on the Forge to see what else you can automate with Puppet and Bolt.
