# SecureNetworkStackforSMEs
A Foundational secure stack designed for SMEs to provide baseline seturity when designing their network's architecture.
This is implemented across LAN, DMZ, and external segments, with features including a firewall on the gateway, OpenVPN for remote access, and an internal DNS server.
All firewall packages sit on the firewall server (Firewall folder and FirewallSetup.sh). DMTestWebServer.sh sits on the DMZ Server. DNSSetup.sh sits on the DNS server, connected to the switch. The OpenvpnServer.sh is on the VPN server, OpenVPCClient.sh on the LAN clients.

Except for the firewall, other devices within this implementation require manual IP configuration. This can be done within managing the network settings through the UI on each device orthrough setting an IP to each interface:
For example the following IPs would be used for the DMZ host setup:
sudo ip addr add 192.168.30.2/24 dev ens1
sudo ip link set dev ens1 up
sudo ip route add default via 192.168.30.1

The Lan internal client would be 192.168.10.2/24 with a default route of 192.168.10.1 and the external being 192.168.50.2/24 via 192.168.50.1.

Before running any of the scripts, they need to be executable. From both the base directory and from within the firewall folder do:
chmod +x *.sh
This has to be run seperately in the firewall folder as the master script within the home directory references it to function.

To setup any of these systems, provided you are an administrator on the system, you can run ./<filename>. If you are not logged in as an administrator but have the credentials, type sudo ./<filename>

To monitor firewall activity in real-time, from the home directory you can run:
./Firewall/7_logsLive.sh
