#!/bin/sh
# Load ip_gre
sudo modprobe ip_gre
lsmod | grep gre

# Create the tunnel
sudo ip tunnel add bgptunnel mode gre key 0xfffffffe ttl 255 

# Uncomment (for BGP and Zebra)
sudo sed -i "/net.ipv4.ip_forward=1/s/^#//" /etc/sysctl.conf

sudo sysctl --system