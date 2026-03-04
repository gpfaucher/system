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
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    editor = false; # Security
    consoleMode = "auto";
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.timeout = 5;

  boot.initrd = {
    verbose = false;
    systemd.enable = true;
  };

  boot.kernelParams = [
    "video=efifb:nobgrt" # Hide firmware logo
    "quiet" # Reduce kernel messages
    "loglevel=3" # Only show errors
    "systemd.show_status=auto" # Show status only on slow boot
    "rd.udev.log_level=3" # Reduce udev logging in initrd
    "consoleblank=0" # Disable VT console blanking (prevents grey screen on Wayland)
  ];

  boot.consoleLogLevel = 3;

  services.haveged.enable = true;

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
