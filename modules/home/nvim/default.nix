{
  pkgs,
  config,
  inputs,
  ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.neovim-unwrapped;
    vimAlias = true;
    viAlias = true;
    withPython3 = true;
    withRuby = true;

    extraPackages = with pkgs; [
      # LSP servers
      nil
      lua-language-server
      basedpyright
      typescript-language-server
      rust-analyzer
      gopls
      terraform-ls

      # Formatters
      nixfmt
      nodejs_22
      stylua
      shfmt
      ruff

      # Tools needed by plugins
      ripgrep
      fd
      gcc
      tree-sitter
    ];
  };

  # Symlink Lua config from flake repo (writable — instant iteration)
  home.file.".config/nvim".source = "${inputs.self}/modules/home/nvim/config";
}
