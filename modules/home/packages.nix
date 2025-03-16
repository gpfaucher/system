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
    google-drive-ocamlfuse
    nnn
    rofi-wayland

    # Fonts
    nerd-fonts.jetbrains-mono

    # GUI
    zoom-us
    obsidian
    mullvad-browser
    foot
  ];
}
