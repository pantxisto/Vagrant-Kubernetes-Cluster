#!/bin/bash

apt update -y
apt install -y haproxy

routes="\
frontend kubernetes-frontend
    bind 172.42.42.100:6443
    mode tcp
    option tcplog
    tcp-request inspect-delay 2s
    default_backend kubernetes-backend

backend kubernetes-backend
    mode tcp
    option tcp-check
    balance roundrobin
    server master 172.42.42.101:6443 check fall 3 rise 2
"

echo "$routes" >> /etc/haproxy/haproxy.cfg

systemctl restart haproxy

apt install -y bird2

cat <<EOF | sudo tee /etc/bird/bird.conf
log "/var/log/bird.log" { debug, trace, info, remote, warning, error, auth, fatal, bug };
debug protocols all;

protocol device {
        scan time 10;
}

protocol direct {
        disabled;
}

protocol kernel {
        ipv4 {        
              import all;
              export all;
        };
}

template bgp kubernetes {
      local 172.42.42.100 as 64600;
      neighbor as 64600;

      ipv4 {
              import filter {accept;};
              export filter {accept;};
      };
      graceful restart on;
}

protocol bgp worker from kubernetes {
      neighbor 172.42.42.102;
}

protocol bgp master from kubernetes {
      neighbor 172.42.42.101;
}
EOF

systemctl restart bird
bird
systemctl restart bird
