{ pkgs, ... }:
{
  services.blueman.enable = true;
  hardware.logitech.wireless.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
  
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];
}
