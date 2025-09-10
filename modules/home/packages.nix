{ pkgs, ... }:
{
  home.packages = with pkgs; [
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
    rofi-wayland
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
    floorp
  ];
}
