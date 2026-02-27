{
  config,
  pkgs,
  lib,
  ...
}:

let
  colors = config.lib.stylix.colors;

  # Monitor hotplug script: disable laptop when externals are connected
  handleMonitorChange = pkgs.writeShellScriptBin "handle-monitor-change" ''
    handle() {
      case "$1" in
        monitoradded*|monitorremoved*)
          external_count=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq '[.[] | select(.name != "eDP-1")] | length')
          if [ "$external_count" -gt 0 ]; then
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1, disable"
          else
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1, 3840x2400@60, auto, 2"
          fi
          # Restart Eww bars on correct monitors
          ${pkgs.eww}/bin/eww close-all
          sleep 0.5
          ${pkgs.eww}/bin/eww open bar
          ;;
      esac
    }

    ${pkgs.socat}/bin/socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while IFS= read -r line; do
      handle "$line"
    done
  '';
in
{
  imports = [
    ./dunst.nix
    ./fuzzel.nix
    ./hyprlock.nix
    ./eww
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # ── Monitors ──
      monitor = [
        # Known externals (matched by EDID description)
        "desc:MSI MAG342CQR, 3440x1440@100, auto, 1"
        "desc:MSI G272QPF, 2560x1440@60, auto-left, 1, transform, 1"

        # Laptop panel (fallback when no externals)
        "eDP-1, 3840x2400@60, auto, 2"

        # Unknown displays: auto-configure at preferred resolution
        ", preferred, auto, 1"
      ];

      # ── General ──
      general = {
        gaps_in = 10;
        gaps_out = 20;
        border_size = 3;
        layout = "master";
        allow_tearing = false;
      };

      # ── Master layout ──
      master = {
        mfact = 0.55;
        new_status = "slave";
        orientation = "left";
      };

      # ── Dwindle layout ──
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # ── Decoration ──
      decoration = {
        rounding = 12;

        blur = {
          enabled = true;
          size = 4;
          passes = 2;
          new_optimizations = true;
        };

        active_opacity = 1.0;
        inactive_opacity = 0.95;
      };

      # ── Animations ──
      animations = {
        enabled = true;
        bezier = "ease, 0.25, 0.1, 0.25, 1.0";
        animation = [
          "windows, 1, 4, ease"
          "windowsOut, 1, 4, ease, popin 80%"
          "border, 1, 6, default"
          "fade, 1, 4, ease"
          "workspaces, 1, 4, ease"
        ];
      };

      # ── Input ──
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };

      # ── Gestures ──
      gestures = {
        workspace_swipe = true;
      };

      # ── Misc ──
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        focus_on_activate = true;
      };

      # ── Cursor ──
      cursor = {
        no_hardware_cursors = true;
      };

      # ── Window rules ──
      windowrulev2 = [
        # Scratchpad
        "float, class:^(scratchpad)$"
        "size 80% 80%, class:^(scratchpad)$"
        "center, class:^(scratchpad)$"

        # Floating apps
        "float, class:^(zoom)$"
        "float, class:^(Gimp)$"
        "float, class:^(gimp)$"
        "float, class:^(Steam)$"
        "float, class:^(steam)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(Blueman-manager)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(Nm-connection-editor)$"
        "float, class:^(pavucontrol)$"
        "float, class:^(Pavucontrol)$"
        "float, class:^(.blueman-manager-wrapped)$"
        "float, class:^(org.pulseaudio.pavucontrol)$"

        # Fullscreen opacity
        "opacity 1.0 override, fullscreen:1"

        # Video call opacity
        "opacity 1.0 override, class:^(zoom)$"
        "opacity 1.0 override, class:^(teams-for-linux)$"
        "opacity 1.0 override, class:^(Google-chrome)$"
        "opacity 1.0 override, class:^(firefox)$, focus:1"
      ];

      # ── Variables ──
      "$mod" = "SUPER";

      # ── Keybindings ──
      bind = [
        # Spawn
        "$mod, Return, exec, ghostty"
        "$mod, d, exec, fuzzel"
        "$mod SHIFT, l, exec, hyprlock"

        # Screenshots (grimblast)
        "$mod, Print, exec, grimblast copy output"
        "$mod SHIFT, Print, exec, grimblast copy area"

        # Clipboard history
        "$mod, v, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"

        # Scratchpad
        "$mod, grave, togglespecialworkspace, scratch"

        # Window management
        "$mod, q, killactive"
        "$mod, j, layoutmsg, cyclenext"
        "$mod, k, layoutmsg, cycleprev"
        "$mod SHIFT, j, layoutmsg, swapnext"
        "$mod SHIFT, k, layoutmsg, swapprev"
        "$mod, z, layoutmsg, swapwithmaster master"
        "$mod, Tab, workspace, previous"

        # Master count
        "$mod, i, layoutmsg, addmaster"
        "$mod SHIFT, i, layoutmsg, removemaster"

        # Centered master toggle
        "$mod, u, layoutmsg, orientationcycle left center"

        # Layouts
        "$mod, t, exec, hyprctl keyword general:layout master"
        "$mod, r, exec, hyprctl keyword general:layout dwindle"

        # Floating / fullscreen
        "$mod, space, togglefloating"
        "$mod, f, fullscreen, 0"
        "$mod, m, fullscreen, 1"
        "$mod, s, pin"

        # Toggle bar
        "$mod, b, exec, eww close bar || eww open bar"

        # Gaps
        "$mod ALT, equal, exec, hyprctl keyword general:gaps_in $(( $(hyprctl getoption general:gaps_in -j | jq '.int') + 1 )) && hyprctl keyword general:gaps_out $(( $(hyprctl getoption general:gaps_out -j | jq '.int') + 2 ))"
        "$mod ALT, minus, exec, hyprctl keyword general:gaps_in $(( $(hyprctl getoption general:gaps_in -j | jq '.int') - 1 )) && hyprctl keyword general:gaps_out $(( $(hyprctl getoption general:gaps_out -j | jq '.int') - 2 ))"
        "$mod ALT, 0, exec, hyprctl keyword general:gaps_in 0 && hyprctl keyword general:gaps_out 0"
        "$mod ALT SHIFT, 0, exec, hyprctl keyword general:gaps_in 10 && hyprctl keyword general:gaps_out 20"

        # All tags
        "$mod, 0, focusworkspaceoncurrentmonitor, 10"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Monitors
        "$mod, comma, focusmonitor, -1"
        "$mod, period, focusmonitor, +1"
        "$mod SHIFT, comma, movewindow, mon:-1"
        "$mod SHIFT, period, movewindow, mon:+1"

        # Manual laptop screen override
        "$mod CTRL, comma, exec, hyprctl keyword monitor 'eDP-1, disable'"
        "$mod CTRL, period, exec, hyprctl keyword monitor 'eDP-1, 3840x2400@60, auto, 2'"

        # Workspaces 1-9
        "$mod, 1, focusworkspaceoncurrentmonitor, 1"
        "$mod, 2, focusworkspaceoncurrentmonitor, 2"
        "$mod, 3, focusworkspaceoncurrentmonitor, 3"
        "$mod, 4, focusworkspaceoncurrentmonitor, 4"
        "$mod, 5, focusworkspaceoncurrentmonitor, 5"
        "$mod, 6, focusworkspaceoncurrentmonitor, 6"
        "$mod, 7, focusworkspaceoncurrentmonitor, 7"
        "$mod, 8, focusworkspaceoncurrentmonitor, 8"
        "$mod, 9, focusworkspaceoncurrentmonitor, 9"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Quit / reload
        "$mod SHIFT, q, exit"
        "$mod SHIFT, r, exec, hyprctl reload"
      ];

      # Resize with Super+h/l
      binde = [
        "$mod, h, resizeactive, -50 0"
        "$mod, l, resizeactive, 50 0"

        # Media keys (repeatable)
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
      ];

      # Locked keys (work even when locked / no input inhibitor)
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # ── Autostart ──
      exec-once = [
        # Scratchpad terminal
        "ghostty --class=scratchpad"

        # Tray applets
        "nm-applet --indicator"
        "blueman-applet"

        # Clipboard manager
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"

        # Wallpaper (solid Gruvbox bg)
        "swaybg -m solid_color -c '#${colors.base00}'"

        # Polkit agent
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"

        # Monitor hotplug handler
        "${handleMonitorChange}/bin/handle-monitor-change"

        # Hyprland special workspace for scratchpad
        "hyprctl dispatch movetoworkspacesilent special:scratch,class:^(scratchpad)$"

        # Eww bar
        "eww open bar"
      ];
    };
  };

  # Packages needed for the Hyprland environment
  home.packages = with pkgs; [
    # Wayland clipboard
    wl-clipboard
    cliphist

    # Screenshots
    grimblast
    grim
    slurp

    # Wallpaper
    swaybg

    # System tray applets
    blueman
    networkmanagerapplet

    # Audio / brightness / media
    pavucontrol
    wireplumber
    brightnessctl
    playerctl

    # Display tools
    wlr-randr

    # Polkit
    polkit_gnome

    # Utilities for hotplug script
    socat
    jq
  ];
}
