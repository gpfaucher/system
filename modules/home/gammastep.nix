_: {
  services.gammastep = {
    enable = true;
    provider = "manual";
    # Amsterdam area coordinates
    latitude = 52.37;
    longitude = 4.90;
    temperature = {
      day = 6500;
      night = 3500;
    };
    tray = false;
    settings = {
      general = {
        fade = 1;
        adjustment-method = "wayland";
      };
    };
  };
}
