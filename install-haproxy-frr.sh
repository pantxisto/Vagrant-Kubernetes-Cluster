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

snap install frr -y

systemctl restart frr
