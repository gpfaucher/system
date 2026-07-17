{
  # Keep normal and Tailscale DNS for general traffic, but resolve SP's private
  # domain through the DNS server reachable over the beheer OpenVPN tunnel.
  environment.etc."resolver/s15m.nl".text = ''
    nameserver 10.200.1.2
    nameserver 10.200.101.5
    timeout 2
  '';

  # Tunnelblick settings are keyed by the profile's display name. Do not let
  # OpenVPN replace global DNS or disable IPv6 on Tailscale. The security-token
  # setting gives password and OTP separate fields; neither secret enters Nix.
  system.defaults.CustomUserPreferences."net.tunnelblick.tunnelblick" = {
    launchAtNextLogin = true;

    "SP Beheer GN2 (UDP)-doNotDisableIpv6onTun" = true;
    "SP Beheer GN2 (UDP)-loginWindowSecurityTokenCheckboxIsChecked" = true;
    "SP Beheer GN2 (UDP)useDNS" = 0;

    "SP Beheer GN3 (TCP)-doNotDisableIpv6onTun" = true;
    "SP Beheer GN3 (TCP)-loginWindowSecurityTokenCheckboxIsChecked" = true;
    "SP Beheer GN3 (TCP)useDNS" = 0;
  };

  # Shared Tunnelblick profiles are installed system-wide. Credentials remain
  # in the user's macOS Keychain and OTP is requested for every connection.
  system.activationScripts.postActivation.text = ''
    shared_profiles="/Library/Application Support/Tunnelblick/Shared"
    gn2_profile="$shared_profiles/SP Beheer GN2 (UDP).tblk/Contents/Resources"
    gn3_profile="$shared_profiles/SP Beheer GN3 (TCP).tblk/Contents/Resources"

    /usr/bin/install -d -m 0755 "$gn2_profile" "$gn3_profile"
    /usr/bin/install -o root -g wheel -m 0700 ${./vpn-profiles/sp-beheer-gn2-udp.ovpn} "$gn2_profile/config.ovpn"
    /usr/bin/install -o root -g wheel -m 0700 ${./vpn-profiles/sp-beheer-gn3-tcp.ovpn} "$gn3_profile/config.ovpn"
  '';
}
