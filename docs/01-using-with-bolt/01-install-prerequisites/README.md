# Install Prerequisites

Before you begin, you need a Ruby, Bolt and a Palo Alto firewall that you can test against. Open a terminal window and follow the steps below.

1. Install the latest version of Bolt. See [Installing Bolt
](https://puppet.com/docs/bolt/latest/bolt_installing.html) for instuctions. To check that Bolt has been installed, run `bolt --version`, which shows you the Bolt version number.

2. Download a Palo Alto VM. If you are a Palo Alto customer, you may have VMs that you can run in [Virtual Box](https://www.virtualbox.org/). Alternatively, you can get a free trial on the [AWS marketplace](https://aws.amazon.com/marketplace/seller-profile?id=0ed48363-5064-4d47-b41b-a53f7c937314). If you are a Puppet employee, we have licenses for VMs that you can run in Virtual Box, or you can get an image from vmpooler. 

3. You need to be able to connect to the firewall from the host that you are running. You can check this by entering the Palo machine details in a browser to access the web user interface of PANOS. Type `https://1.1.1.1` where 1.1.1.1 is the IP address of the Palo VM. If the web management interface of the firewall opens, you are ready to start the lab.

# Next steps

You are now set to start the lab. Next up we will use Bolt to download the Puppet Palo Alto module.

[Download Puppet Palo Alto Module](./../02-download-panos-module/README.md)
