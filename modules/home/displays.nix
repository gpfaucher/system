_: {
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "pc";
        profile.outputs = [
          {
            criteria = "Microstep MSI MAG342CQR DB6H261C02187";
            mode = "3440x1440@144.00";
          }
        ];
      }
      {
        profile.name = "work_1";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "AOC U34V5C 1QDQ6HA000288";
            mode = "3440x1440@100.00";
          }
        ];
      }
      {
        profile.name = "wfh";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Microstep MSI MAG342CQR DB6H261C02187";
            mode = "3440x1440@100.00";
          }
        ];
      }
      {
        profile.name = "laptop";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 2.00;
          }
        ];
      }
    ];
  };
}
