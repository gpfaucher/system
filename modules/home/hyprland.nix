{lib, ...}: {
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "ALT";

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
      ",preferred,auto,1" # Fallback: let kanshi handle specifics
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
      "LIBVA_DRIVER_NAME,radeonsi"
      # "__GLX_VENDOR_LIBRARY_NAME,nvidia"  # Only set when using nvidia-offload
      "XDG_CURRENT_DESKTOP, Hyprland"
      "XDG_SESSION_TYPE, wayland"
      "XDG_SESSION_DESKTOP, Hyprland"
      "GDK_BACKEND, wayland, x11"
      "GDK_SCALE,1"
      # "NVIDIA_ANTI_FLICKER, true"  # Only useful when NVIDIA is primary
      "CLUTTER_BACKEND, wayland"
      "QT_QPA_PLATFORM=wayland;xcb"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
      "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
      "SDL_VIDEODRIVER, x11"
      "MOZ_ENABLE_WAYLAND, 1"
      "QT_SCALE_FACTOR,1"
      "XCURSOR_SIZE,24"
      "XCURSOR_THEME,Adwaita"
      "EDITOR,nvim"
    ];
    binde = [
      # Existing floating window resize
      "SUPERSHIFT,H,resizeactive,-150 0"
      "SUPERSHIFT,J,resizeactive,0 150"
      "SUPERSHIFT,K,resizeactive,0 -150"
      "SUPERSHIFT,L,resizeactive,150 0"
      # Master layout split ratio (for tiled windows)
      "$mod CTRL,H,splitratio,-0.05"
      "$mod CTRL,L,splitratio,+0.05"
    ];
    bindm = [
      "$mod, mouse:272, movewindow" # ALT + left-click drag to move
      "$mod, mouse:273, resizewindow" # ALT + right-click drag to resize
    ];
    # Window rules for floating TUI apps
    windowrulev2 = [
      "float,title:^(btop)$"
      "size 80% 80%,title:^(btop)$"
      "center,title:^(btop)$"

      "float,title:^(bluetuith)$"
      "size 80% 80%,title:^(bluetuith)$"
      "center,title:^(bluetuith)$"

      "float,title:^(impala)$"
      "size 80% 80%,title:^(impala)$"
      "center,title:^(impala)$"
    ];

    bind =
      [
        "$mod,q,killactive,"
        "$mod, o, exec, wofi"
        "$mod, b, exec, wofi-bluetooth"
        "SUPER, Return, exec, ghostty"
        "$mod,h,movefocus,l"
        "$mod,l,movefocus,r"
        "$mod,k,movefocus,u"
        "$mod,j,movefocus,d"

        # Screenshots (grimblast)
        ", Print, exec, grimblast --notify copy area"
        "SHIFT, Print, exec, grimblast --notify save area"
        "CTRL, Print, exec, grimblast --notify copy output"
        "$mod, Print, exec, grimblast --notify copy window"

        # Session locking
        "$mod CTRL, l, exec, pidof waylock || waylock -fork-on-lock"

        # Clipboard history
        "$mod, v, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

        # Notification center
        "$mod, n, exec, swaync-client -t -sw"

        # Fullscreen and floating
        "$mod, f, fullscreen, 0"
        "$mod SHIFT, f, fullscreen, 1"
        "$mod, space, togglefloating,"

        # Workspace navigation
        "$mod, Tab, workspace, previous"
        "$mod SHIFT, Tab, movetoworkspace, previous"
        "$mod, grave, togglespecialworkspace, scratchpad"
        "$mod SHIFT, grave, movetoworkspace, special:scratchpad"

        # Floating TUI apps
        "$mod SHIFT, b, exec, ghostty --title=btop -e btop"
        "$mod SHIFT, t, exec, ghostty --title=bluetuith -e bluetuith"
        "$mod SHIFT, i, exec, ghostty --title=impala -e impala"

        # Quick reconnect to last bluetooth device
        "$mod CTRL, b, exec, bluetoothctl connect $(bluetoothctl devices Paired | head -1 | awk '{print $2}')"

        # Monitor/display management
        "$mod CTRL, m, exec, hyprctl keyword monitor eDP-1,3840x2400@60,0x0,2"
        "$mod CTRL SHIFT, m, exec, kanshictl reload"
        "$mod CTRL, d, exec, wdisplays"

        # Presentation mode - mirror laptop screen
        "$mod CTRL, p, exec, wl-mirror eDP-1"

        # Media keys
        ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
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
            i: let
              ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9
        )
      );
  };
}
