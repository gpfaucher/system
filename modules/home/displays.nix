_: {
  services.kanshi = {
    enable = true;
    # Profiles are evaluated in order. The first one where all output
    # criteria match a connected display will be activated.
    settings = [
      # Most specific profiles first
      {
        profile.name = "msi-ultrawide";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Microstep MSI MAG342CQR *";
            mode = "3440x1440@144.00";
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "aoc-ultrawide";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            # Using the specific connector is slightly more robust
            criteria = "DP-1";
            mode = "3440x1440@100.000000Hz"; # Using the exact refresh rate from wlr-randr
            position = "0,0";
          }
        ];
      }

      # Generic external display fallbacks
      {
        profile.name = "external-display";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-*";
            status = "enable";
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "external-hdmi";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "HDMI-*";
            status = "enable";
            position = "0,0";
          }
        ];
      }

      # Laptop only profile - This is the crucial fallback.
      # It will be matched ONLY when eDP-1 is the only connected display from the ones defined.
      {
        profile.name = "laptop-only";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            # --- KEY CHANGE ---
            # The 'mode' is intentionally removed. This tells the compositor
            # to use the display's preferred mode, which is more reliable.
            scale = 2.00;
            position = "0,0";
            transform = "normal"; # It's good practice to be explicit
          }
        ];
      }
      # The second, identical 'fallback-laptop-only' profile is redundant and has been removed.
    ];
  };
}
