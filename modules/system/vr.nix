{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Meta Quest 3S / VR Support
  
  # Udev rules for Meta Quest devices
  services.udev.extraRules = ''
    # Meta Quest 3S / Quest 3 / Quest 2 / Quest Pro
    SUBSYSTEM=="usb", ATTR{idVendor}=="2833", MODE="0666", GROUP="adbusers"
    # Additional Meta/Oculus vendor IDs
    SUBSYSTEM=="usb", ATTR{idVendor}=="2d40", MODE="0666", GROUP="adbusers"
  '';

  # ALVR for wireless PC VR streaming
  # Note: ALVR dashboard runs on port 8082 by default
  # Note: programs.adb removed - systemd 258 handles uaccess rules automatically
  environment.systemPackages = with pkgs; [
    alvr # Wireless VR streaming to Quest
    android-tools # ADB and fastboot
    scrcpy # Screen mirror/control Android devices
  ];

  # Open firewall ports for ALVR
  networking.firewall = {
    allowedTCPPorts = [ 9943 9944 ]; # ALVR control ports
    allowedUDPPorts = [ 9943 9944 ]; # ALVR streaming ports
  };
}
