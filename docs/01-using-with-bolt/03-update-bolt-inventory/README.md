# Update bolt Inventory

Now we're going to add the Palo Alto firewall to the bolt inventory. Doing this allows us to enter the firewall details in the bolt inventory and avoids having to pass them at the command line.

1. Go to your bolt working directory. This is `$HOME/.puppetlabs/bolt`.

2. Create a file called `inventory.yaml`.

3. Edit the file to provide details about the Palo Alto firewall you want to manage. The following details will needed: hostname or IP of the Palo Alto firewall, user name, password or api key. For this tutorial I'm using a username and password combination. I've also chosen to set SSL to false. By default this is set to true meaning that the SSL certificate needs to be verified before you can connect to the firewall - I've set this to false for this demo.
```
nodes:
  - name: <hostname or IP of your Palo Alto firewall>
    alias: pan
    config:
      transport: remote
      remote:
        remote-transport: panos
        user: <username to access your Palo Alto VM>
        password: <password for the above username>
        ssl: false
```

Now you will be able to refer to your Palo Alto firewall via the alias in the above `inventory.yaml` file.

# Next steps

Next up is running a simple task.

[Running a Task](./../04-running-a-task/README.md)