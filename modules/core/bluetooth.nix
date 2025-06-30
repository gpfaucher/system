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
        KernelExperimental = true;
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
      };
      LE = {
        EnableAdvMonInterleaveScan = true;
      };
    };
  };
  
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];
}
