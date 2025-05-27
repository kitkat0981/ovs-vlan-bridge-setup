#!/bin/bash

set -euo pipefail

LOG_FILE="/var/log/setup-ovs.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Starting Open vSwitch Setup ==="

# Interfaces
BRIDGE="br0"
TRUNK_PORTS=("ens4" "ens6")
ACCESS_PORT="ens5"
ACCESS_VLAN=2201

# Clean up existing bridge
echo "Deleting bridge $BRIDGE if it exists..."
ovs-vsctl --if-exists del-br "$BRIDGE"

# Create bridge
echo "Creating bridge $BRIDGE..."
ovs-vsctl add-br "$BRIDGE"

# Add trunk ports
for PORT in "${TRUNK_PORTS[@]}"; do
    echo "Adding trunk port $PORT to $BRIDGE..."
    ovs-vsctl add-port "$BRIDGE" "$PORT" trunks=2201-2205
    echo "Bringing up interface $PORT..."
    ip link set "$PORT" up
done

# Add access port
echo "Adding access port $ACCESS_PORT to $BRIDGE with VLAN $ACCESS_VLAN..."
ovs-vsctl add-port "$BRIDGE" "$ACCESS_PORT" tag=$ACCESS_VLAN
echo "Bringing up interface $ACCESS_PORT..."
ip link set "$ACCESS_PORT" up

# Bring up the bridge itself
echo "Bringing up bridge interface $BRIDGE..."
ip link set "$BRIDGE" up

echo "=== OVS Bridge Setup Complete ==="
ovs-vsctl show
