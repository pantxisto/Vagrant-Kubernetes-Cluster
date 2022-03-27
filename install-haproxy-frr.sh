#!/bin/bash

apt update -y
apt install -y haproxy

cat <<EOF | sudo tee -a /etc/haproxy/haproxy.cfg
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

frontend web-frontend
    bind 172.42.42.100:80
    mode tcp
    option tcplog
    tcp-request inspect-delay 2s
    default_backend web-backend

backend web-backend
    mode tcp
    option tcp-check
    balance roundrobin
    server loadbalancer 128.28.28.1:80 check fall 3 rise 2
EOF

systemctl restart haproxy


# Install FRR routing daemon
# add GPG key
curl -s https://deb.frrouting.org/frr/keys.asc | sudo apt-key add -

# possible values for FRRVER: frr-6 frr-7 frr-8 frr-stable
# frr-stable will be the latest official stable release
FRRVER="frr-stable"
echo deb https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list

# update and install FRR
apt update
apt install -y frr frr-pythontools
#NOTE: To revert to FRR version 8.1 or 8.0, please replace frr with frr8.0 or frr8.1 in the sources url above.
#For example to revert to FRR 8.1, use: deb.frrouting.org/frr8.1

# Configure to launch bgp on reboot
# /etc/frr/daemons
sed -i "s/bgpd=no/bgpd=yes/" /etc/frr/daemons

# Add static and bgp configuration
# One static route per worker node

# /etc/frr/frr.conf
cat <<EOF | sudo tee -a /etc/frr/frr.conf  
ip route 128.28.28.1/32 172.42.42.102
ip route 128.28.28.1/32 172.42.42.103

bfd
  profile full1
    receive-interval 179
    transmit-interval 150
    echo receive-interval 62
    echo transmit-interval 62
    minimum-ttl 254
  peer 172.42.42.101
    profile full1
    no shutdown
  peer 172.42.42.102
    profile full1
    no shutdown
  peer 172.42.42.103
    profile full1
    no shutdown

router bgp 64600
  bgp router-id 172.42.42.100
  neighbor 172.42.42.101 remote-as 64600
  neighbor 172.42.42.101 bfd
  neighbor 172.42.42.102 remote-as 64600
  neighbor 172.42.42.102 bfd
  neighbor 172.42.42.103 remote-as 64600
  neighbor 172.42.42.103 bfd
EOF

systemctl daemon-reload
systemctl restart frr