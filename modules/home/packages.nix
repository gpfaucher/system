{ pkgs, ... }:
{
  home.packages = with pkgs; [
    codex
    kmonad
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
    quickemu

    # Formatters for Neovim (conform.nvim)
    ruff
    black
    isort
    alejandra
    stylua
    nodePackages.prettier
    gofumpt
    gotools

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
