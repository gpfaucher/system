{ pkgs, ... }:

{
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    RuntimeMaxUse=100M
    MaxFileSec=7day
  '';

  services.smartd = {
    enable = true;
    autodetect = true;
    defaults.monitored = "-a -o on -S on -n standby,q -W 4,55,70";
    notifications = {
      wall.enable = true;
      x11.enable = false;
    };
  };

  environment.systemPackages = with pkgs; [
    smartmontools
  ];
}
