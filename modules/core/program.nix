{ pkgs, ... }: {
  programs = {
    dconf.enable = true;
    ssh.startAgent = true;
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
    wget
    git
  ];
}
