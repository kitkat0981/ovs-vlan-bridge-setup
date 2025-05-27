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
> - IP address (`10.0.22.3/24`) → your desired management IP on the ens3 port (in netplan)
> - VLANs (`2201–2205`) → your VLAN range
> - Interfaces (`ens4`, `ens5`, `ens6`) → your actual NIC names

---

## Installation Instructions

### 1. Install Open vSwitch

```bash
sudo apt update
sudo apt install -y openvswitch-switch openvswitch-common
```

### 2. Copy Setup Script

```bash
sudo cp setup-ovs.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/setup-ovs.sh
```

### 3. Install systemd Service

```bash
sudo cp setup-ovs.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable setup-ovs.service
```

### 4. Configure Netplan

Edit `/etc/netplan/01-netcfg.yaml` to include a defined `br0` bridge:

```yaml
network:
  version: 2
  renderer: networkd

#this configuration is for the OOB (Out-Of-Band) management of the host only.

  ethernets:
    ens3: #change this to you out-of-band management port
      dhcp4: false
      dhcp6: false
      addresses:
      - 10.0.22.3/24 #change this to the IP you want to assign
      routes:
      - to: default
        via: 10.0.22.254 #change this to the gateway of interface
      nameservers:
        addresses: [8.8.8.8] #change to whatever the DNS you want to use
```

Then apply the configuration:

```bash
sudo netplan generate
sudo netplan apply
```

### 5. Reboot the Host

```bash
sudo reboot
```

---

## Validation Steps

After rebooting:

1. Check if bridge `br0` is are up:
   ```bash
   ip addr show br0
   
   ```

2. Test IP connectivity:
   ```bash
   ping 10.0.22.3
   ```

3. Test SSH access to `10.0.22.3` from another host.

4. Check Open vSwitch config:
   ```bash
   sudo ovs-vsctl show
   ```

---

## Troubleshooting

### Network Startup Delay

If the system stalls at `systemd-networkd-wait-online.service`, disable and mask it:

```bash
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service
```

### Interface `br0` Not Defined

Ensure that `br0` is declared in the Netplan YAML. Netplan must define the bridge, even if Open vSwitch also creates it.

### OVS Bridge Already Exists

If `ovs-vsctl` shows: `could not add network device br0 to ofproto (file exists)`, the bridge might have been defined both by Netplan and OVS. To avoid this:

- Use Netplan only to define the existence of `br0` (with no interfaces).
- Let `setup-ovs.sh` handle the OVS configuration.

### Still Delays on Boot?

Create a systemd-networkd override for `br0`:

```bash
sudo mkdir -p /etc/systemd/network/
cat <<EOF | sudo tee /etc/systemd/network/br0.network
[Match]
Name=br0

[Network]
DHCP=no

[Link]
RequiredForOnline=no
EOF

sudo systemctl restart systemd-networkd
```

---

## Requirements

- Ubuntu system with Open vSwitch installed
- `systemd-networkd` as the Netplan renderer

---

## License

MIT License
