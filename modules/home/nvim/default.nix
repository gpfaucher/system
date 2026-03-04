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

    extraPackages = with pkgs; [
      # LSP servers
      nil # Nix
      lua-language-server
      basedpyright # Python
      nodePackages.typescript-language-server
      rust-analyzer
      gopls
      terraform-ls

      # Formatters
      nixfmt
      nodePackages.prettier
      stylua
      shfmt
      ruff

      # Tools needed by plugins
      ripgrep
      fd
      gcc # treesitter compilation
      tree-sitter
    ];
  };

  # Symlink Lua config from flake repo (writable — instant iteration)
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/projects/system/modules/home/nvim/config";
}
