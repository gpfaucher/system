return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({})
    telescope.load_extension("fzf")
  end,
  keys = {
    { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search buffer" },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<leader><space>", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
    { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
  },
}
