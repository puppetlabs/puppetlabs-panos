# Download Puppet Panos Module

OK, so now we're going to use bolt to download the [Puppet Palo Alto module](https://forge.puppet.com/puppetlabs/panos) from [the Forge](https://forge.puppet.com/) to your local workstation. This can be done by creating a [Puppetfile](https://puppet.com/docs/bolt/latest/installing_tasks_from_the_forge.html#task-8928) and adding a link to the Forge module.

1. Go to your bolt working directory. This is `$HOME/.puppetlabs/bolt`.

2. Create a file called `Puppetfile`.

3. Edit the file to tell bolt where to get the module, the module to retrieve and the version of the module. Those of your already familiar with Puppet will see that it uses the same format as existing Puppetfiles. For this purpose of this tutorial, enter the following details in the Puppetfile:
```
forge 'http://forge.puppetlabs.com'
mod 'puppetlabs-panos', '1.0.0'
```

4. Now install the module using bolt by typing `bolt puppetfile install` from the command line. When complete you should get a message which states that the modules were successfully synced, something like: `Successfully synced modules from $HOME/.puppetlabs/bolt/Puppetfile to $HOME/.puppetlabs/bolt/modules`

5. To verify that this worked you should now see a `modules` folder in your bolt working directory. Within that folder you should see a folder entitled `panos` which contains the downloaded Puppet Palo Alto module from the Forge. Type `ls $HOME/.puppetlabs/bolt/modules` and should see a folder entitled `panos` which contains the downloaded module. Now, type `bolt task show` and it will list all the tasks that bolt can access on your local machine. This should include 4 tasks in the Palo Alto module, as follows:
```
panos::apikey            Retrieve a PAN-OS apikey
panos::commit            Commit a candidate configuration to a firewall.
panos::set_config        upload and/or apply a configuration to a firewall.
panos::store_config      Retrieve the configuration running on the firewall.
```

# Next steps

OK, now we've got the module installed we'll configure the Palo Alto firewall in the inventory.yaml file.

[Update bolt Inventory](./../03-update-bolt-inventory/README.md)