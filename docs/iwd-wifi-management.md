# iwd WiFi Management Guide

This system uses **iwd** (iNet Wireless Daemon) for wireless management instead of NetworkManager.

## Quick Start

### Using Impala (TUI)
```bash
# Launch impala WiFi manager
impala

# In River WM: Super+Shift+W
```

Impala provides a user-friendly terminal UI for:
- Scanning networks
- Connecting to WiFi
- Managing saved networks
- Viewing connection status

### Using iwctl (CLI)

```bash
# Interactive mode
iwctl

# Common commands
iwctl device list                           # List wireless devices
iwctl station wlan0 scan                    # Scan for networks
iwctl station wlan0 get-networks            # Show available networks
iwctl station wlan0 connect SSID            # Connect to network
iwctl station wlan0 disconnect              # Disconnect
iwctl known-networks list                   # List saved networks
iwctl known-networks forget SSID            # Forget a network
```

## Configuration

iwd is configured in `modules/system/networking.nix`:

```nix
networking.wireless.iwd = {
  enable = true;
  settings = {
    General = {
      EnableNetworkConfiguration = true;  # iwd handles DHCP
      UseDefaultInterface = true;
    };
    Network = {
      EnableIPv6 = true;
      RoutePriorityOffset = 300;
    };
  };
};
```

## Network Storage

- **Credentials**: `/var/lib/iwd/*.psk` (one file per network)
- **Format**: Plain text config files
- **Permissions**: Root-owned, mode 0600
- **Impermanence**: Add `/var/lib/iwd` to persistence when enabled

## Advanced iwctl Commands

```bash
# Get detailed device info
iwctl device wlan0 show

# Get connection info
iwctl station wlan0 show

# Connect with passphrase inline (useful for scripts)
iwctl --passphrase="password" station wlan0 connect SSID

# Set adapter power state
iwctl adapter phy0 set-property Powered on
```

## Troubleshooting

### No networks found
```bash
# Check if wireless is blocked
rfkill list
rfkill unblock wifi

# Restart iwd service
sudo systemctl restart iwd
```

### Can't connect
```bash
# Check iwd status
sudo systemctl status iwd

# View logs
journalctl -u iwd -f

# Forget and reconnect
iwctl known-networks forget SSID
iwctl station wlan0 connect SSID
```

### DHCP not working
If you need static IP or custom DHCP, you can disable iwd's built-in DHCP:

```nix
networking.wireless.iwd.settings.General.EnableNetworkConfiguration = false;
```

Then configure networking separately via NixOS options or use `dhcpcd`.

## Migration from NetworkManager

Changes made during migration:
1. Disabled `networking.networkmanager.enable`
2. Enabled `networking.wireless.iwd`
3. Removed `networkmanagerapplet` package
4. Changed user group from `networkmanager` to `network`
5. Updated impermanence paths for iwd

## Advantages of iwd

- **Simpler**: Less complexity than NetworkManager
- **Faster**: Lower overhead and quicker connections
- **Modern**: Built-in DHCP, DNS, and IPv6 support
- **Declarative**: Config via files, no dbus complexity
- **Wayland-friendly**: No GUI dependencies

## References

- [iwd Wiki](https://iwd.wiki.kernel.org/)
- [Arch Wiki: iwd](https://wiki.archlinux.org/title/Iwd)
- [NixOS Wiki: iwd](https://nixos.wiki/wiki/Iwd)
- [impala GitHub](https://github.com/pythops/impala)
