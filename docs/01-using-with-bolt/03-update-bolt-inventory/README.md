# Update the Bolt inventory file

Add the Palo Alto firewall details to the Bolt inventory file.

1. Navigate to the directory you created in [Download Puppet Palo Alto Module](./../02-download-panos-module/README.md).

2. Create a file called `inventory.yaml`.

3. Edit the `inventory.yaml` file to provide details of the Palo Alto firewall you want to manage, including the hostname or IP of the Palo Alto firewall, username, password or api key: 

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

The `name` needs to match the `Common Name (CN)` of the certificate of the firewall. In this example, we are using the username and password for authenticating with the device. 

By default, the module performs SSL verification. To disable this, put `ssl: false` in the remote section of the `inventory.yaml` file. 

In this lab, we use the SHA256 fingerprint of the certificate for verification. To get the certificate's fingerprint, see the certificate in a browser, or for Linux users, use the `openssl` command.

In zsh:
```
echo | openssl s_client -connect <hostname of IP of Palo Alto firewall>:443 |& openssl x509 -fingerprint -noout -sha256
```
Or in bash:
```
echo | openssl s_client -connect <hostname of IP of Palo Alto firewall>:443 | openssl x509 -fingerprint -noout -sha256
```

> Note: For Puppet employees using VMPooler images, the CN name may be a generated string that does not match the FQDN. We advise you to edit the hosts file in this instance, or to replace `ssl_fingerprint: <certificate SHA256 fingerprint>` with `ssl: false` so that it does not perform SSL validation.

Now you can refer to your Palo Alto firewall with the alias in the above `inventory.yaml` file.

# Next steps

Next, you will run a task.

[Running a Task](./../04-running-a-task/README.md)
