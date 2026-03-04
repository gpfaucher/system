return {
  -- Markdown inline editing
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown",
    opts = {
      mappings = {
        inline_surround_toggle = "gs",
        inline_surround_toggle_line = "gss",
        inline_surround_delete = "ds",
        inline_surround_change = "cs",
        link_add = "gl",
        link_follow = "gx",
        go_curr_heading = "]c",
        go_parent_heading = "]p",
        go_next_heading = "]]",
        go_prev_heading = "[[",
      },
      on_attach = function(bufnr)
        local map = vim.keymap.set
        map("n", "<leader>mc", function()
          local line = vim.api.nvim_get_current_line()
          local new_line
          if line:match("%- %[x%]") then
            new_line = line:gsub("%- %[x%]", "- [ ]")
          elseif line:match("%- %[ %]") then
            new_line = line:gsub("%- %[ %]", "- [x]")
          else
            return
          end
          vim.api.nvim_set_current_line(new_line)
        end, { buffer = bufnr, desc = "Toggle checkbox" })
      end,
    },
  },

  -- Table mode
  {
    "dhruvasagar/vim-table-mode",
    ft = "markdown",
    keys = {
      { "<leader>mt", "<cmd>TableModeToggle<cr>", desc = "Toggle table mode" },
    },
    init = function()
      vim.g.table_mode_corner = "|"
    end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = "cd app && npx --yes yarn install",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview" },
    },
  },

  -- Render markdown beautifully
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      heading = {
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
      },
      checkbox = {
        unchecked = { icon = "☐ " },
        checked = { icon = "☑ " },
      },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
    },
  },
}
