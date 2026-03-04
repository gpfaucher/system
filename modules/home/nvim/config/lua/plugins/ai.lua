return {
  -- OpenCode.nvim
  {
    "nickjvandyke/opencode.nvim",
    keys = {
      { "<leader>oo", function() require("opencode").menu() end, desc = "OpenCode menu" },
      { "<leader>oa", function() require("opencode").ask() end, desc = "OpenCode ask" },
      { "<leader>oe", function() require("opencode").explain() end, desc = "OpenCode explain" },
      { "<leader>or", function() require("opencode").review() end, desc = "OpenCode review" },
      { "<leader>of", function() require("opencode").fix() end, desc = "OpenCode fix" },
      { "<leader>ot", function() require("opencode").test() end, desc = "OpenCode test" },
      { "<leader>oi", function() require("opencode").implement() end, desc = "OpenCode implement" },
      { "<leader>op", function() require("opencode").optimize() end, desc = "OpenCode optimize" },
      { "<leader>oc", function() require("opencode").document() end, desc = "OpenCode document" },
      { "<leader>od", function() require("opencode").diagnostics() end, desc = "OpenCode diagnostics" },
      { "<leader>og", function() require("opencode").git_diff_review() end, desc = "OpenCode git diff" },
    },
    dependencies = { "folke/snacks.nvim" },
    opts = {},
  },

  -- Claude Code integration (MCP-based)
  {
    "coder/claudecode.nvim",
    keys = {
      { "<leader>cc", "<cmd>ClaudeCodeStart<cr>", desc = "Claude Code start" },
    },
    opts = {},
  },
}
