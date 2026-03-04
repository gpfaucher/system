return {
  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]c", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[c", function() gs.nav_hunk("prev") end, "Prev hunk")

        -- Actions
        map("n", "<leader>Gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>Gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>Gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
        map("v", "<leader>Gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
        map("n", "<leader>GS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>Gu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>Gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>Gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>Gd", gs.diffthis, "Diff this")
        map("n", "<leader>Gt", gs.toggle_deleted, "Toggle deleted")
      end,
    },
  },

  -- Lazygit
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Lazygit" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
