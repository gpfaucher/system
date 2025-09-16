{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zlib
    graphite-cli
    kdePackages.xdg-desktop-portal-kde
    xdg-desktop-portal-gtk
    ticktick
    ngrok
    protonmail-desktop
    xfce.thunar
    obs-studio
    lyra-cursors
    nwg-look
    calibre
    neovide
    libgcc
    alacritty
    plymouth
    docker-buildx
    overskride
    mesa-demos
    teams-for-linux
    lmstudio
    pavucontrol
    filezilla
    gemini-cli
    opencode
    zellij
    autorandr
    arandr
    xpipe
    todoist-electron

    # CLI
    networkmanagerapplet
    wlogout
    dunst
    brightnessctl
    nix-search
    hyfetch
    hsetroot
    xclip
    rofi
    wlr-randr
    wl-clipboard
    evremap
    quickemu

    awscli2

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.monaspace

    # GUI
    zoom-us
    swaynotificationcenter
    foot

    # Browsers
    firefox
    google-chrome
  ];
}
