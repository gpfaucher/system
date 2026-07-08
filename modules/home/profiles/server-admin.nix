{ pkgs, ... }:

{
  home.packages = with pkgs; [
    restic
    kubectl
    k9s
    kubernetes-helm
    flux
    age
    sops
    jq
    yq-go
    curl
    wget
    htop
    tree
  ];
}
