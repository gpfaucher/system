{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Systemd-boot configuration
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    editor = false; # Disable editor for security and faster boot
    consoleMode = "auto"; # Auto-detect best console mode
  };

  boot.loader.efi.canTouchEfiVariables = true;

  # Timeout to allow boot menu selection for dual-boot
  boot.loader.timeout = 5;

  # Mount Windows EFI partition for dual-boot auto-detection
  # systemd-boot auto-detects Windows when its EFI partition is accessible
  # Find Windows EFI UUID with: lsblk -o NAME,FSTYPE,UUID,MOUNTPOINT
  # Then add to hardware.nix:
  #   fileSystems."/boot/efi-windows" = {
  #     device = "/dev/disk/by-uuid/XXXX-XXXX";
  #     fsType = "vfat";
  #     options = [ "ro" "nofail" ];
  #   };

  # Initrd optimization - use systemd in initrd for faster boot
  boot.initrd = {
    verbose = false; # Less logging for faster boot
    systemd.enable = true; # Systemd-based initrd (faster than scripted)
  };

  # Kernel parameters for faster/quieter boot
  boot.kernelParams = [
    "video=efifb:nobgrt" # Hide firmware logo
    "quiet" # Reduce kernel messages
    "loglevel=3" # Only show errors
    "systemd.show_status=auto" # Show status only on slow boot
    "rd.udev.log_level=3" # Reduce udev logging in initrd
  ];

  # Console log level
  boot.consoleLogLevel = 3; # Only show errors and warnings

  # Faster entropy generation for crypto operations
  services.haveged.enable = true;

  # HiDPI console configuration
  console = {
    earlySetup = true;
    font = "ter-132n";
    packages = [ pkgs.terminus_font ];

    # Ayu dark theme colors
    # Format: black, red, green, yellow, blue, magenta, cyan, white (normal + bright)
    colors = [
      "0b0e14" # black (bg)
      "f07178" # red
      "aad94c" # green
      "ffb454" # yellow
      "59c2ff" # blue
      "d2a6ff" # magenta
      "95e6cb" # cyan
      "6c7380" # white (fg4)
      "3d424d" # bright black (gray)
      "ff3333" # bright red
      "b8cc52" # bright green
      "e6b673" # bright yellow
      "73d0ff" # bright blue
      "dfbfff" # bright magenta
      "95e6cb" # bright cyan
      "bfbdb6" # bright white (fg)
    ];
  };
}
