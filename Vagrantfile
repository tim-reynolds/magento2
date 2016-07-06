# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

  # Enter Your Github API Token Below. 
  # If not entered, you must manually run composer to finish the installation.
  # See http://devdocs.magento.com/guides/v1.0/install-gde/trouble/tshoot_rate-limit.html
  
  githubToken = ""
  if File.file?("github.key")
        file = File.open("github.key", "rb")
        githubToken = file.read
        file.close
  else
        print "We need a GitHub Access Token to continue."
        print "Magento 2 Uses a great deal of 3rd party packages that are installed using Composer"
        print "However, GitHub rate-limits access from anonymous parties. Because of this you must have a GitHub account"
        print "to install all packages through Composer. Please see the following for instructions:"
        print "http://devdocs.magento.com/guides/v2.0/install-gde/trouble/git/tshoot_rate-limit.html"
        print "You should note, you don't need to specify any permissions"
        print "GitHub Key: "
        githubToken = STDIN.gets.chomp
        File.open("github.key", "w") { |file| file.write(githubToken); file.close}
  end
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.
  
  # box name.  Any box from vagrant share or a box from a custom URL. 
  config.vm.box = "ubuntu/trusty64"
  
  # box modifications, including memory limits and box name. 
  config.vm.provider "virtualbox" do |vb|
     vb.name = "Magento2 Vagrant"
     vb.memory = 4096
	 vb.cpus = 2
  end

  ## IP to access box
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.synced_folder ".", "/vagrant", nfs:false, :mount_options => ["dmode=777","fmode=666"]
  ## Bootstrap script to provision box.  All installation methods can go here.
  config.vm.provision "shell" do |s|
    s.path = "vagrant/bootstrap.sh"
    s.args   = [githubToken]
  end
  

  config.vm.post_up_message =  "YOUR MAGENTO 2 SITE IS UP AN RUNNING.
  You just need to add the following entry to your host file:
  192.168.33.10 dev.magento2.com
  And you need to setup file syncing in PHPStorm
  You will need to sync whatever directory you are doing your work in to
  /var/www/html/magento2
  After you have done those things you can access your site at:
  http://dev.magento2.com/
  You can also access MailCatcher at:
  http://dev.magento2.com:1080/
  You can also access PHPMyAdmin at:
  http://dev.magento2.com/phpmyadmin/
  The Magento Admin Account is: admin/passw0rd
  The PHPMyAdmin Account is: root/root

  "
end
