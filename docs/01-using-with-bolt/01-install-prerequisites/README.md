# Install Prerequisites

Before doing any of this you're doing to need a few things to be set up: Ruby, Bolt and a Palo Alto firewall that you can test against. Open a terminal window and follow the steps below.

1. Install the latest version of bolt. Follow the instructions [here](https://puppet.com/docs/bolt/latest/bolt_installing.html) for your chosen operating system. You check that it installed correctly by typing `bolt --version` and it will print out the bolt version number.

1. Grab a Palo Alto VM. If you are a Palo Alto customer you may have some VMs that you can run in [Virtual Box](https://www.virtualbox.org/). Alternatively, you can get a free trial on the [AWS marketplace](https://aws.amazon.com/marketplace/seller-profile?id=0ed48363-5064-4d47-b41b-a53f7c937314). If you are a Puppet employee we have licenses for VMs that you can run in Virtual Box, or you can just grab an image from vmpooler. In order for this lab to work you will need to be able to connect to the firewall from the host that you're running on. Typically you can check this by entering the Palo machine details in a browser to access the web user interface of PANOS - try typing `https://1.1.1.1` where 1.1.1.1 is the IP address of the Palo VM. This should open the web management interface of the firewall - if that works then the lab will also work.

# Next steps

OK, you're now all set to start the lab. Next up we'll use bolt to download the Puppet Palo Alto module

[Download Puppet Palo Alto Module](./../02-download-panos-module/README.md)