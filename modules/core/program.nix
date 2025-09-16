{ pkgs, ... }:
{
  programs = {
    dconf.enable = true;
    fish.enable = true;
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
    wget
    git
  ];
}
