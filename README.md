# Vagrant-Kubernetes-Cluster

Kubernetes Cluster with Metallb (BGP) and bird. (Not working - Bird routes stay unreachable)

- git clone https://github.com/pantxisto/Vagrant-Kubernetes-Cluster.git
- cd Vagrant-Kubernetes-Cluster
- vagrant up
- vagrant ssh loadbalancer // loadbalancer is the control plane node
- birdc show route // This will show the error ... unreachable ...
