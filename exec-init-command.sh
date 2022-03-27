kubeadm init --control-plane-endpoint="172.42.42.100:6443" --upload-certs --apiserver-advertise-address=172.42.42.101 --pod-network-cidr=10.244.0.0/16

kubeadm token create --print-join-command | tee /vagrant/join_command.sh

chmod +x /vagrant/join_command.sh

cp /etc/kubernetes/admin.conf /vagrant/.
