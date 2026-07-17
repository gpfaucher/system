{
  # Keep normal and Tailscale DNS for general traffic, but resolve SP's private
  # domain through the DNS server reachable over the beheer OpenVPN tunnel.
  environment.etc."resolver/s15m.nl".text = ''
    nameserver 10.200.1.2
    timeout 2
  '';
}
