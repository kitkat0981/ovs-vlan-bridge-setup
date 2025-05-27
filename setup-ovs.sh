#!/bin/bash
set -e

# Delete existing bridge if exists
ovs-vsctl --if-exists del-br br0

# Create the bridge
ovs-vsctl add-br br0

# Add trunk ports
ovs-vsctl add-port br0 ens4 trunks=2201-2205
ovs-vsctl add-port br0 ens6 trunks=2201-2205

# Add access port
ovs-vsctl add-port br0 ens5 tag=2201

# Bring up interfaces
ip link set br0 up
ip link set ens4 up
ip link set ens5 up
ip link set ens6 up

# Wait briefly for bridge creation
sleep 1

# Create VLAN interface on top of br0
ip link add link br0 name br0.2201 type vlan id 2201

# Assign IP address
ip addr add 10.10.3.2/24 dev br0.2201

# Bring up the VLAN interface
ip link set br0.2201 up

# Add default route
ip route add default via 10.10.3.1

# Optional DNS
echo "nameserver 10.10.3.22" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
