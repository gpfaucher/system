{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Essential system tools
    git
    wget
    killall
    xdg-utils
    ffmpeg
    unzip

    # Power management and monitoring
    powertop
    acpi
  ];
}
