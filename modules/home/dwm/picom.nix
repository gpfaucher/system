{ config, pkgs, ... }:

{
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;

    # Fading
    fade = true;
    fadeDelta = 8;
    fadeSteps = [ 0.06 0.06 ];

    # Shadows
    shadow = true;
    shadowOpacity = 0.6;
    shadowOffsets = [ (-8) (-8) ];
    shadowExclude = [
      "class_g = 'dwm'"
      "class_g = 'dmenu'"
      "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
    ];

    # Opacity
    activeOpacity = 1.0;
    inactiveOpacity = 0.95;

    opacityRules = [
      "100:class_g = 'firefox' && focused"
      "100:class_g = 'teams-for-linux'"
      "100:class_g = 'zoom'"
      "100:fullscreen"
    ];

    settings = {
      # Blur
      blur = {
        method = "dual_kawase";
        strength = 5;
      };

      # Rounded corners
      corner-radius = 8;

      rounded-corners-exclude = [
        "class_g = 'dwm'"
        "class_g = 'dmenu'"
      ];

      # Performance
      glx-no-stencil = true;
      glx-no-rebind-pixmap = true;
      use-damage = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;

      # Window type rules
      wintypes = {
        tooltip = {
          fade = true;
          shadow = false;
          opacity = 0.9;
        };
        dock = {
          shadow = false;
          clip-shadow-above = true;
        };
        dnd = {
          shadow = false;
        };
        popup_menu = {
          fade = true;
          shadow = true;
          opacity = 0.95;
        };
        dropdown_menu = {
          fade = true;
          shadow = true;
          opacity = 0.95;
        };
      };
    };
  };
}
