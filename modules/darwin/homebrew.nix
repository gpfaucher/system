{
  homebrew = {
    enable = true;
    onActivation.cleanup = "none";

    casks = [
      "ghostty"
      "tailscale-app"
      "openvpn-connect"
    ];
  };
}
