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
        key = "<C-o>";
        action = "<cmd>silent !tmux neww tms<CR>";
        options = {
          desc = "Tmux Sessionizer (Ctrl-o)";
          silent = true;
        };
      }
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
      # Quickfix navigation and toggles
      {
        key = "]q";
        action = "<cmd>cnext<cr>";
        options = { desc = "Quickfix Next"; silent = true; };
      }
      {
        key = "[q";
        action = "<cmd>cprev<cr>";
        options = { desc = "Quickfix Prev"; silent = true; };
      }
      {
        key = "<leader>qq";
        action = "<cmd>copen<cr>";
        options = { desc = "Quickfix Open"; silent = true; };
      }
      {
        key = "<leader>qc";
        action = "<cmd>cclose<cr>";
        options = { desc = "Quickfix Close"; silent = true; };
      }
      # Lazygit
      {
        key = "<leader>gg";
        action = ":LazyGit<cr>";
        options = { desc = "LazyGit"; silent = true; };
      }
      # Taskwarrior helpers
      {
        key = "<leader>tt";
        action.__raw = ''function()
          vim.cmd('vsplit')
          vim.cmd('terminal task next')
        end'';
        options = { desc = "Tasks: Next"; silent = true; };
      }
      {
        key = "<leader>ta";
        action.__raw = ''function()
          vim.ui.input({ prompt = 'Task add: ' }, function(input)
            if input and #input > 0 then
              vim.system({ 'task', 'add', input }, { text = true }, function() end)
            end
          end)
        end'';
        options = { desc = "Tasks: Add"; silent = true; };
      }
      {
        key = "<leader>td";
        action.__raw = ''function()
          vim.ui.input({ prompt = 'Task done (ID): ' }, function(id)
            if id and #id > 0 then
              vim.system({ 'task', id, 'done' }, { text = true }, function() end)
            end
          end)
        end'';
        options = { desc = "Tasks: Done"; silent = true; };
      }
      {
        key = "<leader>tp";
        action.__raw = ''function()
          vim.ui.input({ prompt = 'Project filter: ' }, function(project)
            if project and #project > 0 then
              vim.cmd('vsplit')
              vim.cmd('terminal task project:' .. project .. ' next')
            end
          end)
        end'';
        options = { desc = "Tasks: Project"; silent = true; };
      }
      # Removed Trouble.nvim mappings
      # Telescope Frecency
      {
        key = "<leader>sr";
        action = "<cmd>Telescope frecency<cr>";
        options = { desc = "Recent Files"; silent = true; };
      }
      # Flash.nvim
      {
        key = "s";
        mode = "n";
        action = "<cmd>lua require('flash').jump()<cr>";
        options = { desc = "Flash Jump"; silent = true; };
      }
      {
        key = "S";
        mode = "n";
        action = "<cmd>lua require('flash').treesitter()<cr>";
        options = { desc = "Flash TS"; silent = true; };
      }
    ];
  };
}
