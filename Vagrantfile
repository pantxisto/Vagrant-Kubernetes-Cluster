Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-20.04"

  boxes = [
    { :name => "loadbalancer", :ip => "172.42.42.100", :cpus => 2, :memory => 2048 },
    { :name => "master", :ip => "172.42.42.101", :cpus => 2, :memory => 2048 },
    { :name => "worker", :ip => "172.42.42.102", :cpus => 2, :memory => 2048 },
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
      end

      if box.vm.hostname != "loadbalancer" then
        box.vm.provision "shell", path:"./install-kubernetes-dependencies.sh"
      end

      if box.vm.hostname == "master" then
        box.vm.provision "shell", path:"./exec-init-command.sh"
        box.vm.provision "shell", path:"./install-flannel-metallb-nginx.sh"
      end
      
      if box.vm.hostname == "worker" then
        box.vm.provision "shell", path:"./exec-join-command.sh"
      end
    end
  end
end
