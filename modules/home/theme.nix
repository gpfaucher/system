{ pkgs, config, ... }:

let
  # Ayu Dark base16 palette -> KDE RGB triplets
  # Mirrors the exact mapping from Stylix's modules/kde/hm.nix
  colors = {
    base00 = "11,14,20"; # #0b0e14 - background
    base01 = "19,23,33"; # #131721 - alternate bg
    base02 = "32,34,41"; # #202229 - selection bg
    base03 = "62,75,89"; # #3e4b59 - comments
    base04 = "191,189,182"; # #bfbdb6 - dark fg
    base05 = "230,225,207"; # #e6e1cf - foreground
    base06 = "236,232,219"; # #ece8db - light fg
    base07 = "242,240,231"; # #f2f0e7 - lightest fg
    base08 = "240,113,120"; # #f07178 - red
    base09 = "255,143,64"; # #ff8f40 - orange
    base0A = "255,180,84"; # #ffb454 - yellow
    base0B = "170,217,76"; # #aad94c - green
    base0C = "149,230,203"; # #95e6cb - cyan
    base0D = "89,194,255"; # #59c2ff - blue
    base0E = "210,166,255"; # #d2a6ff - purple
    base0F = "230,180,80"; # #e6b450 - brown
  };

  kdecolors = with colors; {
    BackgroundNormal = base00;
    BackgroundAlternate = base01;
    DecorationFocus = base0D;
    DecorationHover = base0D;
    ForegroundNormal = base05;
    ForegroundActive = base05;
    ForegroundInactive = base05;
    ForegroundLink = base05;
    ForegroundVisited = base05;
    ForegroundNegative = base08;
    ForegroundNeutral = base0D;
    ForegroundPositive = base0B;
  };

  selectionColors = kdecolors // (with colors; {
    BackgroundNormal = base0D;
    BackgroundAlternate = base0D;
    ForegroundNormal = base00;
    ForegroundActive = base00;
    ForegroundInactive = base00;
    ForegroundLink = base00;
    ForegroundVisited = base00;
  });

  colorEffect = {
    ColorEffect = 0;
    ColorAmount = 0;
    ContrastEffect = 1;
    ContrastAmount = 0.5;
    IntensityEffect = 0;
    IntensityAmount = 0;
  };

  formatSection = name: attrs:
    "[${name}]\n" + builtins.concatStringsSep "\n" (
      builtins.attrValues (builtins.mapAttrs (k: v: "${k}=${toString v}") attrs)
    );

  colorSchemeFile = builtins.concatStringsSep "\n\n" [
    (formatSection "General" {
      ColorScheme = "AyuDark";
      Name = "Ayu Dark";
    })
    (formatSection "ColorEffects:Disabled" colorEffect)
    (formatSection "ColorEffects:Inactive" colorEffect)
    (formatSection "Colors:Window" kdecolors)
    (formatSection "Colors:View" kdecolors)
    (formatSection "Colors:Button" kdecolors)
    (formatSection "Colors:Tooltip" kdecolors)
    (formatSection "Colors:Complementary" kdecolors)
    (formatSection "Colors:Selection" selectionColors)
    (formatSection "Colors:Header" kdecolors)
    (formatSection "WM" (with colors; {
      activeBlend = base0A;
      activeBackground = base00;
      activeForeground = base05;
      inactiveBlend = base03;
      inactiveBackground = base00;
      inactiveForeground = base05;
    }))
  ];
in
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

      # KDE/Qt — disabled due to Stylix issue #1092 (Kvantum breaks Plasma 6)
      # Color scheme is generated manually below and applied via plasma-manager
      kde.enable = false;
      qt.enable = false;
    };
  };

  # Install ayu-dark KDE color scheme (generated from same base16 palette as Stylix)
  xdg.dataFile."color-schemes/AyuDark.colors".text = colorSchemeFile;

  # Declarative KDE Plasma 6 configuration
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "AyuDark";
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
