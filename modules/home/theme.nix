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
      fuzzel.enable = true;
    };
  };

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

  # wlogout style with Gruvbox colors
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
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
        margin: 5px;
    }

    button:focus, button:active, button:hover {
        background-color: #504945;
        border-color: #83a598;
        outline-style: none;
    }

    #lock {
        background-image: image(url("/usr/share/wlogout/icons/lock.png"));
    }
    #logout {
        background-image: image(url("/usr/share/wlogout/icons/logout.png"));
    }
    #suspend {
        background-image: image(url("/usr/share/wlogout/icons/suspend.png"));
    }
    #hibernate {
        background-image: image(url("/usr/share/wlogout/icons/hibernate.png"));
    }
    #reboot {
        background-image: image(url("/usr/share/wlogout/icons/reboot.png"));
    }
    #shutdown {
        background-image: image(url("/usr/share/wlogout/icons/shutdown.png"));
    }
  '';
}
