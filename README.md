[Vagrant](http://www.vagrantup.com) provider for [VMware vCloud Air®](http://vcloud.vmware.com)
=============

[Version 0.5.0](../../releases/tag/v0.5.0) has been released!
-------------

We have a wide array of boxes available at [Vagrant Cloud](https://vagrantcloud.com/gosddc) you can use them directly or you can roll your own as you please, make sure to install VMware tools in it.

This plugin supports the universal [```vmware_ovf``` box format](https://github.com/gosddc/packer-post-processor-vagrant-vmware-ovf/wiki/vmware_ovf-Box-Format), that is 100% portable between [vagrant-vcloud](https://github.com/frapposelli/vagrant-vcloud), [vagrant-vcenter](https://github.com/gosddc/vagrant-vcenter) and [vagrant-vcloudair](https://github.com/gosddc/vagrant-vcloudair), no more double boxes!.

If you're unsure about what are the correct network settings for your Vagrantfile make sure to check out the [Network Deployment Options](https://github.com/gosddc/vagrant-vcloudair/wiki/Network-Deployment-Options) wiki page.

Check the full releases changelog [here](../../releases)

Install
-------------

Latest version can be easily installed by running the following command:

```vagrant plugin install vagrant-vcloudair```

Vagrant will download all the required gems during the installation process.

After the install has completed a ```vagrant up --provider=vcloudair``` will trigger the newly installed provider.

Upgrade
-------------

If you already have vagrant-vcloudair installed you can update to the latest version available by issuing:

```vagrant plugin update vagrant-vcloudair```

Vagrant will take care of the upgrade process.

Configuration
-------------

Here's a sample Vagrantfile that builds a docker host on vCloud Air and starts a Wordpress container on port 80, make sure you replace the placeholders with your own values.

```ruby
# Set our default provider for this Vagrantfile to 'vcloudair'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'vcloudair'

nodes = [
  { hostname: 'vagrant-test1', box: 'gosddc/trusty64' },
]

Vagrant.configure('2') do |config|

  # vCloud Air provider settings
  config.vm.provider :vcloudair do |vcloudair|

    vcloudair.username = '<username@domain>'
    vcloudair.password = '<password>'

    # if you're using a vCloud Air Dedicated Cloud, put the cloud id here, if
    # you're using a Virtual Private Cloud, skip this parameter.
    vcloudair.cloud_id = '<dedicated cloud id>'
    vcloudair.vdc_name = '<vdc name>'

    # Set the network to deploy our VM on
    vcloudair.vdc_network_name = '<vdc network name>'

    # Set our Edge Gateway and the public IP we're going to use.
    vcloudair.vdc_edge_gateway = '<vdc edge gateway>'
    vcloudair.vdc_edge_gateway_ip = '<vdc edge gateway public ip>'

    # Catalog that holds our templates.
    vcloudair.catalog_name = 'Vagrant'

    # Set our Memory and CPU to a sensible value for Docker.
    vcloudair.memory = 2048
    vcloudair.cpus = 2
  end

  # Go through nodes and configure each of them.
  nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|
    	# Set the box we're using
      node_config.vm.box = node[:box]
      # Set the hostname for the box
      node_config.vm.hostname = node[:hostname]
      # Fix a customization problem on Ubuntu and vCloud Air.
      node_config.vm.provision 'shell', inline: 'echo "nameserver 8.8.8.8" >> tmp; sudo mv tmp /etc/resolvconf/resolv.conf.d/base; sudo resolvconf -u'
      # Fetch and run Docker and the 'tutum/wordpress' container.
      node_config.vm.provision 'docker' do |d|
        d.run 'tutum/wordpress', cmd: '/run.sh', args: '-p 80:80'
      end
      # Declare NFS non functional as our plugin doesn't provide for it.
      node_config.nfs.functional = false
    end
  end

end
```

For additional documentation on different network setups with vCloud Director, check the [Network Deployment Options](../../wiki/Network-Deployment-Options) Wiki page

Contribute
-------------

What is still missing:

- TEST SUITES! (working on that).
- Permission checks, make sure you have at least Catalog Admin privileges if you want to upload boxes to vCloud.
- Some spaghetti code here and there.

If you're a developer and want to lend us a hand, head over to our ```develop``` branch and send us PRs!

