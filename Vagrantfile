# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "puphpet/ubuntu1604-x64"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  # config.vm.synced_folder "~/.gnupg", "/home/vagrant/.gnupg"
  config.vm.synced_folder ".", "/home/vagrant/project"

  # Enable provisioning with a shell script.
  config.vm.provision "file", source: "~/.gnupg", destination: ".gnupg"
  config.vm.provision "shell", inline: <<-SHELL
     apt-get update
     apt-get install -y reprepro
  SHELL
end


