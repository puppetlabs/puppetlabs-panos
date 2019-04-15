# Update bolt Inventory

Now we're going to add the Palo Alto firewall to the bolt inventory. Doing this allows us to enter the firewall details in the bolt inventory and avoids having to pass them at the command line.

1. Go to the directory which was created in [Download Puppet Palo Alto Module](./../02-download-panos-module/README.md).

2. Create a file called `inventory.yaml`.

3. Edit the file to provide details about the Palo Alto firewall you want to manage. The following details will needed: hostname or IP of the Palo Alto firewall, user name, password or api key. For this tutorial I'm using a username and password combination. By default the module performs SSL verification, this can be disabled by putting `ssl: false` in the remote section of the `inventory.yaml` file. 

For the purpose of this lab we will use the SHA256 fingerprint of the certificate for verification. In order to get the certificate's fingerprint, this can retrieved from inspecting the certificate in a browser, or Linux users can use the openssl command:

```
echo | openssl s_client -connect <hostname of IP of Palo Alto firewall>:443 |& openssl x509 -fingerprint -noout -sha256
```

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
        ssl_fingerprint: <certificate SHA256 fingerprint>
```

*Note*: The `name` will need to match the `Common Name (CN)` of the certificate of the firewall, for Puppet employees using VMPooler images the CN name may be a generated string that does not match the FQDN, it is advisable to edit the hosts file in this instance, or if this does not suit simply replace `ssl_fingerprint: <certificate SHA256 fingerprint>` with `ssl: false` which will mean that no SSL validation is performed.

Now you will be able to refer to your Palo Alto firewall via the alias in the above `inventory.yaml` file.

# Next steps

Next up is running a simple task.

[Running a Task](./../04-running-a-task/README.md)