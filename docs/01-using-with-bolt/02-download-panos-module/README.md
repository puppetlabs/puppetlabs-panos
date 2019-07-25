# Download the Puppet Panos module

Use Bolt to download the [Puppet Palo Alto module](https://forge.puppet.com/puppetlabs/panos) from [the Forge](https://forge.puppet.com/) to your local workstation. In this lab, you will create a [local project directory](https://puppet.com/docs/bolt/latest/bolt_project_directories.html#local-project-directory).

1. Create a folder in your preferred location and navigate to it.

2. Inside the new folder, create a `bolt.yaml` file and a `Puppetfile` file.

3. Edit the `Puppetfile` file to tell Bolt where to look for the module, which module to retrieve, and the version of the module:

```
mod 'puppetlabs-panos', '1.0.0'
mod 'puppetlabs-resource_api', '1.1.0'
```

> Note: If you are familiar with Puppet, notice that it uses the same format as Puppet files. Also, this module is dependent on the [Resource API](https://forge.puppet.com/puppetlabs/resource_api), hence its inclusion here also.

4. From the command line, install the module with Bolt:

`bolt puppetfile install`

Once the module has been installed, you should get the following message: 

`Successfully synced modules from $(pwd)/Puppetfile to $(pwd)/modules`

6. To verify that the module has been installed correctly, look for a `modules` folder in your Bolt working directory. Run `ls $(pwd)/modules` and you should see a folder called `panos` containing the downloaded Puppet Palo Alto module from the Forge.

7. To see a list of the tasks that Bolt can access on your local machine, run `bolt task show`. You should see 4 tasks in the Palo Alto module:

```
panos::apikey            Retrieve a PAN-OS apikey
panos::commit            Commit a candidate configuration to a firewall.
panos::set_config        upload and/or apply a configuration to a firewall.
panos::store_config      Retrieve the configuration running on the firewall.
```

# Next steps

Now that you have installed the Palo Alto module, you will configure the Palo Alto firewall in an `inventory.yaml` file.

[Update bolt Inventory](./../03-update-bolt-inventory/README.md)
