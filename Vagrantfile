Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-20.04"

  boxes = [
    { :name => "loadbalancer", :ip => "172.42.42.100", :cpus => 2, :memory => 2048 },
    { :name => "master", :ip => "172.42.42.101", :cpus => 2, :memory => 2048 },
    { :name => "worker1", :ip => "172.42.42.102", :cpus => 2, :memory => 2048 },
    { :name => "worker2", :ip => "172.42.42.103", :cpus => 2, :memory => 2048 },
  ]  

  boxes.each do |opts|
    config.vm.define opts[:name] do |box|
      box.vm.hostname = opts[:name]
      box.vm.network :private_network, ip: opts[:ip]
 
      box.vm.provider "virtualbox" do |vb|
        vb.cpus = opts[:cpus]
        vb.memory = opts[:memory]
        vb.name = opts[:name]
      end  

      if box.vm.hostname == "loadbalancer" then
        box.vm.provision "shell", path:"./install-haproxy-frr.sh"
        box.vm.provision "shell", path:"./gre_tunnel_global.sh"
        box.vm.provision "shell", path:"./gre_tunnel_router.sh"
      end

      if box.vm.hostname != "loadbalancer" then
        box.vm.provision "shell", path:"./install-kubernetes-dependencies.sh"
      end

      if box.vm.hostname == "master" then
        $script = "cat << EOF | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
Environment='KUBELET_EXTRA_ARGS=--node-ip=$1'
EOF
systemctl daemon-reload
systemctl restart kubelet

"
        box.vm.provision "shell" do |s|
          s.inline = $script
          s.args   = [opts[:ip]]
        end
        box.vm.provision "shell", path:"./exec-init-command.sh"
        box.vm.provision "shell", path:"./install-flannel-metallb-nginx.sh"
        box.vm.provision "shell", path:"./gre_tunnel_global.sh"
        box.vm.provision "shell", path:"./gre_tunnel_master.sh"
      end
      
      if box.vm.hostname == "worker1" then
        $script = "cat << EOF | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
Environment='KUBELET_EXTRA_ARGS=--node-ip=$1'
EOF
systemctl daemon-reload
systemctl restart kubelet

"
        box.vm.provision "shell" do |s|
          s.inline = $script
          s.args   = [opts[:ip]]
        end
        box.vm.provision "shell", path:"./exec-join-command.sh"
        box.vm.provision "shell", path:"./gre_tunnel_global.sh"
        box.vm.provision "shell", path:"./gre_tunnel_worker1.sh"
      end

      if box.vm.hostname == "worker2" then
        $script = "cat << EOF | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
Environment='KUBELET_EXTRA_ARGS=--node-ip=$1'
EOF
systemctl daemon-reload
systemctl restart kubelet
"
        box.vm.provision "shell" do |s|
          s.inline = $script
          s.args   = [opts[:ip]]
        end
        box.vm.provision "shell", path:"./exec-join-command.sh"
        box.vm.provision "shell", path:"./delete-join-command.sh"
        box.vm.provision "shell", path:"./gre_tunnel_global.sh"
        box.vm.provision "shell", path:"./gre_tunnel_worker2.sh"
      end
    end
  end
end
