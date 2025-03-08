{ pkgs, ... }: 
{
  programs = {
    dconf.enable = true;
    fish.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    git
  ];
}
