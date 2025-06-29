_: {
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "Alt";
    general = {
      gaps_out = 15;
      gaps_in = 5;
      allow_tearing = false;
      layout = "master";
    };
    input = {
      # kb_layout = "us";
      # kb_options = "caps:swapescape";
      # kb_options = "ctrl:nocaps";

      repeat_delay = 300;
      repeat_rate = 50;

      follow_mouse = 1;

      sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
    };

    monitor = [
      "DP-2,3440x1440@100,auto,auto"
    ];
    gestures = {
      workspace_swipe = 1;
      workspace_swipe_fingers = 3;
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
      "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
      "GDK_SCALE,1"
      "QT_SCALE_FACTOR,1"
      "EDITOR,nvim"
    ];
    exec-once = [
      "waybar"
      "nm-applet"
      "blueman-applet"
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
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (
          builtins.genList
            (
              i:
              let
                ws = i + 1;
              in
              [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9
        )
      );
  };
}
