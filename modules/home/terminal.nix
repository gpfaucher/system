{ config, lib, ... }:

{
  # Ghostty installed via Homebrew cask; manage config file directly
  xdg.configFile."ghostty/config" = {
    force = true;
    text = ''
      working-directory = ${config.home.homeDirectory}
      window-inherit-working-directory = false

      window-padding-x = 4
      window-padding-y = 4

      background-opacity = 0.9

      font-family = JetBrainsMono Nerd Font
      font-family-bold = JetBrainsMono Nerd Font
      font-family-italic = JetBrainsMono Nerd Font
      font-family-bold-italic = JetBrainsMono Nerd Font
      font-size = 16

      copy-on-select = clipboard
      confirm-close-surface = false
      mouse-hide-while-typing = true
      scrollback-limit = 1000000000
    '';
  };
}
