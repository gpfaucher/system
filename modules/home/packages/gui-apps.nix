{pkgs, ...}: {
  home.packages = with pkgs; [
    # Communication
    zoom-us
    protonmail-desktop
    # teams-for-linux

    # File managers and utilities
    xfce.thunar
    filezilla
    xpipe

    # Media and content
    obs-studio
    calibre

    # Productivity and task management
    ticktick
    todoist-electron
    bruno

    # VPN and network
    protonvpn-gui

    # Desktop portals
    xdg-desktop-portal-gtk

    # Theming and appearance
    lyra-cursors
    nwg-look

    # System utilities
    pavucontrol
    overskride
    swaynotificationcenter
    plymouth

    # AI and ML tools
    claude-code
    lmstudio

    # Display management
    hyprmon
  ];
}
