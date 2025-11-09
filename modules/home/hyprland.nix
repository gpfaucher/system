{ lib, ... }:
{
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "Super";

    general = {
      gaps_out = 0;
      gaps_in = 0;
      allow_tearing = false;
      layout = "master";
    };

    master = {
      new_status = "master";
    };

    misc = {
      disable_hyprland_logo = true;
      enable_swallow = true;
    };

    decoration = {
      rounding = 0;

      active_opacity = 1.0;
      inactive_opacity = 1.0;

      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
      };

      blur = {
        enabled = true;
        size = 3;
        passes = 1;

        vibrancy = 0.1696;
      };
    };

    animations = {
      enabled = true;

      bezier = [
        "easeOutQuint,0.23,1,0.32,1"
        "easeInOutCubic,0.65,0.05,0.36,1"
        "linear,0,0,1,1"
        "almostLinear,0.5,0.5,0.75,1.0"
        "quick,0.15,0,0.1,1"
      ];

      animation = [
        "global, 1, 10, default"
        "border, 1, 5.39, easeOutQuint"
        "windows, 1, 4.79, easeOutQuint"
        "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
        "windowsOut, 1, 1.49, linear, popin 87%"
        "fadeIn, 1, 1.73, almostLinear"
        "fadeOut, 1, 1.46, almostLinear"
        "fade, 1, 3.03, quick"
        "layers, 1, 3.81, easeOutQuint"
        "layersIn, 1, 4, easeOutQuint, fade"
        "layersOut, 1, 1.5, linear, fade"
        "fadeLayersIn, 1, 1.79, almostLinear"
        "fadeLayersOut, 1, 1.39, almostLinear"
        "workspaces, 1, 1.94, almostLinear, fade"
        "workspacesIn, 1, 1.21, almostLinear, fade"
        "workspacesOut, 1, 1.94, almostLinear, fade"
      ];
    };

    input = {
      kb_layout = "us";
      repeat_delay = 300;
      repeat_rate = 50;
      follow_mouse = 1;
      sensitivity = 0;
    };

    monitor = [
      "DP-2,3440x1440@100,auto,auto"
    ];
    gestures = {
      workspace_swipe_distance = 500;
      workspace_swipe_invert = 1;
      workspace_swipe_min_speed_to_force = 30;
      workspace_swipe_cancel_ratio = 0.5;
      workspace_swipe_create_new = 1;
      workspace_swipe_forever = 1;
    };
    xwayland.force_zero_scaling = true;
    env = [
      "NIXOS_OZONE_WL, 1"
      "ELECTRON_OZONE_PLATFORM_HINT, auto"
      "WLR_NO_HARDWARE_CURSORS, 1"
      "NIXPKGS_ALLOW_UNFREE, 1"
      "LIBVA_DRIVER_NAME,nvidia"
      "GLX_VENDOR_LIBRARY_NAME,nvidia"
      "XDG_CURRENT_DESKTOP, Hyprland"
      "XDG_SESSION_TYPE, wayland"
      "XDG_SESSION_DESKTOP, Hyprland"
      "GDK_BACKEND, wayland, x11"
      "GDK_SCALE, 2"
      "NVIDIA_ANTI_FLICKER, true"
      "CLUTTER_BACKEND, wayland"
      "QT_QPA_PLATFORM=wayland;xcb"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
      "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
      "SDL_VIDEODRIVER, x11"
      "MOZ_ENABLE_WAYLAND, 1"
      "GDK_SCALE,1"
      "QT_SCALE_FACTOR,1"
      "EDITOR,nvim"
    ];
    exec-once = [
      "hyprctl setcursor Numix-Cursor 24"
    ];
    binde = [
      "ALTSHIFT,H,resizeactive,-150 0"
      "ALTSHIFT,J,resizeactive,0 150"
      "ALTSHIFT,K,resizeactive,0 -150"
      "ALTSHIFT,L,resizeactive,150 0"
    ];
    bind =
      [
        "$mod,q,killactive,"
        "$mod, o, exec, wofi"
        "$mod, b, exec, wofi-bluetooth"
        "ALTSHIFT, Return, exec, foot"
        "$mod,h,movefocus,l"
        "$mod,l,movefocus,r"
        "$mod,k,movefocus,u"
        "$mod,j,movefocus,d"
        ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        " ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPause, exec, playerctl play-pause"
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPrev, exec, playerctl previous"
        ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
        ",XF86MonBrightnessUp,exec,brightnessctl set +5%"
      ]
      ++ (
        builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = i + 1;
            in
            [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          ) 9
        )
      );
  };
}
