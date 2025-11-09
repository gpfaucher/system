{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # System monitoring and management
    htop
    btop
    bluetuith
    lazydocker
    impala
    hyfetch
    networkmanagerapplet

    # File and text utilities
    ripgrep
    fzf
    eza
    nnn
    xclip
    wl-clipboard

    # Task and productivity
    taskwarrior3
    nix-search
    codex
    gemini-cli
    opencode

    # Terminal multiplexers and session managers
    tmux-sessionizer
    zellij

    # Wayland/X utilities
    brightnessctl
    dunst
    wlogout
    hsetroot
    rofi
    wlr-randr
    quickemu
    autorandr
    arandr

    # Utilities
    ngrok
  ];
}
