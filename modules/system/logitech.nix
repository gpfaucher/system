{ pkgs, ... }:

{
  # Logitech wireless device support (HID++ protocol)
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true; # Solaar GUI for device management
  };
}
