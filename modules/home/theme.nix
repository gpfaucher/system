{
  pkgs,
  ...
}:

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
      neovim.enable = true;
      fish.enable = true;
      gtk.enable = true;
      kde.enable = false; # Disabled: crashes on NixOS
      qt.enable = false; # Disabled: kvantum breaks KDE QML components
      firefox.profileNames = [ "default" ];
    };
  };

  home.packages = [ pkgs.nerd-fonts.symbols-only ];

  # KDE Plasma handles the following natively:
  # - Application launcher (KRunner, Kickoff)
  # - Notifications
  # - Screen locking
  # - Logout/power menu
}
