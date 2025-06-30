{ pkgs, ... }: {
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "external-dp1";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-1";
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "external-dp2";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-2";
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "external-dp3";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-3";
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "internal-only";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "3840x2400";
            scale = 1.666667;
            position = "0,0";
          }
        ];
      }
    ];
  };
}
