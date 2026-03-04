{ pkgs, config, ... }:

{
  # Stylix theming configuration
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    polarity = "dark";

    # Disable overlays at home-manager level since useGlobalPkgs = true
    # System-level Stylix (nixosModules) already applies overlays to nixpkgs
    overlays.enable = false;

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
      # Editors — base16-nvim handles Neovim theming now
      neovim.enable = false;
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

      # KDE/Qt — plasma-manager handles KDE theming
      kde.enable = false;
      qt.enable = false;
    };
  };

  home.packages = [ pkgs.nerd-fonts.symbols-only ];
}
