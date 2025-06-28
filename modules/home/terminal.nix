{ lib, ... }: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = lib.mkForce "JetBrainsMono Nerd Font Mono:size=12";
        dpi-aware = lib.mkForce "yes";
      };
    };
  };
}
