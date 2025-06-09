return {
  {
    'neovim/nvim-lspconfig',
    cmd = 'LspInfo',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'j-hui/fidget.nvim', opts = {} },
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require('mason').setup {}
      local mason_lspconfig = require('mason-lspconfig')

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'fish',
        callback = function()
          vim.lsp.start({
            name = 'fish-lsp',
            cmd = { 'fish-lsp', 'start' },
            cmd_env = { fish_lsp_show_client_popups = true },
          })
        end,
      })

      mason_lspconfig.setup({
        ensure_installed = { "lua_ls", "ts_ls", "jsonls", "bashls", "marksman", "yamlls", "texlab" },
        automatic_enable = true
      })
    end
  },
  {
    'nvimdev/lspsaga.nvim',
    after = 'nvim-lspconfig',
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = { buffer = event.buf, noremap = true }
          vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc<cr>', opts)
          vim.keymap.set('n', 'gd', '<cmd>Lspsaga goto_definition<cr>', opts)
          vim.keymap.set('n', 'gi', '<cmd>Lspsaga finder<cr>', opts)
          vim.keymap.set('n', 'go', '<cmd>Lspsaga goto_type_definition<cr>', opts)
          vim.keymap.set('n', 'gr', '<cmd>Lspsaga rename<cr>', opts)
          vim.keymap.set('n', 'ca', '<cmd>Lspsaga code_action<cr>', opts)
        end,
      })

      require('lspsaga').setup({
        symbol_in_winbar = {
          enable = false
        },
        lightbulb = {
          virtual_text = false
        }
      })
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
