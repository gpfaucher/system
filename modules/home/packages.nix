{ pkgs, ... }: {
  home.packages = with pkgs; [

    # CLI
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
    solaar


    # GNOME
    gnomeExtensions.solaar-extension
    gnomeExtensions.appindicator
    gnomeExtensions.just-perfection
    gnomeExtensions.dash-to-panel
    gnomeExtensions.yakuake
    gnome-tweaks

    # Fonts
    nerd-fonts.jetbrains-mono

    # GUI
    zoom-us
    obsidian
    foot
    wpsoffice
    nautilus
    zed-editor
    vscode-fhs
    ticktick
    kdePackages.yakuake
    teams-for-linux

    # Browsers
    firefox
    google-chrome
  ];
}
