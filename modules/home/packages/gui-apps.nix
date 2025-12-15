{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Communication
    zoom-us
    protonmail-desktop
    thunderbird-latest-unwrapped

    # teams-for-linux

    # File managers and utilities
    filezilla
    xpipe

    # Media and content
    obs-studio
    calibre

    # Productivity and task management
    ticktick
    todoist-electron
    bruno
    obsidian

    # VPN and network
    protonvpn-gui

    # Desktop portals
    xdg-desktop-portal-gtk

    # Theming and appearance
    lyra-cursors

    # System utilities
    pavucontrol
    plymouth

    # GNOME utilities
    gnome-calculator
    gnome-system-monitor
    gnome-disk-utility
    file-roller
    loupe
    gnome-text-editor

    # AI and ML tools
    claude-code
    lmstudio
    antigravity-fhs

    # Display management
    hyprmon
  ];
}
