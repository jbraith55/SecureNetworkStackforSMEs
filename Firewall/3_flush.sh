#!/bin/bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sudo nft flush ruleset
for i in $(ls /sys/class/net) ; do sudo ip addr flush dev $i ; done
echo "~ IP Forw enabled, existing nftables flushed"

