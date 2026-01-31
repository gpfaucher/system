{
  config,
  lib,
  pkgs,
  ...
}:

{
  # ============================================
  # Wired Network Configuration (Server/Desktop)
  # ============================================
  # Simple wired networking using systemd-networkd
  # No WiFi management needed

  # Use systemd-networkd for network management
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # DHCP on all wired interfaces by default
  # Override in host config for static IP if needed
  networking.useDHCP = lib.mkDefault true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    # Default ports - host config can add more
    allowedTCPPorts = [
      22 # SSH
    ];
  };

  # Disable wireless-related services (not needed for wired)
  networking.wireless.enable = false;
  networking.networkmanager.enable = false;

  # Network diagnostic tools
  environment.systemPackages = with pkgs; [
    ethtool     # Ethernet diagnostics
    iperf3      # Network performance testing
    nmap        # Network scanning
    tcpdump     # Packet capture
    traceroute  # Route tracing
  ];
}
