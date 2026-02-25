{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  # Display hotplug script — X11 equivalent of the old kanshi profiles.
  # Detects connected outputs and applies the matching xrandr layout.
  display-switch = pkgs.writeShellScript "display-switch" ''
    set -euo pipefail
    sleep 1 # debounce rapid udev events

    export DISPLAY=":0"
    export XAUTHORITY="/home/gabriel/.Xauthority"

    XRANDR="${pkgs.xorg.xrandr}/bin/xrandr"
    NOTIFY="${pkgs.libnotify}/bin/notify-send"
    HSETROOT="${pkgs.hsetroot}/bin/hsetroot"

    info=$($XRANDR)
    hdmi=$(echo "$info" | grep "^HDMI" | grep " connected" | head -1 | ${pkgs.gawk}/bin/awk '{print $1}') || true
    dp=$(echo "$info" | grep "^DP" | grep " connected" | head -1 | ${pkgs.gawk}/bin/awk '{print $1}') || true
    edp="eDP-1"

    # Turn off any disconnected outputs first
    for out in $(echo "$info" | grep " disconnected" | ${pkgs.gawk}/bin/awk '{print $1}'); do
      $XRANDR --output "$out" --off 2>/dev/null || true
    done

    if [ -n "$hdmi" ] && [ -n "$dp" ]; then
      # Dual external: portrait DP + ultrawide HDMI (laptop disabled)
      $XRANDR \
        --output "$dp" --mode 2560x1440 --rate 60 --pos 0x0 --rotate left \
        --output "$hdmi" --primary --mode 3440x1440 --rate 100 --pos 1440x0 --rotate normal \
        --output "$edp" --off
      $NOTIFY "Display Profile" "Dual monitor: Portrait + Ultrawide" 2>/dev/null || true
    elif [ -n "$dp" ]; then
      # Single DP external (laptop disabled)
      $XRANDR \
        --output "$dp" --primary --auto --rotate normal \
        --output "$edp" --off
      $NOTIFY "Display Profile" "External DP" 2>/dev/null || true
    elif [ -n "$hdmi" ]; then
      # Single HDMI external (laptop disabled)
      $XRANDR \
        --output "$hdmi" --primary --auto --rotate normal \
        --output "$edp" --off
      $NOTIFY "Display Profile" "External HDMI" 2>/dev/null || true
    else
      # No external monitors — enable laptop display
      $XRANDR --output "$edp" --primary --mode 3840x2400 --rate 60 --pos 0x0 --dpi 192
      $NOTIFY "Display Profile" "Laptop display" 2>/dev/null || true
    fi

    # Refresh wallpaper after layout change
    $HSETROOT -solid "#202020" 2>/dev/null || true
  '';
in
{
  imports = [
    ./hardware.nix
    ../../modules/system/bootloader.nix
    # GPU: offload mode (AMD primary, NVIDIA on-demand)
    ../../modules/system/graphics.nix
    ../../modules/system/networking.nix
    ../../modules/system/audio.nix
    ../../modules/system/services.nix
    ../../modules/system/hardening.nix
    ../../modules/system/vr.nix
    ../../modules/system/dwm.nix
  ];

  # Hostname
  networking.hostName = "laptop";

  # Stylix NixOS-level config (needed for DWM config.h color substitution)
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";

  # Enable Nix flakes and experimental features
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;

      # Parallel build optimization
      max-jobs = "auto"; # Use all available CPU cores for parallel builds
      cores = 0; # Use all cores per individual build job

      # Download optimization
      http-connections = 25; # Parallel download connections (default is 25)

      # Build caching optimization
      keep-outputs = true; # Keep build outputs for faster rebuilds
      keep-derivations = true; # Keep .drv files for better caching

      # Tarball caching
      tarball-ttl = 300; # Cache downloaded tarballs for 5 minutes

      # Binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://ghostty.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d"; # Extended retention for safer rollbacks
    };
  };

  # Font configuration
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.enable = true;
  };

  # User configuration
  users.users.gabriel = {
    isNormalUser = true;
    home = "/home/gabriel";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager" # For NetworkManager wireless management
      "input"
      "docker"
    ];
  };

  # Enable fish shell system-wide
  programs.fish.enable = true;

  # X11 + DWM (custom patched build from home-manager module)
  services.xserver.enable = true;
  services.xserver.windowManager.dwm.enable = true;
  services.displayManager.defaultSession = "none+dwm";

  # Display manager: LightDM with slick greeter
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.slick = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "breeze_cursors";
      };
      extraConfig = ''
        draw-user-backgrounds=false
        font-name=Monaspace Neon 11
        show-hostname=false
      '';
    };
  };

  # Display hotplug: systemd service triggered by udev on monitor plug/unplug.
  # Replicates the old kanshi profile-switching behavior for X11.
  systemd.services.display-switch = {
    description = "Display hotplug handler (X11 kanshi replacement)";
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${display-switch}";
      User = "gabriel";
    };
  };
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", TAG+="systemd", ENV{SYSTEMD_WANTS}="display-switch.service"
  '';

  # XDG portal for X11 (screensharing via x11 backend)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  # Steam gaming platform
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Steam dedicated servers
  };

  # Gamemode for performance optimization while gaming
  programs.gamemode.enable = true;

  # Screen locker (NixOS module sets up suid wrapper)
  programs.slock.enable = true;

  # NixOS state version - do not change after initial install
  system.stateVersion = "24.11";
}
