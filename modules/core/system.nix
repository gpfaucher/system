_: {
  services.mullvad-vpn.enable = true;

  # Power management for better battery life
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        turbo = "auto";
        scaling_min_freq = 1400000;
        scaling_max_freq = 2800000;
      };
    };
  };

  # Lid switch behavior
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "gabriel"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = ["en_US.UTF-8/UTF-8"];

  environment.variables.EDITOR = "nvim";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "Europe/Amsterdam";
  system.stateVersion = "24.05";
}
