#!/bin/bash
sudo apt update
sudo apt install -y nftables ipset iproute2 rsyslog vim
sudo systemctl enable nftables rsyslog systemd-networkd
echo "Packages installed and services enabled"

