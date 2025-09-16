{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Development tools
    git
    wget
    direnv
    devenv
    gh
    python312Packages.bugwarrior
    zig
    # ollama

    # IDEs
    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.datagrip
    vscode-fhs
    zed-editor-fhs
    lapce

    # CLI tools
    htop
    ripgrep
    fzf
    eza
    tmux-sessionizer
    nnn
    taskwarrior3

    # System tools
    killall
    xdg-utils
    ffmpeg
    unzip
  ];
}
