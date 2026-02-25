{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

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

  # Autorandr: runtime-managed display profiles with udev hotplug detection.
  # Profiles are saved at runtime, not declaratively:
  #   1. Set up your displays with xrandr
  #   2. Save: autorandr --save <name>
  #   3. The "laptop" profile is the fallback (defaultTarget)
  #
  # First boot: connect only laptop screen, then run: autorandr --save laptop
  services.autorandr = {
    enable = true;
    defaultTarget = "laptop";

    hooks.postswitch = {
      "refresh-wallpaper" = "${pkgs.hsetroot}/bin/hsetroot -solid '#202020'";
      "notify" = "${pkgs.libnotify}/bin/notify-send 'Display Profile' 'Switched display layout'";
    };
  };

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
