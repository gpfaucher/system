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

    # Gruvbox dark theme colors
    # Format: black, red, green, yellow, blue, magenta, cyan, white (normal + bright)
    colors = [
      "282828" # black (bg)
      "cc241d" # red
      "98971a" # green
      "d79921" # yellow
      "458588" # blue
      "b16286" # magenta
      "689d6a" # cyan
      "a89984" # white (fg4)
      "928374" # bright black (gray)
      "fb4934" # bright red
      "b8bb26" # bright green
      "fabd2f" # bright yellow
      "83a598" # bright blue
      "d3869b" # bright magenta
      "8ec07c" # bright cyan
      "ebdbb2" # bright white (fg)
    ];
  };
}
