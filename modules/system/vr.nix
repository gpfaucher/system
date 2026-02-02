{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ADB support via NixOS module (handles udev rules automatically)
  programs.adb.enable = true;

  # Add user to adbusers group (required for ADB access)
  users.users.gabriel.extraGroups = [ "adbusers" ];

  # Additional udev rules for Meta Quest devices (belt and suspenders)
  services.udev.extraRules = ''
    # Meta Quest 3S / Quest 3 / Quest 2 / Quest Pro
    SUBSYSTEM=="usb", ATTR{idVendor}=="2833", MODE="0666", GROUP="adbusers"
    # Additional Meta/Oculus vendor IDs
    SUBSYSTEM=="usb", ATTR{idVendor}=="2d40", MODE="0666", GROUP="adbusers"
  '';

  # ALVR and VR tools
  environment.systemPackages = with pkgs; [
    alvr # Wireless VR streaming to Quest
    scrcpy # Screen mirror/control Android devices (useful for Quest setup)
  ];

  # Force ALVR to use system ADB instead of bundled version
  # This fixes the "adb could not be used" / re-downloading errors
  environment.sessionVariables = {
    ALVR_ADB_PATH = "${pkgs.android-tools}/bin/adb";
  };

  # Open firewall ports for ALVR
  # TCP 9943-9944: Control/handshake
  # UDP 9943-9944: Video/audio streaming
  networking.firewall = {
    allowedTCPPorts = [ 9943 9944 ];
    allowedUDPPorts = [ 9943 9944 ];
  };

  # Ensure fuse is available (ALVR may need it for certain operations)
  boot.kernelModules = [ "fuse" ];
}
