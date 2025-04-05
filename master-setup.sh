#!/bin/bash

# Initialize the cluster
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Set up local kubeconfig for regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Wait for kube-apiserver to become available
until kubectl get nodes &>/dev/null; do
  echo "Waiting for API server to respond..."
  sleep 5
done

# Wait until the master node is in Ready status
until kubectl get nodes | grep -q 'Ready'; do
  echo "Waiting for master node to become Ready..."
  sleep 5
done

# Deploy Calico network plugin
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# Display the join command
kubeadm token create --print-join-command
