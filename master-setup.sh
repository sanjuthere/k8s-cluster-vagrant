#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Reset the cluster if any previous setup exists
echo "Resetting any previous kubeadm setup..."
sudo kubeadm reset -f
sudo rm -rf /etc/kubernetes/*
sudo rm -rf /var/lib/etcd
sudo systemctl restart containerd
sudo systemctl restart kubelet

# Initialize the Kubernetes master node
echo "Initializing Kubernetes cluster..."
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Configure kubeconfig for the vagrant user
echo "Setting up kubeconfig for user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Wait for API server
echo "Waiting for kube-apiserver to respond..."
until kubectl get nodes &>/dev/null; do
  echo "  → Still waiting..."
  sleep 5
done

# Wait until master node is Ready
echo "Waiting for master node to be Ready..."
until kubectl get nodes | grep -q ' Ready'; do
  echo "  → Not ready yet..."
  sleep 5
done

# Deploy Calico CNI plugin
echo "Deploying Calico CNI..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# Print the join command for worker nodes
echo "Generating kubeadm join command for worker nodes:"
kubeadm token create --print-join-command
