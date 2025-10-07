# APT Packages

This module manages the installation of essential system packages via APT on Ubuntu 24 LTS.

## Features

- Automatic installation of WireGuard VPN
- Installation of net-tools for network utilities
- Package verification and testing
- Comprehensive error handling
- System integration validation

## Packages Installed

### Network & Security
- **WireGuard** - Modern VPN protocol for secure connections
- **net-tools** - Essential network utilities (netstat, ifconfig, route)

## Installation

To install all packages:

```bash
sudo ./install.sh
```

The installation process includes:
1. Updating package list
2. Installing WireGuard VPN package
3. Installing net-tools package
4. Verifying installations
5. Displaying package information

## WireGuard Usage

### Basic Setup

1. **Generate keys:**
   ```bash
   # Generate private key
   wg genkey | tee privatekey | wg pubkey > publickey
   
   # Generate preshared key (optional)
   wg genpsk > presharedkey
   ```

2. **Create configuration:**
   ```bash
   sudo nano /etc/wireguard/wg0.conf
   ```

3. **Start interface:**
   ```bash
   sudo wg-quick up wg0
   ```

4. **Enable at boot:**
   ```bash
   sudo systemctl enable wg-quick@wg0
   ```

### Example Configuration

```ini
[Interface]
PrivateKey = <your-private-key>
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = <peer-public-key>
Endpoint = <server-ip>:51820
AllowedIPs = 0.0.0.0/0
```

## Net-Tools Usage

### Network Information

```bash
# List network interfaces
ifconfig

# Show routing table
route -n

# Display network connections
netstat -tuln

# Show active connections
netstat -an

# Display network statistics
netstat -s
```

### Common Commands

```bash
# List listening ports
netstat -tuln

# Show TCP connections
netstat -t

# Show UDP connections
netstat -u

# Display interface statistics
ifconfig -a

# Show routing table
route -n
```

## Configuration

### WireGuard Configuration

WireGuard configuration files are typically stored in:
- `/etc/wireguard/` - System-wide configurations
- `~/.config/wireguard/` - User-specific configurations

### Network Tools

Net-tools provides traditional network utilities:
- `ifconfig` - Network interface configuration
- `netstat` - Network statistics and connections
- `route` - Routing table management
- `arp` - ARP table management
- `iptunnel` - IP tunnel management

## Security Considerations

### WireGuard Security

1. **Key Management:**
   - Keep private keys secure
   - Use strong preshared keys
   - Rotate keys regularly

2. **Network Security:**
   - Use proper firewall rules
   - Limit allowed IPs
   - Monitor connections

3. **Best Practices:**
   - Use unique keys per client
   - Implement proper authentication
   - Regular security updates

## Troubleshooting

### Common Issues

1. **WireGuard Connection Issues:**
   ```bash
   # Check interface status
   sudo wg show
   
   # Test connectivity
   ping <peer-ip>
   
   # Check logs
   journalctl -u wg-quick@wg0
   ```

2. **Network Tools Issues:**
   ```bash
   # Verify installation
   dpkg -l | grep net-tools
   
   # Check command availability
   which netstat
   which ifconfig
   ```

3. **Permission Issues:**
   ```bash
   # Check sudo access
   sudo -l
   
   # Verify package installation
   sudo apt list --installed | grep wireguard
   ```

### Getting Help

- **WireGuard Documentation:** [wireguard.com](https://www.wireguard.com/)
- **Net-tools Manual:** `man netstat`, `man ifconfig`
- **System Logs:** `journalctl -u wg-quick@wg0`

## Notes

- WireGuard requires kernel support (included in Ubuntu 24.04)
- Net-tools provides legacy network utilities
- Some modern systems prefer `ip` command over net-tools
- WireGuard configurations are typically managed by system administrators

## Related Documentation

- [WireGuard Official Documentation](https://www.wireguard.com/)
- [Ubuntu WireGuard Guide](https://ubuntu.com/server/docs/network-wireguard)
- [Net-tools Documentation](https://net-tools.sourceforge.io/)
