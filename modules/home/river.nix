{
  config,
  pkgs,
  lib,
  ...
}: let
  colors = config.lib.stylix.colors;

  # Screenshot scripts (grim + slurp for wlroots)
  screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    grim -g "$(slurp)" - | wl-copy
    notify-send "Screenshot" "Area copied to clipboard"
  '';
  screenshot-screen = pkgs.writeShellScriptBin "screenshot-screen" ''
    grim - | wl-copy
    notify-send "Screenshot" "Screen copied to clipboard"
  '';
  screenshot-save = pkgs.writeShellScriptBin "screenshot-save" ''
    mkdir -p ~/Pictures/Screenshots
    grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png
    notify-send "Screenshot" "Saved to ~/Pictures/Screenshots"
  '';

  # Keybind cheatsheet
  river-keybinds = pkgs.writeShellScriptBin "river-keybinds" ''
    cat << 'EOF' | fuzzel --dmenu --prompt "Keybinds: "
━━━ WINDOWS ━━━
Super + H/J/K/L       Focus left/down/up/right
Super + Shift + HJKL  Swap window
Super + Q             Close window
Super + F             Fullscreen
Super + Space         Toggle float

━━━ LAYOUT ━━━
Super + Ctrl + H/L    Shrink/grow master
Super + M             Monocle layout
Super + T             Tiled layout
Super + Tab           Toggle layout

━━━ WORKSPACES ━━━
Super + 1-9           Switch workspace
Super + Shift + 1-9   Move to workspace
Super + 0             View all
Super + `             Scratchpad
Super + Shift + `     Move to scratchpad

━━━ APPS ━━━
Super + Return        Terminal (ghostty)
Super + A             App launcher (fuzzel)
Super + B             Firefox
Super + E             File manager (yazi)
Super + Shift + B     btop
Super + Shift + T     bluetuith
Super + Shift + I     impala (wifi)

━━━ SCREENSHOTS ━━━
Print                 Area → clipboard
Ctrl + Print          Screen → clipboard
Shift + Print         Area → save
Super + Shift + S     Area → clipboard

━━━ SYSTEM ━━━
Super + V             Clipboard history
Super + Escape        Lock screen
Super + Shift + E     Power menu
Super + N             Dismiss notification
Super + Shift + N     Dismiss all notifications
Super + Slash         This cheatsheet

━━━ DISPLAY ━━━
Super + Ctrl + D      Display settings
Super + Ctrl + M      Reload kanshi
Super + Ctrl + P      Mirror screen

━━━ MOUSE ━━━
Super + Left Click    Move window
Super + Right Click   Resize window
Super + Middle Click  Toggle float
EOF
  '';
in {
  wayland.windowManager.river = {
    enable = true;
    xwayland.enable = true;

    settings = {
      border-width = 2;
      set-cursor-warp = "on-focus-change";

      spawn = [
        # Layout generator (wideriver - dwm/xmonad style)
        "'wideriver --layout left --stack dwindle --count-master 1 --ratio-master 0.55 --border-width 2 --border-width-monocle 0'"

        # Wallpaper
        "wpaperd"

        # Notifications
        "fnott"

        # Clipboard watchers
        "'wl-paste --type text --watch cliphist store'"
        "'wl-paste --type image --watch cliphist store'"

        # Night light
        "gammastep"

        # Network/Bluetooth tray
        "'nm-applet --indicator'"
        "blueman-applet"

        # Polkit agent
        "'${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1'"

        # Idle management with screen fade before lock
        "'swayidle -w timeout 300 \"chayang && waylock\" timeout 600 \"systemctl suspend\" before-sleep \"waylock\"'"

        # Auto display management
        "kanshi"
      ];

      # Input configuration
      input = {
        "*" = {
          accel-profile = "flat";
          tap = "enabled";
          natural-scroll = "enabled";
        };
        "type:keyboard" = {
          repeat-delay = "250";
          repeat-rate = "30";
        };
      };

      # Window rules
      rule-add = {
        "-app-id" = {
          "'btop'" = "float";
          "'bluetuith'" = "float";
          "'impala'" = "float";
          "'pavucontrol'" = "float";
          "'nm-connection-editor'" = "float";
          "'.blueman-*'" = "float";
          "'org.gnome.Calculator'" = "float";
        };
      };
    };

    extraConfig = ''
      # === Mod Key ===
      mod="Super"

      # === Border Colors (Stylix) ===
      riverctl border-color-focused 0x${colors.base0D}
      riverctl border-color-unfocused 0x${colors.base02}
      riverctl border-color-urgent 0x${colors.base08}

      # === Window Focus (vim-style) ===
      riverctl map normal $mod H focus-view left
      riverctl map normal $mod J focus-view down
      riverctl map normal $mod K focus-view up
      riverctl map normal $mod L focus-view right

      # === Window Swap ===
      riverctl map normal $mod+Shift H swap left
      riverctl map normal $mod+Shift J swap down
      riverctl map normal $mod+Shift K swap up
      riverctl map normal $mod+Shift L swap right

      # === Window Actions ===
      riverctl map normal $mod Q close
      riverctl map normal $mod F toggle-fullscreen
      riverctl map normal $mod Space toggle-float

      # === Layout Control (wideriver) ===
      riverctl map normal $mod+Control H send-layout-cmd wideriver "--ratio -0.05"
      riverctl map normal $mod+Control L send-layout-cmd wideriver "--ratio +0.05"
      riverctl map normal $mod M send-layout-cmd wideriver "--layout monocle"
      riverctl map normal $mod T send-layout-cmd wideriver "--layout left"
      riverctl map normal $mod Tab send-layout-cmd wideriver "--layout-toggle"

      # === Tags (Workspaces 1-9) ===
      for i in $(seq 1 9); do
          tags=$((1 << ($i - 1)))
          riverctl map normal $mod $i set-focused-tags $tags
          riverctl map normal $mod+Shift $i set-view-tags $tags
          riverctl map normal $mod+Control $i toggle-focused-tags $tags
          riverctl map normal $mod+Control+Shift $i toggle-view-tags $tags
      done

      # All tags (tag 0 = all)
      all_tags=$(((1 << 9) - 1))
      riverctl map normal $mod 0 set-focused-tags $all_tags
      riverctl map normal $mod+Shift 0 set-view-tags $all_tags

      # === Scratchpad ===
      scratch_tag=$((1 << 20))
      riverctl map normal $mod Grave toggle-focused-tags $scratch_tag
      riverctl map normal $mod+Shift Grave set-view-tags $scratch_tag
      all_but_scratch=$(( ((1 << 32) - 1) ^ $scratch_tag ))
      riverctl spawn-tagmask $all_but_scratch

      # === App Launchers ===
      riverctl map normal $mod Return spawn ghostty
      riverctl map normal $mod A spawn fuzzel
      riverctl map normal $mod B spawn firefox
      riverctl map normal $mod E spawn "ghostty -e yazi"

      # === Screenshots (grim + slurp) ===
      riverctl map normal None Print spawn screenshot-area
      riverctl map normal $mod+Shift S spawn screenshot-area
      riverctl map normal Control Print spawn screenshot-screen
      riverctl map normal Shift Print spawn screenshot-save

      # === Clipboard History ===
      riverctl map normal $mod V spawn 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'

      # === Screen Lock ===
      riverctl map normal $mod Escape spawn 'chayang && waylock'

      # === Power Menu ===
      riverctl map normal $mod+Shift E spawn wlogout

      # === Floating TUI Apps ===
      riverctl map normal $mod+Shift B spawn "ghostty --title=btop -e btop"
      riverctl map normal $mod+Shift T spawn "ghostty --title=bluetuith -e bluetuith"
      riverctl map normal $mod+Shift I spawn "ghostty --title=impala -e impala"

      # === Display Management ===
      riverctl map normal $mod+Control D spawn wdisplays
      riverctl map normal $mod+Control M spawn "kanshictl reload"
      riverctl map normal $mod+Control P spawn "wl-mirror eDP-1"

      # === Notification Control ===
      riverctl map normal $mod N spawn "fnottctl dismiss"
      riverctl map normal $mod+Shift N spawn "fnottctl dismiss all"

      # === Keybind Cheatsheet ===
      riverctl map normal $mod Slash spawn river-keybinds

      # === Media Keys ===
      riverctl map normal None XF86AudioRaiseVolume spawn 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+'
      riverctl map normal None XF86AudioLowerVolume spawn 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'
      riverctl map normal None XF86AudioMute spawn 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'
      riverctl map normal None XF86AudioMicMute spawn 'wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'
      riverctl map normal None XF86AudioPlay spawn 'playerctl play-pause'
      riverctl map normal None XF86AudioPause spawn 'playerctl play-pause'
      riverctl map normal None XF86AudioNext spawn 'playerctl next'
      riverctl map normal None XF86AudioPrev spawn 'playerctl previous'
      riverctl map normal None XF86MonBrightnessUp spawn 'brightnessctl set +5%'
      riverctl map normal None XF86MonBrightnessDown spawn 'brightnessctl set 5%-'

      # === Mouse Bindings ===
      riverctl map-pointer normal $mod BTN_LEFT move-view
      riverctl map-pointer normal $mod BTN_RIGHT resize-view
      riverctl map-pointer normal $mod BTN_MIDDLE toggle-float

      # === Focus follows mouse ===
      riverctl focus-follows-cursor normal

      # === Default layout generator ===
      riverctl default-layout wideriver
    '';

    extraSessionVariables = {
      XDG_CURRENT_DESKTOP = "river";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "river";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      GDK_BACKEND = "wayland,x11";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";

      # NVIDIA hybrid graphics (use iGPU by default for battery)
      WLR_NO_HARDWARE_CURSORS = "1";
      LIBVA_DRIVER_NAME = "radeonsi";

      # Cursor
      XCURSOR_SIZE = "24";
      XCURSOR_THEME = "Adwaita";
    };
  };

  # Required packages for River setup
  home.packages = with pkgs; [
    # Layout generator
    wideriver

    # Screenshots
    grim
    slurp
    screenshot-area
    screenshot-screen
    screenshot-save
    river-keybinds

    # Clipboard
    wl-clipboard
    cliphist

    # Lock & Idle
    waylock
    swayidle
    chayang

    # Wallpaper
    wpaperd

    # Display management
    kanshi
    wdisplays
    wlr-randr
    wl-mirror

    # Power menu
    wlogout

    # Polkit
    polkit_gnome

    # Tray apps
    networkmanagerapplet
    blueman

    # Portals
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk

    # Utilities
    playerctl
    brightnessctl
    libnotify
  ];
}
