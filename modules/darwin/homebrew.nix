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
    ];

    brews = [
      "openshift-cli"
    ];
  };
}
