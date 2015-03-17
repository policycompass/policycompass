# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

PROVISION_ROOT = <<eof
   set -e
   make -C /home/vagrant/adhocracy3 install_deps
eof

PROVISION_USER = <<eof
eof

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "trusty_64"
  config.vm.box_url = "https://vagrantcloud.com/ubuntu/boxes/trusty64/versions/14.04/providers/virtualbox.box"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  # NOTE: Disk I/O is really slow in shared folders! This is a serious blocker
  # for development within a VirtualBox.
  #
  # Alternatives to shared folders:
  # - Use development tools like editor, git etc. inside the VM
  # - Use NFS, much faster - https://i.imgur.com/BoEBc1X.png - but possibly
  #   other problems.
  #
  config.vm.synced_folder ".", "/home/vagrant/policycompass"

  config.vm.network :forwarded_port, guest: 6541, host: 6541
  config.vm.network :forwarded_port, guest: 6551, host: 6551
  config.vm.network :forwarded_port, guest: 8080, host: 8080

  config.vm.provision :shell, inline: PROVISION_ROOT
  config.vm.provision :shell, inline: PROVISION_USER, :privileged => false

  # Optional settings

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network :private_network, ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network
end
