# Configure Puppet device

Puppet device is Puppet's agentless catalog execution service. It executes a catalog on an agent node, and applies the catalog via a module to a remote and agentless device. This approach is used by Puppet module developers for agentless device management. For more information on its history at Puppet, see the [manual page](https://puppet.com/docs/puppet/6.4/man/device.html). Note that we are in the process of upgrading our agentless capabilities, using both [Bolt](https://puppet.com/products/bolt) and Agentless Catalog Executor(ACE) that we will release later in 2019.

1. Firstly, you need to find the location of a file called `device.conf`, which contains a information about device specific configuration files. Run `puppet config print deviceconfig` to find the location of the `device.conf` file, this will look similar to `/etc/puppetlabs/puppet/device.conf`

2. Check whether there is anything already in the `device.conf` file. To view the `device.conf` file, referred run `cat /etc/puppetlabs/puppet/device.conf`. If the file exists, you will see the contents displayed. If it does not exist, you will get a message stating that `No such file or directory exists`.

3. The `device.conf` file needs to contain an alias, type and url to a credentials file:

```
[firewall.example.com]
type panos
url file:////etc/puppetlabs/puppet/devices/firewall.example.com.conf
```

4. You have told Puppet that there is a device for `puppet device` to manage. Now you need to enter credentials in the configuration file referenced above. Enter the following details inside the `/etc/puppetlabs/puppet/devices/firewall.example.com.conf` file:

```
host: 192.168.99.101
user: admin
password: admin
ssl_fingerprint: <certificate SHA256 fingerprint>
```

The host is the IP address of the Palo Alto firewall you want to manage.

By default, the module performs SSL verification. To disable this, replace `ssl_fingerprint: <certificate SHA256 fingerprint>` with `ssl: false` in `/etc/puppetlabs/puppet/devices/firewall.example.com.conf`

In this lab, we use the SHA256 fingerprint of the certificate for verification. To get the certificate's fingerprint, see the certificate in a browser, or for Linux users, use the `openssl` command:

```
echo | openssl s_client -connect <hostname of IP of Palo Alto firewall>:443 2>&1 | openssl x509 -fingerprint -noout -sha256
```


> Note: The `host` needs to match the `Common Name (CN)` of the certificate of the firewall. For Puppet employees using VMPooler images, the CN name may be a generated string that does not match the FQDN. We advise you to edit the hosts file in this instance, or to replace `ssl_fingerprint: <certificate SHA256 fingerprint>` with `ssl: false` so that it does not perform SSL validation.

# Next steps

Before you can start interacting with the device, you need to sign the certificates.

[Sign the Certificate](./../04-sign-the-cert/README.md)
