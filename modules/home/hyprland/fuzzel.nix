{ lib, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = lib.mkForce "Monaspace Neon:size=12";
        icon-theme = lib.mkForce "Papirus-Dark";
        terminal = lib.mkForce "ghostty -e";
        layer = "overlay";
        prompt = "❯ ";
        width = 50;
        lines = 12;
        horizontal-pad = 20;
        vertical-pad = 12;
        inner-pad = 8;
      };
      # Colors handled by Stylix
      border = {
        width = 2;
        radius = 12;
      };
    };
  };
}
