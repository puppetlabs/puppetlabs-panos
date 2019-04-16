# Install Prerequisites

Before doing any of this you're doing to need a few things to be set up: Ruby, Puppet and a Palo Alto firewall that you can test against. Open a terminal window and follow the steps below.

1. Check if Ruby is installed by typing `ruby --version`. This will print out the version of Ruby that is installed. If it's not installed follow the instructions [here](https://rubyinstaller.org/downloads/) to install it.

2. Install the latest Puppet Agent. Follow the instructions [here](https://puppet.com/docs/puppet/6.4/install_agents.html) for your chosen operating system. You can check that it is installed correctly by typing `puppet --version` and it will print out the Puppet version number.

3. Grab a Palo Alto VM. If you are a Palo Alto customer you may have some VMs that you can run in [Virtual Box](https://www.virtualbox.org/). Alternatively, you can get a free trial on the [AWS marketplace](https://aws.amazon.com/marketplace/seller-profile?id=0ed48363-5064-4d47-b41b-a53f7c937314). If you are a Puppet employee we have licenses for VMs that you can run in Virtual Box, or you can just grab an image from vmpooler. In order for this lab to work you will need to be able to connect to the firewall from the host that you're running on. Typically you can check this by entering the Palo machine details in a browser to access the web user interface of PANOS - try typing `https://1.1.1.1` where 1.1.1.1 is the IP address of the Palo VM. This should open the web management interface of the firewall - if that works then the lab will also work.

# Next steps

OK, you're now all set to start the lab. Next up we'll install the Puppet Palo Alto module from the [Forge](https://forge.puppet.com/).

[Install the Puppet Palo Alto Module](./../02-install-panos-module/README.md)
