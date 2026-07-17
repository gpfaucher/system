{
  homebrew = {
    enable = true;
    onActivation.cleanup = "none";

    casks = [
      "ghostty"
      "tailscale-app"
      "tunnelblick"
    ];
  };
}
