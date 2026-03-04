{ inputs, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      working-directory = "/home/gabriel";
      window-inherit-working-directory = false;

      window-padding-x = 4;
      window-padding-y = 4;

      background-opacity = 0.9;

      # Colors handled by Stylix
      font-family = "JetBrainsMono Nerd Font";
      font-family-bold = "JetBrainsMono Nerd Font";
      font-family-italic = "JetBrainsMono Nerd Font";
      font-family-bold-italic = "JetBrainsMono Nerd Font";
      font-size = 14;

      copy-on-select = "clipboard";
      confirm-close-surface = false;
      mouse-hide-while-typing = true;
      scrollback-limit = 1000000000;
    };
  };
}
