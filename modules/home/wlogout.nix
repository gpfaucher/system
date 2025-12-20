{
  config,
  pkgs,
  ...
}: let
  colors = config.lib.stylix.colors;
in {
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "chayang && waylock";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "logout";
        action = "riverctl exit";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "s";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "p";
      }
    ];
    style = ''
      * {
        background-image: none;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      window {
        background-color: rgba(${config.lib.stylix.colors.base00-rgb-r}, ${config.lib.stylix.colors.base00-rgb-g}, ${config.lib.stylix.colors.base00-rgb-b}, 0.9);
      }

      button {
        color: #${colors.base05};
        background-color: #${colors.base01};
        border: 2px solid #${colors.base02};
        border-radius: 0;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
        margin: 5px;
      }

      button:focus, button:active, button:hover {
        background-color: #${colors.base02};
        border-color: #${colors.base0D};
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
  };
}
