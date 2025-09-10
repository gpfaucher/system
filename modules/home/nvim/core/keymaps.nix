{
  programs.nixvim = {
    keymaps = [
      {
        key = "<leader>sf";
        action = "<cmd>Telescope find_files<cr>";
        options = {
          desc = "Find Files";
          silent = true;
        };
      }
      {
        key = "<leader>sg";
        action = "<cmd>Telescope live_grep<cr>";
        options = {
          desc = "Live Grep";
          silent = true;
        };
      }
      {
        key = "<leader>sb";
        action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
        options = {
          desc = "Search in Buffer";
          silent = true;
        };
      }
      {
        key = "<leader>sh";
        action = "<cmd>Telescope help_tags<cr>";
        options = {
          desc = "Help Tags";
          silent = true;
        };
      }
      {
        key = "<leader>sm";
        action = "<cmd>Telescope man_pages<cr>";
        options = {
          desc = "Man Pages";
          silent = true;
        };
      }
      {
        key = "<leader><space>";
        action = "<cmd>Telescope buffers<cr>";
        options = {
          desc = "List Buffers";
          silent = true;
        };
      }
      {
        key = "<leader>gc";
        action = "<cmd>Telescope git_commits<cr>";
        options = {
          desc = "Git Commits";
          silent = true;
        };
      }
      # Added tmux-sessionizer keymaps
      {
        key = "<C-f>";
        action = "<cmd>silent !tmux neww tms<CR>";
        options = {
          desc = "Tmux Sessionizer";
          silent = true;
        };
      }
      {
        key = "<M-h>";
        action = "<cmd>silent !tmux neww tms -s 0<CR>";
        options = {
          desc = "Tmux Sessionizer Session 0";
          silent = true;
        };
      }
      {
        key = "<M-t>";
        action = "<cmd>silent !tmux neww tms -s 1<CR>";
        options = {
          desc = "Tmux Sessionizer Session 1";
          silent = true;
        };
      }
      {
        key = "<M-n>";
        action = "<cmd>silent !tmux neww tms -s 2<CR>";
        options = {
          desc = "Tmux Sessionizer Session 2";
          silent = true;
        };
      }
      {
        key = "<M-s>";
        action = "<cmd>silent !tmux neww tms -s 3<CR>";
        options = {
          desc = "Tmux Sessionizer Session 3";
          silent = true;
        };
      }
      # Undotree keymaps
      {
        key = "<leader>u";
        action = "<cmd>UndotreeToggle<cr>";
        options = {
          desc = "Toggle Undotree";
          silent = true;
        };
      }
      # Buffer diagnostics keymaps
      {
        key = "<leader>dn";
        action = "<cmd>lua vim.diagnostic.goto_next()<cr>";
        options = {
          desc = "Next Diagnostic";
          silent = true;
        };
      }
      {
        key = "<leader>dp";
        action = "<cmd>lua vim.diagnostic.goto_prev()<cr>";
        options = {
          desc = "Previous Diagnostic";
          silent = true;
        };
      }
      {
        key = "<leader>dq";
        action = "<cmd>lua vim.diagnostic.setloclist()<cr>";
        options = {
          desc = "Diagnostic Quickfix";
          silent = true;
        };
      }
      {
        key = "<leader>df";
        action = "<cmd>Telescope diagnostics<cr>";
        options = {
          desc = "Find Diagnostics";
          silent = true;
        };
      }
    ];
  };
}
