#!/usr/bin/bash

# Firewall rules to be set while using a VPN (kill switch)

# Dropping all the current rules
iptables -F
#iptables -t nat -F
#iptables -t nat -X

# Set policy for connections
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Setting rules for local adapter
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Setting rules for local network 
iptables -A INPUT  -s 192.168.1.0/24 -j ACCEPT
iptables -A OUTPUT -s 192.168.1.0/24 -j ACCEPT

# VPN Establishment  
iptables -I INPUT --src 46.166.142.215,89.39.107.202 -j ACCEPT  # set here you vpn ip addresses
iptables -I OUTPUT --dst 46.166.142.215,89.39.107.202 -j ACCEPT 

# Allow VPN traffic
iptables -A INPUT  -p udp --sport 1194 -j ACCEPT #It seems that it also works without these lines...
iptables -A OUTPUT -p udp --dport 1194 -j ACCEPT

# Allow communication through tunnel
iptables -A INPUT    -i tun+ -j ACCEPT
iptables -A OUTPUT   -o tun+ -j ACCEPT
iptables -A FORWARD  -i tun+ -j ACCEPT
