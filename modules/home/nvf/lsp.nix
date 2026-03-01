# LSP, diagnostics, and Telescope configuration
{ ... }:
{
  programs.nvf.settings.vim = {
    # Global LSP enable
    lsp.enable = true;

    luaConfigRC = {
      # Telescope configuration for hidden files
      # Fix #7: use vim.schedule to ensure this runs after nvf's own Telescope setup
      telescope-config = ''
        vim.schedule(function()
          local ok, telescope = pcall(require, "telescope")
          if ok then
            telescope.setup({
              defaults = {
                hidden = true,  -- Show hidden files (dotfiles)
                file_ignore_patterns = {
                  "%.git/",
                  "node_modules/",
                  "%.automaker/",
                  "%.beads/",
                  "%.worktrees/",
                  "%.direnv/",
                  "%.devenv/",
                  "%.cache/",
                  "__pycache__/",
                  "%.mypy_cache/",
                  "%.ruff_cache/",
                  "%.pytest_cache/",
                  "target/",         -- Rust/Java build output
                  "dist/",
                  "%.next/",
                  "%.terraform/",
                },
              },
              pickers = {
                find_files = {
                  hidden = true,
                  no_ignore = false,
                },
                live_grep = {
                  additional_args = function()
                    return {"--hidden"}
                  end,
                },
              },
            })
          end
        end)
      '';

      # LSP attach keymaps (Fix #21: added visual mode for code_action)
      lsp-keymaps = ''
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local map = function(modes, keys, func, desc)
              vim.keymap.set(modes, keys, func, { buffer = args.buf, desc = desc, silent = true })
            end
            map("n", "gd", vim.lsp.buf.definition, "Go to definition")
            map("n", "gr", vim.lsp.buf.references, "References")
            map("n", "gi", vim.lsp.buf.implementation, "Implementation")
            map("n", "gD", vim.lsp.buf.declaration, "Declaration")
            map("n", "gy", vim.lsp.buf.type_definition, "Type definition")
            map("n", "K", vim.lsp.buf.hover, "Hover")
            map("n", "<leader>r", vim.lsp.buf.rename, "Rename")
            -- Fix #21: code action available in both normal and visual mode
            map({"n", "v"}, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          end,
        })
      '';

      # Diagnostic configuration (Fix #2: source = true instead of "always")
      diagnostic-config = ''
        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
          float = {
            border = "rounded",
            source = true,
            header = "",
            prefix = "",
          },
        })

        -- Show diagnostics on hover (CursorHold)
        vim.api.nvim_create_autocmd("CursorHold", {
          callback = function()
            local opts = {
              focusable = false,
              close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
              border = "rounded",
              source = true,
              prefix = " ",
              scope = "cursor",
            }
            vim.diagnostic.open_float(nil, opts)
          end
        })
      '';

      # Diagnostic keymaps (Fix #1: use vim.diagnostic.jump instead of deprecated goto_next/goto_prev)
      diagnostic-keymaps = ''
        vim.keymap.set("n", "<leader>dn", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic", silent = true })
        vim.keymap.set("n", "<leader>dp", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic", silent = true })
        vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Float diagnostic", silent = true })
      '';

      # Gitsigns keymaps (#15)
      # Uses GitSignsAttach autocmd to add buffer-local keymaps without
      # conflicting with nvf's own gitsigns.setup() call
      gitsigns-keymaps = ''
        vim.api.nvim_create_autocmd("User", {
          pattern = "GitSignsAttach",
          callback = function(args)
            local bufnr = args.buf
            local gs = require("gitsigns")
            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              opts.silent = true
              vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map("n", "]c", function()
              if vim.wo.diff then return "]c" end
              vim.schedule(function() gs.nav_hunk("next") end)
              return "<Ignore>"
            end, { expr = true, desc = "Next hunk" })

            map("n", "[c", function()
              if vim.wo.diff then return "[c" end
              vim.schedule(function() gs.nav_hunk("prev") end)
              return "<Ignore>"
            end, { expr = true, desc = "Previous hunk" })

            -- Actions
            map("n", "<leader>Gs", gs.stage_hunk, { desc = "Stage hunk" })
            map("n", "<leader>Gr", gs.reset_hunk, { desc = "Reset hunk" })
            map("v", "<leader>Gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage hunk" })
            map("v", "<leader>Gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset hunk" })
            map("n", "<leader>GS", gs.stage_buffer, { desc = "Stage buffer" })
            map("n", "<leader>Gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
            map("n", "<leader>GR", gs.reset_buffer, { desc = "Reset buffer" })
            map("n", "<leader>Gp", gs.preview_hunk, { desc = "Preview hunk" })
            map("n", "<leader>Gb", function() gs.blame_line({ full = true }) end, { desc = "Blame line (full)" })
            map("n", "<leader>Gd", gs.diffthis, { desc = "Diff this" })
            map("n", "<leader>GD", function() gs.diffthis("~") end, { desc = "Diff this (~)" })
            map("n", "<leader>Gt", gs.toggle_deleted, { desc = "Toggle deleted" })

            -- Text object
            map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
          end,
        })
      '';
    };
  };
}
