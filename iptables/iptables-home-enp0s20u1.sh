#!/usr/bin/bash

# Firewall rule for standard use
# It has been modified to handle also VPN connection
# But be careful, this has no kill switch and is not DNS leak-proof.

# Dropping all the current rules
iptables -F

# Set policy for connections
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Setting rules for local adapter
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Accept any related or established connection
iptables -I INPUT  -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -I OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT


# Allow outbond DCHP request
iptables -A OUTPUT -o enp0s20u1 -p udp --dport 67:68 --sport 67:68 -j ACCEPT

# Allow inboud ssh
iptables -A INPUT -i enp0s20u1 -p tcp -m tcp --dport 22 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -o enp0s20u1 -p tcp -m tcp --dport 22 -m state --state NEW -j ACCEPT

# Outbout DNS lookups
iptables -A OUTPUT -o enp0s20u1 -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -i enp0s20u1 -p udp -m udp --dport 53 -j ACCEPT

# Outbound ping request
iptables -A OUTPUT -o enp0s20u1 -p icmp -j ACCEPT

# Outbound Network Time Protocol (NTP) 
iptables -A OUTPUT -o enp0s20u1 -p udp --dport 123 --sport 123 -j ACCEPT

# Outbound HTTP and HTTPS
iptables -A OUTPUT -o enp0s20u1 -p tcp -m tcp --dport 80 -m state --state NEW -j ACCEPT 
iptables -A OUTPUT -o enp0s20u1 -p tcp -m tcp --dport 443 -m state --state NEW -j ACCEPT 

# Enables port for establishing VPN
iptables -A OUTPUT -p tcp --dport 1194 -j ACCEPT                            # enable port for establishing VPN
iptables -A OUTPUT -p udp --dport 1194 -j ACCEPT
# Allow communication through tunnel
iptables -A INPUT    -i tun+ -j ACCEPT
iptables -A OUTPUT   -o tun+ -j ACCEPT
iptables -A FORWARD  -i tun+ -j ACCEPT
#iptables -A OUTPUT --out-interface tun+ -j ACCEPT

# Saving the rules
/sbin/iptables-save
