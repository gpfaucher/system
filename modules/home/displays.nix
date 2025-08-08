_: {
  services.kanshi = {
    enable = true;
    profiles = {
      wfh = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Microstep MSI MAG342CQR DB6H261C02187";
            mode = "3440x1440@100.00";
          }
        ];
      };
      laptop = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      };
    };
  };
}
