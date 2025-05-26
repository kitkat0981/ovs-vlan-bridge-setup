# Open vSwitch VLAN Bridge Setup

This repository contains scripts and configuration files to set up an Open vSwitch (OVS) bridge for a host with VLAN trunking and access ports.

## Topology

- `ens4` and `ens6`: Trunk ports carrying VLANs 2201–2205
- `ens5`: Access port on VLAN 2201, used for management (IP: `10.10.3.2/24`)

- The diagram:

![diagram](images/diagram.png)

## Files

- `setup-ovs.sh`: Configures the OVS bridge and ports
- `setup-ovs.service`: systemd unit to automatically apply the OVS setup on boot
- `netplan/01-netcfg.yaml`: Netplan config to assign an IP address on VLAN 2201

## ⚠️ Important

> **Note**: The IP addresses, VLAN IDs, and interface names in the YAML and setup script are specific to one environment.
>
> You **must update** these values to match your network infrastructure:
>
> - IP address (`10.10.3.2/24`) → your desired management IP
> - VLANs (`2201–2205`) → your VLAN range
> - Interfaces (`ens4`, `ens5`, `ens6`) → your actual NIC names

---

## Installation Instructions

### 1. Copy Setup Script

```bash
sudo cp setup-ovs.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/setup-ovs.sh
```

### 2. Install systemd Service

```bash
sudo cp setup-ovs.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable setup-ovs.service
```

### 3. Configure Netplan

```bash
sudo cp netplan/01-netcfg.yaml /etc/netplan/
sudo netplan apply
```

### 4. Reboot the Host

```bash
sudo reboot
```

---

## Validation Steps

After rebooting:

1. Check if bridge `br0` and VLAN interface `br0.2201` are up:
   ```bash
   ip addr show br0
   ip addr show br0.2201
   ```

2. Test IP connectivity:
   ```bash
   ping 10.10.3.1
   ```

3. Test SSH access to `10.10.3.2` from another host.

4. Check Open vSwitch config:
   ```bash
   sudo ovs-vsctl show
   ```

## Requirements

- Ubuntu system with Open vSwitch installed
- `systemd-networkd` as the netplan renderer

---

## License

MIT License
