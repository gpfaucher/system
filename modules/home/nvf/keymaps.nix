# Keymaps configuration
# Fix #24: all keymaps use silent = true and <cmd> form
{ pkgs, ... }:
{
  programs.nvf.settings.vim = {
    keymaps = [
      # Window navigation
      {
        key = "<C-h>";
        mode = "n";
        action = "<C-w>h";
        desc = "Focus left window";
        silent = true;
      }
      {
        key = "<C-j>";
        mode = "n";
        action = "<C-w>j";
        desc = "Focus below window";
        silent = true;
      }
      {
        key = "<C-k>";
        mode = "n";
        action = "<C-w>k";
        desc = "Focus above window";
        silent = true;
      }
      {
        key = "<C-l>";
        mode = "n";
        action = "<C-w>l";
        desc = "Focus right window";
        silent = true;
      }

      # Window resize (#17)
      {
        key = "<C-Up>";
        mode = "n";
        action = "<cmd>resize +2<cr>";
        desc = "Increase window height";
        silent = true;
      }
      {
        key = "<C-Down>";
        mode = "n";
        action = "<cmd>resize -2<cr>";
        desc = "Decrease window height";
        silent = true;
      }
      {
        key = "<C-Left>";
        mode = "n";
        action = "<cmd>vertical resize -2<cr>";
        desc = "Decrease window width";
        silent = true;
      }
      {
        key = "<C-Right>";
        mode = "n";
        action = "<cmd>vertical resize +2<cr>";
        desc = "Increase window width";
        silent = true;
      }

      # Buffer navigation
      {
        key = "<S-h>";
        mode = "n";
        action = "<cmd>bprevious<cr>";
        desc = "Previous buffer";
        silent = true;
      }
      {
        key = "<S-l>";
        mode = "n";
        action = "<cmd>bnext<cr>";
        desc = "Next buffer";
        silent = true;
      }
      {
        key = "<leader>bd";
        mode = "n";
        action = "<cmd>bdelete<cr>";
        desc = "Delete buffer";
        silent = true;
      }

      # Quick save
      {
        key = "<C-s>";
        mode = [
          "n"
          "i"
          "v"
        ];
        action = "<cmd>w<cr>";
        desc = "Save file";
        silent = true;
      }

      # Center after movements
      {
        key = "<C-d>";
        mode = "n";
        action = "<C-d>zz";
        desc = "Scroll down centered";
        silent = true;
      }
      {
        key = "<C-u>";
        mode = "n";
        action = "<C-u>zz";
        desc = "Scroll up centered";
        silent = true;
      }
      {
        key = "n";
        mode = "n";
        action = "nzzzv";
        desc = "Next search centered";
        silent = true;
      }
      {
        key = "N";
        mode = "n";
        action = "Nzzzv";
        desc = "Previous search centered";
        silent = true;
      }

      # Quickfix
      {
        key = "]q";
        mode = "n";
        action = "<cmd>cnext<cr>";
        desc = "Next quickfix";
        silent = true;
      }
      {
        key = "[q";
        mode = "n";
        action = "<cmd>cprev<cr>";
        desc = "Previous quickfix";
        silent = true;
      }
      {
        key = "<leader>qq";
        mode = "n";
        action = "<cmd>copen<cr>";
        desc = "Open quickfix";
        silent = true;
      }
      {
        key = "<leader>qc";
        mode = "n";
        action = "<cmd>cclose<cr>";
        desc = "Close quickfix";
        silent = true;
      }

      # Clear search highlight
      {
        key = "<Esc>";
        mode = "n";
        action = "<cmd>nohlsearch<cr>";
        desc = "Clear search highlight";
        silent = true;
      }

      # Telescope keymaps
      {
        key = "<leader>sf";
        mode = "n";
        action = "<cmd>Telescope find_files<cr>";
        desc = "Find files";
        silent = true;
      }
      {
        key = "<leader>sg";
        mode = "n";
        action = "<cmd>Telescope live_grep<cr>";
        desc = "Live grep";
        silent = true;
      }
      {
        key = "<leader>sb";
        mode = "n";
        action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
        desc = "Search buffer";
        silent = true;
      }
      {
        key = "<leader>sh";
        mode = "n";
        action = "<cmd>Telescope help_tags<cr>";
        desc = "Help tags";
        silent = true;
      }
      {
        key = "<leader><space>";
        mode = "n";
        action = "<cmd>Telescope buffers<cr>";
        desc = "Buffers";
        silent = true;
      }
      # Fix #23: add Telescope diagnostics keymap
      {
        key = "<leader>sd";
        mode = "n";
        action = "<cmd>Telescope diagnostics<cr>";
        desc = "Diagnostics";
        silent = true;
      }
      {
        key = "<leader>gc";
        mode = "n";
        action = "<cmd>Telescope git_commits<cr>";
        desc = "Git commits";
        silent = true;
      }
      {
        key = "<leader>gs";
        mode = "n";
        action = "<cmd>Telescope git_status<cr>";
        desc = "Git status";
        silent = true;
      }

      # Oil file browser
      {
        key = "<leader>f";
        mode = "n";
        action = "<cmd>Oil --float<cr>";
        desc = "File browser";
        silent = true;
      }

      # Notes keybindings
      {
        key = "<leader>ni";
        mode = "n";
        action = "<cmd>edit ~/notes/inbox.md<cr>";
        desc = "Notes inbox";
        silent = true;
      }
      {
        key = "<leader>nt";
        mode = "n";
        action = "<cmd>edit ~/notes/todo.md<cr>";
        desc = "Notes todo";
        silent = true;
      }
      {
        key = "<leader>nf";
        mode = "n";
        action = "<cmd>Telescope find_files cwd=~/notes<cr>";
        desc = "Find notes";
        silent = true;
      }
      {
        key = "<leader>ng";
        mode = "n";
        action = "<cmd>Telescope live_grep cwd=~/notes<cr>";
        desc = "Grep notes";
        silent = true;
      }

      # Lazygit
      {
        key = "<leader>gg";
        mode = "n";
        action = "<cmd>LazyGit<cr>";
        desc = "LazyGit";
        silent = true;
      }

      # Format keymap (#8)
      {
        key = "<leader>cf";
        mode = [ "n" "v" ];
        action = "<cmd>lua require('conform').format({ async = true, lsp_format = 'fallback' })<cr>";
        desc = "Format buffer";
        silent = true;
      }
    ];

    # Which-key and notes Lua blocks
    extraPlugins = with pkgs.vimPlugins; {
      # Which-key for keybind hints
      which-key-nvim = {
        package = which-key-nvim;
        setup = ''
          require("which-key").setup({
            plugins = {
              marks = true,
              registers = true,
              spelling = {
                enabled = false,
              },
              presets = {
                operators = true,
                motions = true,
                text_objects = true,
                windows = true,
                nav = true,
                z = true,
                g = true,
              },
            },
            win = {
              border = "rounded",
              padding = { 1, 2 },
            },
            layout = {
              spacing = 3,
              align = "center",
            },
            show_help = true,
            show_keys = true,
          })

          -- Register which-key group descriptions
          local wk = require("which-key")
          wk.add({
            { "<leader>b", group = "Buffer" },
            { "<leader>c", group = "Code" },
            { "<leader>d", group = "Diagnostics/Debug" },
            { "<leader>f", group = "File" },
            { "<leader>g", group = "Git" },
            { "<leader>G", group = "Git Hunks" },
            { "<leader>h", group = "Harpoon" },
            { "<leader>m", group = "Markdown" },
            { "<leader>n", group = "Notes" },
            { "<leader>o", group = "OpenCode" },
            { "<leader>q", group = "Quickfix" },
            { "<leader>s", group = "Search" },
            { "<leader>x", group = "Trouble" },
          })
        '';
      };
    };

    luaConfigRC = {
      # Notes: quick capture to inbox
      notes-capture = ''
        vim.keymap.set("n", "<leader>nc", function()
          local line = vim.fn.input("Capture: ")
          if line ~= "" then
            local file = io.open(os.getenv("HOME") .. "/notes/inbox.md", "a")
            if file then
              file:write("- " .. line .. "\n")
              file:close()
              print("Captured to inbox")
            end
          end
        end, { desc = "Capture to inbox", silent = true })
      '';

      # Notes: toggle checkbox (Fix #5: unified, works everywhere, not just markdown)
      notes-checkbox = ''
        vim.keymap.set("n", "<leader>nx", function()
          local line = vim.api.nvim_get_current_line()
          local new_line
          if line:match("%- %[ %]") then
            new_line = line:gsub("%- %[ %]", "- [x]", 1)
          elseif line:match("%- %[x%]") then
            new_line = line:gsub("%- %[x%]", "- [ ]", 1)
          else
            return
          end
          vim.api.nvim_set_current_line(new_line)
        end, { desc = "Toggle checkbox", silent = true })
      '';
    };
  };
}
