{ config, lib, pkgs, ... }:

{
  # Stylix theming configuration
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
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

  # Minimal fuzzel launcher config - centered floating, no bar, gruvbox themed
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=12
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
    title-font=JetBrainsMono Nerd Font:size=10:weight=bold
    summary-font=JetBrainsMono Nerd Font:size=10
    body-font=JetBrainsMono Nerd Font:size=9
    default-timeout=5
    progress-bar-color=83a598ff

    [normal]
    background=282828dd
    title-color=d5c4a1ff
    summary-color=d5c4a1ff
    body-color=bdae93ff
    border-color=83a598ff
    border-size=2
    title-font=JetBrainsMono Nerd Font:size=10:weight=bold
    summary-font=JetBrainsMono Nerd Font:size=10
    body-font=JetBrainsMono Nerd Font:size=9
    default-timeout=10
    progress-bar-color=83a598ff

    [critical]
    background=282828ee
    title-color=fb4934ff
    summary-color=fb4934ff
    body-color=d5c4a1ff
    border-color=fb4934ff
    border-size=3
    title-font=JetBrainsMono Nerd Font:size=10:weight=bold
    summary-font=JetBrainsMono Nerd Font:size=10
    body-font=JetBrainsMono Nerd Font:size=9
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

  # wlogout style with Gruvbox colors and Unicode symbols
  xdg.configFile."wlogout/style.css".text = ''
    * {
        background-image: none;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
    }

    window {
        /* Gruvbox bg with transparency */
        background-color: rgba(40, 40, 40, 0.9);
    }

    button {
        /* Gruvbox colors */
        color: #d5c4a1;
        background-color: #3c3836;
        border: 2px solid #504945;
        border-radius: 0;
        margin: 5px;
        padding: 20px;
        min-width: 120px;
        min-height: 120px;
    }

    button:focus, button:active, button:hover {
        background-color: #504945;
        border-color: #83a598;
        outline-style: none;
    }

    /* Unicode symbol buttons */
    #lock {
        background-image: none;
    }
    #lock label {
        font-size: 48px;
    }
    #lock label:before {
        content: "🔒\A";
        white-space: pre;
    }

    #logout {
        background-image: none;
    }
    #logout label {
        font-size: 48px;
    }
    #logout label:before {
        content: "🚪\A";
        white-space: pre;
    }

    #suspend {
        background-image: none;
    }
    #suspend label {
        font-size: 48px;
    }
    #suspend label:before {
        content: "💤\A";
        white-space: pre;
    }

    #hibernate {
        background-image: none;
    }
    #hibernate label {
        font-size: 48px;
    }
    #hibernate label:before {
        content: "❄\A";
        white-space: pre;
    }

    #reboot {
        background-image: none;
    }
    #reboot label {
        font-size: 48px;
    }
    #reboot label:before {
        content: "🔄\A";
        white-space: pre;
    }

    #shutdown {
        background-image: none;
    }
    #shutdown label {
        font-size: 48px;
    }
    #shutdown label:before {
        content: "⏻\A";
        white-space: pre;
    }
  '';
}
