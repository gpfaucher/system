{
  config,
  pkgs,
  lib,
  ...
}:

let
  c = config.lib.stylix.colors;
in
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
    "resume_offset=69935729" # btrfs swap file physical offset for hibernate resume
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

    # Console colors generated from Stylix base16 scheme
    # Format: black, red, green, yellow, blue, magenta, cyan, white (normal + bright)
    colors = [
      "${c.base00}" # black (bg)
      "${c.base08}" # red
      "${c.base0B}" # green
      "${c.base0A}" # yellow
      "${c.base0D}" # blue
      "${c.base0E}" # magenta
      "${c.base0C}" # cyan
      "${c.base04}" # white (muted fg)
      "${c.base03}" # bright black (gray)
      "${c.base08}" # bright red
      "${c.base0B}" # bright green
      "${c.base09}" # bright yellow (orange)
      "${c.base0D}" # bright blue
      "${c.base0E}" # bright magenta
      "${c.base0C}" # bright cyan
      "${c.base05}" # bright white (fg)
    ];
  };
}
