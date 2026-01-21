{ config, pkgs, lib, ... }:

{
  # rEFInd bootloader
  boot.loader.refind.enable = true;

  # EFI support
  boot.loader.efi.canTouchEfiVariables = true;

  # Clean boot - hide firmware logo
  boot.kernelParams = [ "video=efifb:nobgrt" ];

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
