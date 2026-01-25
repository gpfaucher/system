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
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
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
      # nvf uses base16 theme, Stylix provides the colors
      neovim.enable = true;
      fish.enable = true;
      gtk.enable = true;
      fuzzel.enable = false; # Use custom minimal config below
      firefox.profileNames = [ "default" ];
    };
  };

  # Install Nerd Font for icons (used by wlogout, starship, etc.)
  home.packages = [ pkgs.nerd-fonts.symbols-only ];

  # Minimal fuzzel launcher config - centered floating, no bar, Ayu Dark themed
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
    # Ayu Dark - minimal theme
    background=0b0e14ee
    text=bfbdb6ff
    match=ffb454ff
    selection=1c1f25ff
    selection-text=e6e1cfff
    selection-match=ffb454ff
    border=24272dff

    [border]
    width=2
    radius=0
  '';

  # fnott notification daemon config with Ayu Dark colors
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
    # Ayu Dark colors
    background=0b0e14dd
    title-color=bfbdb6ff
    summary-color=bfbdb6ff
    body-color=8a9199ff
    border-color=24272dff
    border-size=2
    title-font=Monaspace Neon:size=10:weight=bold
    summary-font=Monaspace Neon:size=10
    body-font=Monaspace Neon:size=9
    default-timeout=5
    progress-bar-color=59c2ffff

    [normal]
    background=0b0e14dd
    title-color=bfbdb6ff
    summary-color=bfbdb6ff
    body-color=8a9199ff
    border-color=59c2ffff
    border-size=2
    title-font=Monaspace Neon:size=10:weight=bold
    summary-font=Monaspace Neon:size=10
    body-font=Monaspace Neon:size=9
    default-timeout=10
    progress-bar-color=59c2ffff

    [critical]
    background=0b0e14ee
    title-color=f07178ff
    summary-color=f07178ff
    body-color=bfbdb6ff
    border-color=f07178ff
    border-size=3
    title-font=Monaspace Neon:size=10:weight=bold
    summary-font=Monaspace Neon:size=10
    body-font=Monaspace Neon:size=9
    default-timeout=0
    progress-bar-color=f07178ff
  '';

  # waylock screen locker config with Ayu Dark colors
  xdg.configFile."waylock/waylock.toml".text = ''
    [flags]
    ignore-empty-password = true

    [colors]
    # Ayu Dark
    init-color = "0b0e14"
    input-color = "59c2ff"
    fail-color = "f07178"
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

  # wlogout style with Ayu Dark colors and SVG icons
  xdg.configFile."wlogout/style.css".text = ''
    * {
        background-image: none;
        font-family: "Monaspace Neon", monospace;
        font-size: 14px;
    }

    window {
        background-color: rgba(11, 14, 20, 0.9);
    }

    button {
        color: #bfbdb6;
        background-color: #1c1f25;
        border: 2px solid #24272d;
        border-radius: 8px;
        margin: 10px;
        background-repeat: no-repeat;
        background-position: center 30%;
        background-size: 64px;
    }

    button:focus, button:active, button:hover {
        background-color: #24272d;
        border-color: #59c2ff;
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
