{ pkgs, ... }:

{
  # Stylix theming configuration
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.monaspace;
        name = "Monaspace Neon";
      };
      sizes = {
        terminal = 14;
      };
    };

    opacity = {
      terminal = 0.9;
    };

    targets = {
      # Editors
      neovim.enable = true;
      zed.enable = true;

      # Shell and CLI
      fish.enable = true;
      btop.enable = true;
      fzf.enable = true;
      bat.enable = true;
      lazygit.enable = true;
      k9s.enable = true;
      yazi.enable = true;

      # Terminal
      ghostty.enable = true;

      # GTK apps
      gtk.enable = true;

      # Browser
      firefox.profileNames = [ "default" ];

      # KDE/Qt — disabled, managed by plasma-manager below
      # Stylix issue #1092: KDE may not start with Qt target enabled
      kde.enable = false;
      qt.enable = false;
    };
  };

  # Declarative KDE Plasma 6 configuration
  # Uses Breeze Dark to match ayu-dark aesthetic without the Stylix Qt/Kvantum issues
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
    };

    kwin = {
      titlebarButtons = {
        left = [ "on-all-desktops" ];
        right = [
          "minimize"
          "maximize"
          "close"
        ];
      };
    };

    shortcuts = {
      "kwin"."Switch to Desktop 1" = "Meta+1";
      "kwin"."Switch to Desktop 2" = "Meta+2";
      "kwin"."Switch to Desktop 3" = "Meta+3";
      "kwin"."Switch to Desktop 4" = "Meta+4";
    };
  };

  home.packages = [ pkgs.nerd-fonts.symbols-only ];
}
