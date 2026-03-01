# Core Vim options
{ ... }:
{
  programs.nvf.settings.vim = {
    # Vim options
    options = {
      # Line numbers
      number = true;
      relativenumber = true;

      # Mouse and clipboard
      mouse = "a";
      clipboard = "unnamedplus";

      # Indentation
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      autoindent = true;
      smartindent = true;
      breakindent = true;

      # Search
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;
      inccommand = "split";

      # UI
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 10;
      showmode = false;
      splitright = true;
      splitbelow = true;
      list = true;
      # Fix #4: set listchars so `list = true` shows useful whitespace indicators
      listchars = "tab:» ,trail:·,nbsp:␣,extends:›,precedes:‹";
      termguicolors = true;

      # Performance
      updatetime = 250;
      timeoutlen = 300;
      ttimeoutlen = 10;

      # Persistence
      undofile = true;

      # Visual block beyond line end
      virtualedit = "block";
    };

    # Languages with LSP
    languages = {
      enableTreesitter = true;

      lua = {
        enable = true;
        lsp.enable = true;
      };

      ts = {
        enable = true;
        lsp.enable = true;
        lsp.servers = [ "ts_ls" ];
        # TypeScript-specific tooling (#16): enable error translator
        extensions.ts-error-translator.enable = true;
      };

      rust = {
        enable = true;
        lsp.enable = true;
      };

      go = {
        enable = true;
        lsp.enable = true;
      };

      python = {
        enable = true;
        lsp = {
          enable = true;
          servers = [ "basedpyright" ];
        };
      };

      nix = {
        enable = true;
        lsp.enable = true;
      };

      terraform = {
        enable = true;
        lsp.enable = true;
      };

      markdown = {
        enable = true;
        lsp.enable = true;
      };
    };
  };
}
