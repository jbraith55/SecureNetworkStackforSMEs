#!/bin/bash
#Removed some of the deny-based logic as it is done by default

IP_LAN="192.168.10.1/24"
IP_DMZ="192.168.30.1/24"
IP_EXTERNAL="192.168.50.1/24"
INT_WAN="ens3"
INT_LAN="ens4"
INT_DMZ="ens5"
INT_EXTERNAL="ens6"

ALLOW_LAN="192.168.10.2/32"
ALLOW_LAN2="192.168.40.0/24"
#ALLOW_BRIDGE="192.168.20.0/24"
ALLOW_DMZ="192.168.30.2/32"
ALLOW_EXTERNAL="192.168.50.2/32"
#DENY_ATTACKER="203.0.113.3/32"

RATE_22="10/second"
RATE_80="20/second"
RATE_443="15/second"
RATE_21="5/second"
RATE_DNS="50/second"
RATE_ICMP="5/second"

sudo systemctl start systemd-networkd

sudo sysctl -w net.ipv4.ip_forward=1

sudo cat <<EOF > /etc/netplan/01-network-manager-all.yaml
network:
 version: 2
 renderer: NetworkManager
 ethernets:
  $INT_WAN:
   dhcp4: yes
  $INT_LAN:
   addresses: [$IP_LAN]
   routes:
    - to: $ALLOW_LAN2
  $INT_DMZ:
   addresses: [$IP_DMZ]
  $INT_EXTERNAL:
   addresses: [$IP_EXTERNAL]
EOF

sudo netplan apply	

sudo cat <<EOF > /etc/nftables.conf
table ip firenat {
    chain POSTROUTING {
        type nat hook postrouting priority 100;
        oifname "$INT_WAN" masquerade
    }
}

table inet filter {
    set ALLOW_L {
        type ipv4_addr;
        flags interval;
        elements = { $ALLOW_LAN, $ALLOW_DMZ, $ALLOW_EXTERNAL, $ALLOW_LAN2 }
    }

#    set DENY_L {
#        type ipv4_addr;
#        flags interval;
#        elements = {$DENY_ATTACKER }
#    }

    chain INPUT {
        type filter hook input priority 0; policy drop;

        iif "lo" accept
        ct state established,related accept
        ct state invalid drop

#       ip saddr @DENY_L drop

        ip saddr @ALLOW_L accept

        log prefix "FW_INPUT_DROP " counter
        drop
    }

    chain FORWARD {
        type filter hook forward priority 0; policy drop;

        ct state established,related accept
        ct state invalid drop
	
	ip saddr $ALLOW_EXTERNAL ip daddr $ALLOW_DMZ udp dport 1194 accept

        iif "$INT_LAN" oif "$INT_WAN" accept
        iif "$INT_DMZ" oif "$INT_WAN" accept
	iif "$INT_DMZ" oif "$INT_EXTERNAL" accept
	iif "$INT_WAN" oif "$INT_DMZ" accept

        tcp flags syn tcp dport 22 ct state new limit rate $RATE_22 counter accept
        tcp flags syn tcp dport 80 ct state new limit rate $RATE_80 counter accept
        tcp flags syn tcp dport 443 ct state new limit rate $RATE_443 counter accept
        tcp flags syn tcp dport 21 ct state new limit rate $RATE_21 counter accept

        iif "$INT_LAN" oif "$INT_DMZ" ip protocol icmp limit rate $RATE_ICMP accept
        iif "$INT_DMZ" oif "$INT_LAN" ip protocol icmp limit rate $RATE_ICMP accept

        udp dport 53 ct state new limit rate $RATE_DNS accept
        tcp dport 53 ct state new limit rate $RATE_DNS accept

        tcp flags syn ct state new log prefix "SYN_SCAN_DROP " counter

#       ip saddr @DENY_L drop 

        log prefix "FW_FORWARD_DROP " counter
        drop
    }

    chain OUTPUT {
        type filter hook output priority 0; policy accept;
    }
}
EOF

sudo systemctl restart nftables

echo "~ Firewall setup complete with LAN IP $IP_LAN"
