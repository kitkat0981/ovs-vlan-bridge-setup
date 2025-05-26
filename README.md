# Open vSwitch VLAN Bridge Setup

This repository provides scripts and configuration files to set up an Open vSwitch (OVS) bridge with VLAN trunking and access ports on Ubuntu. This setup is useful for environments that require advanced VLAN routing and management via trunk and access interfaces.

---

## ⚠️ Important Notice

**This configuration is tailored to a specific environment. You _must_ update the IP addresses, VLAN IDs, and interface names to match your own infrastructure.**

### Update the following:
- **IP address** (`10.10.3.2/24`) → your management IP address
- **Gateway** (`10.10.3.1`) → your default gateway
- **VLAN IDs** (`2201–2205`) → your actual VLAN range
- **Network interfaces** (`ens4`, `ens5`, `ens6`) → replace with names from `ip link show`

---

## 🧱 Topology

- `ens4` and `ens6`: Trunk ports carrying VLANs `2201–2205`
- `ens5`: Access port on VLAN `2201` (for management, IP: `10.10.3.2/24`)
- `br0`: OVS bridge carrying both trunk and access ports
- `br0.2201`: VLAN subinterface used for host management

### Diagram

![diagram](images/diagram.png)

---

## 📁 Files Included

- `setup-ovs.sh`: Bash script to configure the OVS bridge and ports
- `setup-ovs.service`: systemd unit file to apply the OVS configuration at boot
- `netplan/01-netcfg.yaml`: Netplan config to assign an IP address to the VLAN subinterface

---

## ✅ Prerequisites

- Ubuntu 20.04 or later
- `systemd-networkd` as the netplan renderer
- Root or sudo privileges

---

## 🛠 Installation Steps

### 1. Install Open vSwitch

```bash
sudo apt update
sudo apt install openvswitch-switch openvswitch-common
```

### 2. Clone the Repository

```bash
git clone https://github.com/kitkat0981/ovs-vlan-bridge-setup.git
cd ovs-vlan-bridge-setup
```

### 3. Review and Edit Configuration Files

Edit `setup-ovs.sh` and `netplan/01-netcfg.yaml` to reflect your:
- Network interfaces
- VLAN ranges
- IP addressing

### 4. Deploy the OVS Setup Script

```bash
sudo cp setup-ovs.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/setup-ovs.sh
```

### 5. Install the systemd Service

```bash
sudo cp setup-ovs.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable setup-ovs.service
```

### 6. Configure Netplan

```bash
sudo cp netplan/01-netcfg.yaml /etc/netplan/
sudo netplan apply
```

### 7. Reboot the System

```bash
sudo reboot
```

---

## 🔍 Validation Steps

After the system reboots:

1. **Check interfaces**:
   ```bash
   ip addr show br0
   ip addr show br0.2201
   ```

2. **Test connectivity**:
   ```bash
   ping 10.10.3.1
   ```

3. **SSH into the host**:
   ```bash
   ssh user@10.10.3.2
   ```

4. **Review OVS configuration**:
   ```bash
   sudo ovs-vsctl show
   ```

---

## 🧪 Troubleshooting

- If `br0` or `br0.2201` does not appear:
  - Ensure the OVS service is running
  - Double-check interface names and VLAN IDs
  - Inspect systemd logs:
    ```bash
    journalctl -u setup-ovs.service
    ```

- If no IP is assigned to `br0.2201`, ensure:
  - Netplan is applied correctly:
    ```bash
    sudo netplan apply
    ```
  - Validate YAML syntax:
    ```bash
    sudo netplan try
    ```

- If SSH fails:
  - Confirm that `br0.2201` is up and has the correct IP
  - Confirm firewall rules are not blocking SSH (e.g., `ufw status`)

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 📬 Feedback

Pull requests and issues are welcome! This project was built for learning and real-world use cases. Feel free to fork, modify, or contribute.
