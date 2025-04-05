#!/bin/bash

# Initialize the cluster
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Set up local kubeconfig for regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy Calico network plugin (or you can use Flannel)
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# Display the join command
kubeadm token create --print-join-command
