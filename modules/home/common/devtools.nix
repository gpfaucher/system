{ pkgs, ... }:

{
  home.packages = with pkgs; [
    awscli2
    gh
    nodejs_22
    codex

    eza
    bat
    zoxide
    atuin
    fzf
    jq
    yq-go
    tldr
    duf
    dust
    procs
    btop
    yazi
    lazygit

    kubectl
    k9s
    kubernetes-helm
    kubectx
    kubectl-neat
    kubeseal
    stern
    argocd
    flux
    kubeconform
    kubescape
    skopeo
    cosign
    kustomize
    helmfile

    postgresql
    redis
    google-cloud-sdk

    bun
    python3
    go

    shellcheck
    shfmt
    black
    ruff
    prettier
    vscode-langservers-extracted
    yaml-language-server

    unzip
    wget
    curl
    htop
    tree
    yt-dlp

    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
}
