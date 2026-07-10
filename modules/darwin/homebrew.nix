{
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";

    casks = [
      "ghostty"
      "microsoft-outlook"
      "citrix-workspace"
      "iterm2"
      "karabiner-elements"
      "zoom"
      "orbstack"
      "tailscale-app"
    ];

    brews = [
      "openshift-cli"
    ];
  };
}
