#!/bin/sh
# Create the tunnel
sudo ip addr add 10.0.0.3/24 dev bgptunnel
sudo ip link set bgptunnel up

# Connect with the other side of the tunnel
sudo ip neigh add 10.0.0.1 lladdr 172.42.42.100 dev bgptunnel