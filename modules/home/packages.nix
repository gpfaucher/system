{ pkgs, ... }: {
  home.packages = with pkgs; [
    # CLI
    networkmanagerapplet
    wlogout
    dunst
    brightnessctl
    eza
    nix-search
    killall
    xdg-utils
    playerctl
    pamixer
    ffmpeg
    unzip
    wget
    hyfetch
    ripgrep
    fzf
    hsetroot
    xclip
    tmux-sessionizer
    nnn
    rofi-wayland
    wlr-randr
    wl-clipboard
    evremap
    quickemu

    awscli2

    # IDE
    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.datagrip

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.monaspace

    # GUI
    zoom-us
    swaynotificationcenter
    foot
    vscode-fhs

    # Browsers
    firefox
    google-chrome
    floorp

    xdg-desktop-portal-hyprland
  ];
}
