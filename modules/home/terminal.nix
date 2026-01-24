{ inputs, pkgs, ... }:

{
  # Ghostty terminal (from ghostty flake)
  programs.ghostty = {
    enable = true;
    package = inputs.ghostty.packages.${pkgs.system}.default;

    settings = {
      # Start in home directory
      working-directory = "/home/gabriel";
      window-inherit-working-directory = false;

      # Window settings - no decorations/borders
      window-decoration = false;
      window-padding-x = 4;
      window-padding-y = 4;
      gtk-titlebar = false;

      # Transparency
      background-opacity = 0.9;

      # Font (colors handled by Stylix)
      font-family = "JetBrainsMono Nerd Font";
      font-family-bold = "JetBrainsMono Nerd Font";
      font-family-italic = "JetBrainsMono Nerd Font";
      font-family-bold-italic = "JetBrainsMono Nerd Font";
      font-size = 14;

      # Behavior
      copy-on-select = "clipboard";
      confirm-close-surface = false;
      mouse-hide-while-typing = true;
      scrollback-limit = 1000000000;
    };

    # keybindings = {
    #   "ctrl+shift+c" = "copy_to_clipboard";
    #   "ctrl+shift+v" = "paste_from_clipboard";
    #   "ctrl+plus" = "increase_font_size:1";
    #   "ctrl+minus" = "decrease_font_size:1";
    #   "ctrl+zero" = "reset_font_size";
    # };
  };
}
