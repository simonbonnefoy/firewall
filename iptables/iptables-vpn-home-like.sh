#!/usr/bin/bash

# Firewall rules to be set while using a VPN 
# It should also take care of the DNS leak by blocking the 
# ISP's DNS server (to be set accordingly)

# ToDo: implement a kill switch...

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
#iptables -I INPUT --src 46.166.142.215,89.39.107.202 -j ACCEPT  # set here you vpn ip addresses
#iptables -I OUTPUT --dst 46.166.142.215,89.39.107.202 -j ACCEPT 

# Allow VPN traffic
iptables -A INPUT  -p udp --sport 1194 -j ACCEPT #It seems that it also works without these lines...
iptables -A OUTPUT -p udp --dport 1194 -j ACCEPT

# Allow communication through tunnel
iptables -A INPUT    -i tun+ -j ACCEPT
iptables -A OUTPUT   -o tun+ -j ACCEPT
iptables -A FORWARD  -i tun+ -j ACCEPT

# Outbout DNS lookups
iptables -A OUTPUT -o enp0s20u1 -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -i enp0s20u1 -p udp -m udp --dport 53 -j ACCEPT

# Allow inboud ssh
iptables -A INPUT -i enp0s20u1 -p tcp -m tcp --dport 22 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -o enp0s20u1 -p tcp -m tcp --dport 22 -m state --state NEW -j ACCEPT

# Accept any related or established connection
iptables -I INPUT  -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -I OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Outbound Network Time Protocol (NTP) 
iptables -A OUTPUT -o enp0s20u1 -p udp --dport 123 --sport 123 -j ACCEPT

# Outbound HTTP and HTTPS
iptables -A OUTPUT -o enp0s20u1 -p tcp -m tcp --dport 80 -m state --state NEW -j ACCEPT 
iptables -A OUTPUT -o enp0s20u1 -p tcp -m tcp --dport 443 -m state --state NEW -j ACCEPT 

# Allow outbond DCHP request
iptables -A OUTPUT -o enp0s20u1 -p udp --dport 67:68 --sport 67:68 -j ACCEPT

# Bloc connection to ISP's DNS
#iptables -I INPUT --src 103.86.99.10,60.109.121.33,62.109.121.32,ns-c-brln-04.net.telefonica.de -j DROP  # set here your ISP's DNS addresses
#iptables -I OUTPUT --dst 103.86.99.10,62.109.121.33,62.109.121.32,ns-c-brln-04.net.telefonica.de -j DROP  # set here your ISP's DNS addresses 
