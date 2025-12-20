{pkgs, ...}: {
  stylix = {
    enable = true;

    # Gruvbox dark theme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    # Polarity for auto-generated schemes
    polarity = "dark";

    # High-res gruvbox wallpaper (works on ultrawide and 4K)
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/AngelJumbo/gruvbox-wallpapers/main/wallpapers/minimalistic/gruv-abstract-maze.png";
      sha256 = "sha256-VRZnvn405EnAv1za4eoF/ryvGn9bMlC4vx9662qNSO4=";
    };

    # Fonts
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 14;
        applications = 10;
        desktop = 10;
        popups = 10;
      };
    };

    # Cursor
    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    # Opacity
    opacity = {
      terminal = 0.85;
      popups = 0.95;
      desktop = 1.0;
      applications = 1.0;
    };

    # Auto-enable targets for installed applications
    autoEnable = true;
  };
}
