{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Stylix theming configuration
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.monaspace;
        name = "Monaspace Neon";  # or Argon, Krypton, Xenon, Radon
      };
      sizes = {
        terminal = 14;
      };
    };

    opacity = {
      terminal = 0.9;
    };

    targets = {
      # nvf handles neovim theming
      neovim.enable = false;
      fish.enable = true;
      gtk.enable = true;
      fuzzel.enable = false; # Use custom minimal config below
      firefox.profileNames = [ "default" ];
    };
  };

  # Install Nerd Font for icons (used by wlogout, starship, etc.)
  home.packages = [ pkgs.nerd-fonts.symbols-only ];

  # Minimal fuzzel launcher config - centered floating, no bar, gruvbox themed
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=Monaspace Neon:size=12
    prompt=""
    icon-theme=Adwaita
    icons-enabled=no
    fields=name,generic,comment,categories,filename,keywords
    terminal=ghostty -e
    layer=overlay
    lines=12
    width=40
    horizontal-pad=20
    vertical-pad=12
    inner-pad=8

    [colors]
    # Gruvbox Dark Medium - minimal theme
    background=282828ee
    text=d5c4a1ff
    match=83a598ff
    selection=3c3836ff
    selection-text=ebdbb2ff
    selection-match=83a598ff
    border=504945ff

    [border]
    width=2
    radius=0
  '';

  # fnott notification daemon config with Gruvbox colors
  xdg.configFile."fnott/fnott.ini".text = ''
    [main]
    output=
    min-width=300
    max-width=400
    max-height=200
    stacking-order=top-down
    anchor=top-right
    edge-margin-vertical=10
    edge-margin-horizontal=10
    icon-theme=Adwaita
    max-icon-size=32
    selection-helper=fuzzel --dmenu

    [low]
    # Gruvbox Dark Medium colors
    background=282828dd
    title-color=d5c4a1ff
    summary-color=d5c4a1ff
    body-color=bdae93ff
    border-color=665c54ff
    border-size=2
    title-font=Monaspace Neon:size=10:weight=bold
    summary-font=Monaspace Neon:size=10
    body-font=Monaspace Neon:size=9
    default-timeout=5
    progress-bar-color=83a598ff

    [normal]
    background=282828dd
    title-color=d5c4a1ff
    summary-color=d5c4a1ff
    body-color=bdae93ff
    border-color=83a598ff
    border-size=2
    title-font=Monaspace Neon:size=10:weight=bold
    summary-font=Monaspace Neon:size=10
    body-font=Monaspace Neon:size=9
    default-timeout=10
    progress-bar-color=83a598ff

    [critical]
    background=282828ee
    title-color=fb4934ff
    summary-color=fb4934ff
    body-color=d5c4a1ff
    border-color=fb4934ff
    border-size=3
    title-font=Monaspace Neon:size=10:weight=bold
    summary-font=Monaspace Neon:size=10
    body-font=Monaspace Neon:size=9
    default-timeout=0
    progress-bar-color=fb4934ff
  '';

  # waylock screen locker config with Gruvbox colors
  xdg.configFile."waylock/waylock.toml".text = ''
    [flags]
    ignore-empty-password = true

    [colors]
    # Gruvbox Dark Medium
    init-color = "282828"
    input-color = "83a598"
    fail-color = "fb4934"
  '';

  # wlogout layout configuration
  xdg.configFile."wlogout/layout".text = ''
    {
        "label" : "lock",
        "action" : "waylock",
        "text" : "Lock",
        "keybind" : "l"
    }
    {
        "label" : "logout",
        "action" : "riverctl exit",
        "text" : "Logout",
        "keybind" : "e"
    }
    {
        "label" : "suspend",
        "action" : "systemctl suspend",
        "text" : "Suspend",
        "keybind" : "s"
    }
    {
        "label" : "hibernate",
        "action" : "systemctl hibernate",
        "text" : "Hibernate",
        "keybind" : "h"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot",
        "keybind" : "r"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shutdown",
        "keybind" : "p"
    }
  '';

  # wlogout style with Gruvbox colors and SVG icons
  xdg.configFile."wlogout/style.css".text = ''
    * {
        background-image: none;
        font-family: "Monaspace Neon", monospace;
        font-size: 14px;
    }

    window {
        background-color: rgba(40, 40, 40, 0.9);
    }

    button {
        color: #d5c4a1;
        background-color: #3c3836;
        border: 2px solid #504945;
        border-radius: 8px;
        margin: 10px;
        background-repeat: no-repeat;
        background-position: center 30%;
        background-size: 64px;
    }

    button:focus, button:active, button:hover {
        background-color: #504945;
        border-color: #83a598;
        outline-style: none;
    }

    #lock {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png"));
    }

    #logout {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png"));
    }

    #suspend {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"));
    }

    #hibernate {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"));
    }

    #reboot {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"));
    }

    #shutdown {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"));
    }
  '';
}
