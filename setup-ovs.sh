#!/bin/bash
set -e

# Remove existing bridge if it exists
ovs-vsctl --if-exists del-br br0

# Create OVS bridge
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
