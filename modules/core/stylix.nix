{pkgs, ...}: {
  stylix = {
    enable = true;

    # Gruvbox dark theme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    # Polarity for auto-generated schemes
    polarity = "dark";

    # Solid gruvbox background (#282828)
    image = ../../assets/wallpaper.png;

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
