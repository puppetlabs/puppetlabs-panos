# Install prerequisites

Before you begin, you need Ruby, Puppet and a Palo Alto firewall that you can test against. Open a terminal window and follow the steps below.

1. To check whether you have Ruby installed, run `ruby --version`. This command prints out the version of Ruby installed. If you do not have Ruby installed, see [Ruby installer](https://rubyinstaller.org/downloads/) for instructions.

2. Install the latest Puppet agent. See [Installing agents](https://puppet.com/docs/puppet/6.4/install_agents.html) for instructions. You can check that you have installed the agent correctly by running `puppet --version`. This command prints out the Puppet version number installed. A usefull tip is to add the Puppet install directory to your path so Puppet commands can be called without having to specify the full path:

```
export PATH=/opt/puppetlabs/bin:$PATH
```

3. Download a Palo Alto VM. If you are a Palo Alto customer, you may have VMs that you can run in [Virtual Box](https://www.virtualbox.org/). Alternatively, you can get a free trial on the [AWS marketplace](https://aws.amazon.com/marketplace/seller-profile?id=0ed48363-5064-4d47-b41b-a53f7c937314). If you are a Puppet employee, we have licenses for VMs that you can run in Virtual Box, or you can get an image from vmpooler. 

4. You need to be able to connect to the firewall from the host that you are running. You can check this by entering the Palo machine details in a browser to access the web user interface of PANOS. Type `https://1.1.1.1` where 1.1.1.1 is the IP address of the Palo VM. If the web management interface of the firewall opens, you are ready to start the lab.

# Next steps

You are now set to start the lab. Next up you will install the Puppet Palo Alto module from the [Forge](https://forge.puppet.com/).

[Install the Puppet Palo Alto Module](./../02-install-panos-module/README.md)
