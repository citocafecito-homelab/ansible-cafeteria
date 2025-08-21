#!/bin/bash
set -e

### Desactivar swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

### Paquetes base
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

### Habilitar módulos kernel
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

### Configuración sysctl
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

### Instalar containerd
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Habilitar systemd cgroups
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

### Instalar kubeadm, kubelet, kubectl
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Configuración por defecto
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Habilitar systemd cgroups (requerido por kube >=1.30 con cgroup v2)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo sed -i 's|sandbox_image = "registry.k8s.io/pause:3.8"|sandbox_image = "registry.k8s.io/pause:3.10"|' /etc/containerd/config.toml

# Recargar y arrancar servicio
sudo systemctl daemon-reexec
sudo systemctl enable --now containerd

### Inicializar cluster (solo en el master)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

### Configurar kubeconfig para el usuario actual
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

### Instalar red (Flannel)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

### Permitir pods en el nodo control-plane (opcional si solo tienes 1 nodo)
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

echo "✅ Cluster Kubernetes inicializado con kubeadm + containerd + flannel"
