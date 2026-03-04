return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lspconfig = require("lspconfig")

      -- Shared on_attach
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end

        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gr", vim.lsp.buf.references, "Go to references")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gy", vim.lsp.buf.type_definition, "Go to type definition")
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("<leader>r", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")

        -- Visual mode code action
        vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
      end

      -- Diagnostics config
      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = true },
      })

      -- Diagnostic keymaps
      vim.keymap.set("n", "<leader>dn", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
      vim.keymap.set("n", "<leader>dp", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev diagnostic" })
      vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Float diagnostic" })

      -- Server configs (all binaries provided by Nix on PATH)
      local servers = {
        nil_ls = {},
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        basedpyright = {},
        ts_ls = {},
        rust_analyzer = {},
        gopls = {},
        terraformls = {},
      }

      for server, config in pairs(servers) do
        config.on_attach = on_attach
        lspconfig[server].setup(config)
      end
    end,
  },

  -- Trouble (diagnostics list)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
    },
    opts = {},
  },
}
