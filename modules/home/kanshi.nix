{
  services.kanshi = {
    enable = true;
    profiles = {
      "laptop-only" = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      };
      "docked" = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-1";
            status = "enable";
            mode = "2560x1440@144Hz";
          }
        ];
      };
    };
  };
}
