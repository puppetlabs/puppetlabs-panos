# Configure Puppet Device

Puppet device is Puppet's current agentless catalog execution service. It executes a catalog on an agent node, and applies the catalog via a module to a remote and agentless device. This approach has typically been used by Puppet module developers for agentless device management over the years, for a history lesson see the date stamp on the [manual page](https://puppet.com/docs/puppet/6.4/man/device.html)! Note that Puppet is in the process of upgrading our agentless capabilities, using both [bolt](https://puppet.com/products/bolt) and another agentless construct (ACE) that we're releasing later in 2019.

1. Firstly, we need to find the location of a file entitled `device.conf` as it contains a pointer to the device specific configuration files. On your work station type `puppet config print deviceconfig`. This will return the location of the file, on my CentOS VM it's located here: `/etc/puppetlabs/puppet/device.conf`

2. Check if the file and if there's anything already in it. View the file referred to above, this can be done by typing: `cat /etc/puppetlabs/puppet/device.conf`. If the file exists the contents will be displayed on screen, if it doesn't exist then you'll get a message stating that `No such file or directory exists`.

3. We need to enter valid details into this file. The file needs to contain an alias, type and url to a credentials file. To make this easy, enter the following details into the device.conf file.
```
[firewall.example.com]
type panos
url file:////etc/puppetlabs/puppet/devices/firewall.example.com.conf
```

4. OK, so now you've told Puppet that there's a device to be managed by `puppet device`. Now we need to enter credentials in the configuration file referenced by the above. Do this by entering the following details in the file `/etc/puppetlabs/puppet/devices/firewall.example.com.conf`. The host should be the IP address of the Palo Alto firewall you want to manage.

By default the module performs SSL verification, this can be disabled by putting `ssl: false` in the `/etc/puppetlabs/puppet/devices/firewall.example.com.conf` file. 

For the purpose of this lab we will use the SHA256 fingerprint of the certificate for verification. In order to get the certificate's fingerprint, this can retrieved from inspecting the certificate in a browser, or *nix users can use the openssl command:

```
echo | openssl s_client -connect <hostname of IP of Palo Alto firewall>:443 |& openssl x509 -fingerprint -noout -sha256
```

```
host: 192.168.99.101
user: admin
password: admin
ssl_fingerprint: <certificate SHA256 fingerprint>
```

*Note*: The `host` will need to match the `Common Name (CN)` of the certificate of the firewall, for Puppet employees using VMPooler images the CN name may be a generated string that does not match the FQDN, it is advisable to edit the `/etc/hosts` file in this instance, or if this does not suit simply replace `ssl_fingerprint: <certificate SHA256 fingerprint>` with `ssl: false` which will mean that no SSL validation is performed.

# Next steps

OK, next up we're going to do the final step before interacting with the device, by signing the certificate.

[Sign the Certificate](./../04-sign-the-cert/README.md)
