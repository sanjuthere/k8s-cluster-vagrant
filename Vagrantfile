$install_common_tools = <<-SCRIPT
# Enable bridge traffic for iptables
cat >> /etc/ufw/sysctl.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
EOF

modprobe br_netfilter
sysctl --system

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf
sysctl -w net.ipv4.ip_forward=1
sysctl -p

# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Install containerd
sudo apt update
sudo apt install -y containerd

# Generate default config and restart
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Install Kubernetes tools
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

apt-get update -qq
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
SCRIPT

$provision_master_node = <<-SCRIPT
OUTPUT_FILE=/vagrant/join.sh
rm -f $OUTPUT_FILE

# Ensure kubelet service directory exists
mkdir -p /etc/systemd/system/kubelet.service.d

# Initialize Kubernetes with containerd
kubeadm init --apiserver-advertise-address=10.0.0.10 --pod-network-cidr=10.244.0.0/16 | grep "kubeadm join" > $OUTPUT_FILE
chmod +x $OUTPUT_FILE

# Configure kubectl for vagrant user
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

# Set node IP in kubelet config
echo 'Environment="KUBELET_EXTRA_ARGS=--node-ip=10.0.0.10"' | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart kubelet

# Install Flannel CNI
su - vagrant -c "kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"
SCRIPT

$install_multicast = <<-SCRIPT
apt-get install -y avahi-daemon libnss-mdns
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vb|
    vb.memory = 6144
    vb.cpus = 2
  end

  config.vm.provision :shell, privileged: true, inline: $install_common_tools

  config.vm.define "master" do |master|
    master.vm.box = "./focal-server-cloudimg-amd64-vagrant.box"
    master.vm.hostname = "master"
    master.vm.network :private_network, ip: "10.0.0.10"
    master.vm.provision :shell, privileged: true, inline: $provision_master_node
  end

  ["worker1", "worker2"].each_with_index do |name, i|
    ip = "10.0.0.#{i + 11}"
    config.vm.define name do |worker|
      worker.vm.box = "./focal-server-cloudimg-amd64-vagrant.box"
      worker.vm.hostname = name
      worker.vm.network :private_network, ip: ip
      worker.vm.provision :shell, privileged: true, inline: <<-SCRIPT
        bash /vagrant/join.sh
        mkdir -p /etc/systemd/system/kubelet.service.d
        echo 'Environment="KUBELET_EXTRA_ARGS=--node-ip=#{ip}"' | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
        systemctl daemon-reexec
        systemctl daemon-reload
        systemctl restart kubelet
      SCRIPT
    end
  end

  config.vm.provision :shell, privileged: true, inline: $install_multicast
end
