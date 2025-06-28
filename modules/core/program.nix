{ pkgs, ... }: {
  programs = {
    dconf.enable = true;
    # ssh.startAgent = true;
    fish.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  };

  services.openssh = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    nerd-fonts.jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.monaspace
    devenv
    direnv
    numix-cursor-theme
    wget
    git
  ];
}
