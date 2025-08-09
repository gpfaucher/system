_: {
  services.kanshi = {
    enable = true;
    settings = [
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
          }
        ];
      }
    ];
  };
}
