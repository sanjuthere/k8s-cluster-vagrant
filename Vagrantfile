# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu2204-generic-LTS-image"

  # Master Node
  config.vm.define "k8s-master" do |master|
    master.vm.hostname = "k8s-master"
    master.vm.network "private_network", ip: "192.168.56.100"

    # Run common setup first, then master-specific setup
    #master.vm.provision "shell", path: "./master-worker.sh"
    #master.vm.provision "shell", path: "./master-setup.sh"

    master.vm.provider "virtualbox" do |vm|
      vm.name = "k8s-master"
      vm.memory = 4096
      vm.cpus = 2
    end
  end

  # Worker Node 1
  config.vm.define "k8s-worker1" do |worker1|
    worker1.vm.hostname = "k8s-worker1"
    worker1.vm.network "private_network", ip: "192.168.56.101"

    #worker1.vm.provision "shell", path: "./master-worker.sh"
    #worker1.vm.provision "shell", path: "./worker-setup.sh", run: "always"

    worker1.vm.provider "virtualbox" do |vm|
      vm.name = "k8s-worker1"
      vm.memory = 4096
      vm.cpus = 2
    end
  end

  # Worker Node 2
  config.vm.define "k8s-worker2" do |worker2|
    worker2.vm.hostname = "k8s-worker2"
    worker2.vm.network "private_network", ip: "192.168.56.102"

    #worker2.vm.provision "shell", path: "./master-worker.sh"
    #worker2.vm.provision "shell", path: "./worker-setup.sh", run: "always"

    worker2.vm.provider "virtualbox" do |vm|
      vm.name = "k8s-worker2"
      vm.memory = 4096
      vm.cpus = 2
    end
  end
end
