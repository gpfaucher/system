{ pkgs, ... }: {
  home.packages = with pkgs; [
    # CLI
    eza
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

    # Fonts
    nerd-fonts.jetbrains-mono

    # GUI
    zoom-us
    obsidian
    foot
    firefox
  ];
}
