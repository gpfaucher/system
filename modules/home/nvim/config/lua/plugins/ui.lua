return {
  -- Base16 Ayu Dark theme (matches Stylix)
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("base16-ayu-dark")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "base16",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
    },
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>g", group = "git" },
        { "<leader>G", group = "git hunks" },
        { "<leader>n", group = "notes" },
        { "<leader>o", group = "opencode" },
        { "<leader>q", group = "quickfix" },
        { "<leader>s", group = "search" },
      })
    end,
  },
}
