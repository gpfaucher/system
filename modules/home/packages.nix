{ pkgs, ... }: {
  home.packages = with pkgs; [
    # CLI
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

    # Fonts
    nerd-fonts.jetbrains-mono

    # GUI
    zoom-us
    obsidian
    foot
    firefox
  ];
}
