_: {
  networking = {
    networkmanager.enable = true;
    nameservers = ["9.9.9.9"];
  };

  # Disable WiFi power saving to prevent random disconnects
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
  '';
}
