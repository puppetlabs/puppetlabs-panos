# Execute a Manifest

Finally, we'll execute a manifest against the Palo Alto firewall to create some resources. This is a particularly powerful feature of bolt because it allows you to use all the types and providers that are available in a module. In this example we'll create some simple address ranges.

1. Create a manifest file, let's just name is as `manifest.pp` with the following details
```
panos_address { 'newaddressrange':
    ensure => 'present',
    ip_range => '10.0.0.1-10.0.0.5',
    tags => [],
}
```

2. Apply the manifest using `bolt apply` by running the following command: `bolt apply manifest.pp -n pan`. This will use the manifest we just created to add the new address ranges above. You should see output similar to that which is below:
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

3. Navigate to the user interface of the Palo Alto firewall web user interface and check that the address range has been created. Well done, you've used bolt and a module to perform some basic automation!

4. One last feature we'll show you is `noop` - this is simulation mode, where you can check what a manifest would do if it was run in full apply mode - this highlights the idempotent capabilities of Puppet. Update the previous manifest to set the ensure property of the address range to be `absent`. Once that's done execute the following command: `bolt apply manifest.pp -n pan --noop --debug`. Examine the output and you will notice that a corrective change was run in `noop` mode, which means that the address range would be removed if the command was run without `noop`. To actually remove the newly created address range run the command without noop, so: `bolt apply manifest.pp -n pan` and it will actually remove the address range.

# Next steps

Well done, you've used bolt with a network device module to perform some network automation! There's a huge amount of other things that can be done, some of which are listed below. I encourage you to have a go at these additional items.

* Run bolt on a jumphost to access devices on different network segments to your localhost using the [run-on](https://puppet.com/docs/bolt/latest/bolt_configuration_options.html#remote-transport-configuration-options) option.
* Check out all the [other resources](https://forge.puppet.com/puppetlabs/panos/reference) that you can automate with Puppet and bolt.
* Use a bolt plan with the Puppet Palo Alto module by looking at Cas's [GitHub gist](https://gist.github.com/donoghuc/8a51243b809ebe5651ff15ae24cc4969).
* Learn more about tasks and bolt using this [hands-on-lab](https://github.com/puppetlabs/tasks-hands-on-lab).
* Try some [Cisco IOS](https://github.com/DavidS/cisco_ios/tree/device-task-poc) automation with bolt.
