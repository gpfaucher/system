{pkgs, ...}: {
  home.packages = with pkgs; [
    # IDEs
    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.datagrip
    jetbrains.goland
    vscode-fhs
    zed-editor-fhs
    lapce
    neovide

    # Language runtimes and tools
    go
    zig
    postgresql
    nodejs_22
    bun
    python312Packages.bugwarrior

    # Development tools
    devenv
    direnv
    gh
    git-lfs
    act
    moon
    graphite-cli
    docker-buildx
    awscli2

    # Formatters (for Neovim conform.nvim)
    ruff
    black
    isort
    alejandra
    stylua
    nodePackages.prettier
    gofumpt
    gotools

    # LSP and language servers
    nil

    # Build tools
    zlib
    libgcc
    mesa-demos
  ];
}
