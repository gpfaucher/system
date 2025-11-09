{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Essential system tools
    git
    wget
    direnv
    devenv
    killall
    xdg-utils
    ffmpeg
    unzip

    # CLI tools
    htop
    fzf
    eza
    taskwarrior3

    # Power management and monitoring
    powertop      # Detailed power consumption analysis
    acpi          # Quick battery status
  ];
}
