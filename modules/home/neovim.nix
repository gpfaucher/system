{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = false;
    withRuby = false;

    extraPackages = with pkgs; [
      fd
      ripgrep
      nixd
      nixfmt
    ];

    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      nvim-lspconfig
      (nvim-treesitter.withPlugins (parsers: [
        parsers.bash
        parsers.fish
        parsers.git_config
        parsers.git_rebase
        parsers.json
        parsers.lua
        parsers.markdown
        parsers.markdown_inline
        parsers.nix
        parsers.toml
        parsers.vim
        parsers.vimdoc
        parsers.yaml
      ]))
    ];

    initLua = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 250
      vim.opt.splitright = true
      vim.opt.splitbelow = true

      vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
      vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })

      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy = "flex",
          sorting_strategy = "ascending",
          layout_config = { prompt_position = "top" },
          file_ignore_patterns = { ".git/", "result", "node_modules/", ".direnv/" },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
      pcall(telescope.load_extension, "fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Search text" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
      vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
      vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })

      vim.lsp.config("nixd", {
        cmd = { "nixd" },
        filetypes = { "nix" },
        root_markers = { "flake.nix", ".git" },
        settings = {
          nixd = {
            formatting = { command = { "nixfmt" } },
          },
        },
      })
      vim.lsp.enable("nixd")

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
          vim.keymap.set("n", "gr", builtin.lsp_references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "bash", "fish", "json", "lua", "markdown", "nix", "toml", "vim", "yaml" },
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    '';
  };
}
