{ pkgs, ... }:
{
  home.packages = with pkgs; [
    filezilla
    gemini-cli
    opencode
    zellij
    alacritty
    ghostty
    todoist-electron

    # CLI
    networkmanagerapplet
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
    ripgrep
    fzf
    hsetroot
    tmux-sessionizer
    nnn
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
    sway
    swaybg
    swaylock
    wofi

    # Browsers
    firefox
    google-chrome
    floorp

    xdg-desktop-portal-wlr
    pkgs.teams
    pkgs.kanshi
  ];
}
