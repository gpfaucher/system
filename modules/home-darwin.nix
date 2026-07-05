{ pkgs, lib, config, ... }:
{
  imports = [
    ./home/nvim
    ./home/terminal.nix
    ./home/tmux.nix
    ./home/ssh.nix
    ./home/zed.nix
    ./home/vscode.nix ];

  home = {
    homeDirectory = "/Users/gabrielfaucher";
    stateVersion = "23.05";
  };

  home.packages = with pkgs; [
    # CLI tools
    git
    eza
    fzf
    jq
    zoxide
    atuin
    yq-go
    tldr
    duf
    dust
    procs
    btop

    # Cloud & container tooling
    gh
    kubectl
    k9s
    kubernetes-helm
    awscli2
    google-cloud-sdk

    # Databases
    postgresql
    redis

    # Languages & runtimes
    nodejs_22
    bun
    python3
    go

    # Dev tools
    shellcheck
    shfmt
    black
    ruff
    prettier

    # Utilities
    unzip
    wget
    curl
    htop
    tree
    # neovide # TODO: build fails on Darwin (needs OpenGL)
    yt-dlp

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
}