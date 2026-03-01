# Markdown plugins and configuration
# Fix #22: Dropped vim-markdown + tabular since Treesitter handles syntax
# highlighting and render-markdown.nvim handles rendering. Kept frontmatter
# support via Treesitter parsers. This removes 2 plugins while keeping all
# practical functionality.
{ pkgs, ... }:
{
  programs.nvf.settings.vim = {
    extraPlugins = with pkgs.vimPlugins; {
      # 1. markdown.nvim - Modern inline editing tools
      # Fix #5: removed duplicate <leader>mc checkbox toggle (use <leader>nx globally)
      # Fix #6: fixed smart list continuation for ordered lists
      markdown-nvim = {
        package = pkgs.vimPlugins.markdown-nvim;
        setup = ''
          require("markdown").setup({
            mappings = {
              inline_surround_toggle = "gs",
              inline_surround_delete = "ds",
              inline_surround_change = "cs",
              link_add = "gl",
              link_follow = "gx",
              go_curr_heading = "]h",
              go_parent_heading = "]p",
              go_next_heading = "]]",
              go_prev_heading = "[[",
            },
            on_attach = function(bufnr)
              local map = vim.keymap.set
              local opts = { buffer = bufnr, silent = true }

              -- Checkbox toggle via MDTaskToggle (markdown-aware)
              map("n", "<leader>mc", "<Cmd>MDTaskToggle<CR>", vim.tbl_extend("force", opts, { desc = "Toggle markdown checkbox" }))

              -- List operations (Ctrl+Enter for new list item)
              map("i", "<C-CR>", "<Cmd>MDListItemBelow<CR>", vim.tbl_extend("force", opts, { desc = "New list item below" }))

              -- Fix #6: smart list continuation that handles ordered lists correctly
              map("n", "o", function()
                local line = vim.api.nvim_get_current_line()
                -- Ordered list: increment the number
                local indent, num, dot_or_paren = line:match("^(%s*)(%d+)([.)]%s)")
                if indent and num and dot_or_paren then
                  local next_num = tostring(tonumber(num) + 1)
                  vim.api.nvim_put({indent .. next_num .. dot_or_paren}, "l", true, true)
                  vim.cmd("startinsert!")
                  return
                end
                -- Unordered list: copy the bullet prefix
                local prefix = line:match("^(%s*[-*+]%s)")
                if prefix then
                  vim.api.nvim_put({prefix}, "l", true, true)
                  vim.cmd("startinsert!")
                  return
                end
                -- Default: normal o behavior
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("o", true, false, true), "n", false)
              end, vim.tbl_extend("force", opts, { desc = "Smart list continuation" }))
            end,
          })
        '';
      };

      # 2. vim-table-mode - Smart table formatting
      vim-table-mode = {
        package = pkgs.vimPlugins.vim-table-mode;
        setup = ''
          -- Use markdown-compatible tables
          vim.g.table_mode_corner = '|'
          vim.g.table_mode_corner_corner = '|'
          vim.g.table_mode_header_fillchar = '-'

          -- Keybindings (Fix #24: use <cmd> form for silent execution)
          vim.keymap.set('n', '<leader>mt', '<cmd>TableModeToggle<cr>', { desc = 'Toggle table mode', silent = true })
          vim.keymap.set('n', '<leader>mtr', '<cmd>TableModeRealign<cr>', { desc = 'Realign table', silent = true })
          vim.keymap.set('n', '<leader>mts', '<cmd>Tableize<cr>', { desc = 'Convert to table', silent = true })
        '';
      };

      # 3. markdown-preview.nvim - Live browser preview
      markdown-preview-nvim = {
        package = pkgs.vimPlugins.markdown-preview-nvim;
        setup = ''
          -- Preview settings
          vim.g.mkdp_auto_start = 0
          vim.g.mkdp_auto_close = 1
          vim.g.mkdp_refresh_slow = 0
          vim.g.mkdp_command_for_global = 0
          vim.g.mkdp_open_to_the_world = 0
          vim.g.mkdp_browser = ""
          vim.g.mkdp_theme = "dark"

          -- Keybinding (Fix #24: use <cmd> form)
          vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', { desc = 'Toggle markdown preview', silent = true })
        '';
      };

      # 4. render-markdown.nvim - Beautiful markdown rendering
      render-markdown-nvim = {
        package = pkgs.vimPlugins.render-markdown-nvim;
        setup = ''
          require('render-markdown').setup({
            -- Rendered headings with icons
            heading = {
              enabled = true,
              icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
              backgrounds = {
                'RenderMarkdownH1Bg',
                'RenderMarkdownH2Bg',
                'RenderMarkdownH3Bg',
                'RenderMarkdownH4Bg',
                'RenderMarkdownH5Bg',
                'RenderMarkdownH6Bg',
              },
              foregrounds = {
                'RenderMarkdownH1',
                'RenderMarkdownH2',
                'RenderMarkdownH3',
                'RenderMarkdownH4',
                'RenderMarkdownH5',
                'RenderMarkdownH6',
              },
            },
            -- Checkbox icons
            checkbox = {
              enabled = true,
              unchecked = { icon = '󰄱 ' },
              checked = { icon = '󰱒 ' },
            },
            -- Code block backgrounds
            code = {
              enabled = true,
              style = 'full',
              left_pad = 1,
              right_pad = 1,
              width = 'block',
              border = 'thin',
            },
            -- List bullet icons
            bullet = {
              enabled = true,
              icons = { '●', '○', '◆', '◇' },
            },
            -- Table rendering
            pipe_table = {
              enabled = true,
              style = 'full',
            },
          })
        '';
      };
    };

    luaConfigRC = {
      # Markdown: Settings for markdown files
      markdown-visual = ''
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "markdown",
          callback = function()
            -- Enable concealment for render-markdown.nvim
            vim.opt_local.conceallevel = 2
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
            vim.opt_local.spell = false
          end,
        })
      '';
    };
  };
}
