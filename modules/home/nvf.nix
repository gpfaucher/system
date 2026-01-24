{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        # Load monorepo LSP configuration from user override
        luaConfigRC.monorepo-lsp = ''
          -- Load monorepo LSP configuration
          pcall(function()
            dofile(vim.fn.expand('~/.config/nvf/monorepo-lsp.lua'))
          end)
        '';
        # Gruvbox dark theme with hard contrast
        # Use mkForce to override stylix theme
        theme = {
          enable = lib.mkForce true;
          name = lib.mkForce "gruvbox";
          style = lib.mkForce "dark";
        };

        # Leader key configuration
        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };

        # Vim options matching current setup
        options = {
          # Line numbers
          number = true;
          relativenumber = true;

          # Mouse and clipboard
          mouse = "a";
          clipboard = "unnamedplus";

          # Indentation
          tabstop = 2;
          softtabstop = 2;
          shiftwidth = 2;
          expandtab = true;
          autoindent = true;
          smartindent = true;
          breakindent = true;

          # Search
          ignorecase = true;
          smartcase = true;
          hlsearch = true;
          incsearch = true;
          inccommand = "split";

          # UI
          signcolumn = "yes";
          cursorline = true;
          scrolloff = 10;
          showmode = false;
          splitright = true;
          splitbelow = true;
          list = true;
          termguicolors = true;
          
          # Concealment (for markdown rendering)
          conceallevel = 2;
          concealcursor = "nc";

          # Performance
          updatetime = 250;
          timeoutlen = 300;
          ttimeoutlen = 10;

          # Persistence
          undofile = true;

          # Visual block beyond line end
          virtualedit = "block";
        };

        # Global LSP enable
        lsp.enable = true;

        # Languages with LSP
        languages = {
          enableTreesitter = true;

          lua = {
            enable = true;
            lsp.enable = true;
          };

          ts = {
            enable = true;
            lsp.enable = true;
            lsp.servers = ["ts_ls"];
          };

          rust = {
            enable = true;
            lsp.enable = true;
          };

          go = {
            enable = true;
            lsp.enable = true;
          };

          python = {
            enable = true;
            lsp = {
              enable = true;
              servers = ["basedpyright"];
            };
          };

          nix = {
            enable = true;
            lsp.enable = true;
          };

          markdown = {
            enable = true;
            lsp.enable = true;
          };
        };

        # Treesitter configuration
        treesitter = {
          enable = true;
          # autoInstall = true;
          highlight.enable = true;
          indent.enable = true;
        };

        # Telescope with fzf
        telescope = {
          enable = true;
        };

        # Autocomplete via blink-cmp
        # autocomplete = {
        #   blink-cmp = {
        #     enable = true;
        #     friendly-snippets.enable = true;
        #     settings = {
        #       keymap = {
        #         preset = "enter";
        #         "<Tab>" = ["select_next" "fallback"];
        #         "<S-Tab>" = ["select_prev" "fallback"];
        #       };
        #       appearance = {
        #         nerd_font_variant = "mono";
        #       };
        #       sources = {
        #         default = ["lsp" "path" "snippets" "buffer"];
        #       };
        #       completion = {
        #         documentation = {
        #           auto_show = true;
        #         };
        #       };
        #     };
        #   };
        # };

        # Git integration
        git = {
          gitsigns = {
            enable = true;
            setupOpts = {
              current_line_blame = true;
            };
          };
        };

        # Statusline
        statusline = {
          lualine = {
            enable = true;
            theme = lib.mkForce "gruvbox";
          };
        };

        # Which-key for keybind hints
        # utility = {
        #   which-key = {
        #     enable = true;
        #   };
        # };

        # Keymaps
        keymaps = [
          # Window navigation
          {
            key = "<C-h>";
            mode = "n";
            action = "<C-w>h";
            desc = "Focus left window";
          }
          {
            key = "<C-j>";
            mode = "n";
            action = "<C-w>j";
            desc = "Focus below window";
          }
          {
            key = "<C-k>";
            mode = "n";
            action = "<C-w>k";
            desc = "Focus above window";
          }
          {
            key = "<C-l>";
            mode = "n";
            action = "<C-w>l";
            desc = "Focus right window";
          }

          # Buffer navigation
          {
            key = "<S-h>";
            mode = "n";
            action = "<cmd>bprevious<cr>";
            desc = "Previous buffer";
          }
          {
            key = "<S-l>";
            mode = "n";
            action = "<cmd>bnext<cr>";
            desc = "Next buffer";
          }
          {
            key = "<leader>bd";
            mode = "n";
            action = "<cmd>bdelete<cr>";
            desc = "Delete buffer";
          }

          # Quick save
          {
            key = "<C-s>";
            mode = ["n" "i" "v"];
            action = "<cmd>w<cr>";
            desc = "Save file";
          }

          # Better escape
          {
            key = "jk";
            mode = "i";
            action = "<Esc>";
            desc = "Exit insert mode";
          }

          # Center after movements
          {
            key = "<C-d>";
            mode = "n";
            action = "<C-d>zz";
            desc = "Scroll down centered";
          }
          {
            key = "<C-u>";
            mode = "n";
            action = "<C-u>zz";
            desc = "Scroll up centered";
          }
          {
            key = "n";
            mode = "n";
            action = "nzzzv";
            desc = "Next search centered";
          }
          {
            key = "N";
            mode = "n";
            action = "Nzzzv";
            desc = "Previous search centered";
          }

          # Quickfix
          {
            key = "]q";
            mode = "n";
            action = "<cmd>cnext<cr>";
            desc = "Next quickfix";
          }
          {
            key = "[q";
            mode = "n";
            action = "<cmd>cprev<cr>";
            desc = "Previous quickfix";
          }
          {
            key = "<leader>qq";
            mode = "n";
            action = "<cmd>copen<cr>";
            desc = "Open quickfix";
          }
          {
            key = "<leader>qc";
            mode = "n";
            action = "<cmd>cclose<cr>";
            desc = "Close quickfix";
          }

          # Clear search highlight
          {
            key = "<Esc>";
            mode = "n";
            action = "<cmd>nohlsearch<cr>";
            desc = "Clear search highlight";
          }

          # Telescope keymaps
          {
            key = "<leader>sf";
            mode = "n";
            action = "<cmd>Telescope find_files<cr>";
            desc = "Find files";
          }
          {
            key = "<leader>sg";
            mode = "n";
            action = "<cmd>Telescope live_grep<cr>";
            desc = "Live grep";
          }
          {
            key = "<leader>sb";
            mode = "n";
            action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
            desc = "Search buffer";
          }
          {
            key = "<leader>sh";
            mode = "n";
            action = "<cmd>Telescope help_tags<cr>";
            desc = "Help tags";
          }
          {
            key = "<leader><space>";
            mode = "n";
            action = "<cmd>Telescope buffers<cr>";
            desc = "Buffers";
          }
          {
            key = "<leader>gc";
            mode = "n";
            action = "<cmd>Telescope git_commits<cr>";
            desc = "Git commits";
          }
          {
            key = "<leader>gs";
            mode = "n";
            action = "<cmd>Telescope git_status<cr>";
            desc = "Git status";
          }

          # Oil file browser
          {
            key = "<leader>f";
            mode = "n";
            action = "<cmd>Oil --float<cr>";
            desc = "File browser";
          }

          # Notes keybindings
          {
            key = "<leader>ni";
            mode = "n";
            action = "<cmd>edit ~/notes/inbox.md<cr>";
            desc = "Notes inbox";
          }
          {
            key = "<leader>nt";
            mode = "n";
            action = "<cmd>edit ~/notes/todo.md<cr>";
            desc = "Notes todo";
          }
          {
            key = "<leader>nf";
            mode = "n";
            action = "<cmd>Telescope find_files cwd=~/notes<cr>";
            desc = "Find notes";
          }
          {
            key = "<leader>ng";
            mode = "n";
            action = "<cmd>Telescope live_grep cwd=~/notes<cr>";
            desc = "Grep notes";
          }

          # Lazygit
          {
            key = "<leader>gg";
            mode = "n";
            action = "<cmd>LazyGit<cr>";
            desc = "LazyGit";
          }

        ];

        # Extra plugins not in nvf
        extraPlugins = with pkgs.vimPlugins; {
          # Base16 colorscheme (needed for stylix integration)
          nvim-base16 = {
            package = base16-nvim;
          };

          # Oil - file browser
          oil-nvim = {
            package = oil-nvim;
            setup = ''
              require("oil").setup({})
            '';
          };

          # Harpoon 2 - quick file jumping
          harpoon2 = {
            package = harpoon2;
            setup = ''
              local harpoon = require("harpoon")
              harpoon:setup({})

              vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add" })
              vim.keymap.set("n", "<leader>he", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
              vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end, { desc = "Harpoon 1" })
              vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end, { desc = "Harpoon 2" })
              vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end, { desc = "Harpoon 3" })
              vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end, { desc = "Harpoon 4" })
            '';
          };

          # Lazygit integration
          lazygit-nvim = {
            package = lazygit-nvim;
          };

          # Todo comments
          todo-comments-nvim = {
            package = todo-comments-nvim;
            setup = ''
              require("todo-comments").setup({})
            '';
          };

          # Auto pairs
          nvim-autopairs = {
            package = nvim-autopairs;
            setup = ''
              require("nvim-autopairs").setup({})
            '';
          };

          # nvim-lspconfig (required by vim-tabby)
          nvim-lspconfig = {
            package = nvim-lspconfig;
            setup = ''
              -- Just load the module so vim-tabby can use it
              require("lspconfig")
            '';
          };

          # Tabby AI completion (vim-tabby)
          vim-tabby = {
            package = vim-tabby;
          };

          # ============ MARKDOWN PLUGINS (Option 3: Lightweight) ============
          
          # 1. markdown.nvim - Modern inline editing tools
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
                  go_curr_heading = "]c",
                  go_parent_heading = "]p",
                  go_next_heading = "]]",
                  go_prev_heading = "[[",
                },
                on_attach = function(bufnr)
                  local map = vim.keymap.set
                  local opts = { buffer = bufnr, silent = true }
                  
                  -- Checkbox toggle
                  map("n", "<leader>mc", "<Cmd>MDTaskToggle<CR>", vim.tbl_extend("force", opts, { desc = "Toggle markdown checkbox" }))
                  
                  -- List operations
                  map("i", "<C-x>", "<Cmd>MDListItemBelow<CR>", vim.tbl_extend("force", opts, { desc = "New list item below" }))
                  map("i", "<CR>", "<Cmd>MDListItemBelow<CR>", vim.tbl_extend("force", opts, { desc = "New list item" }))
                end,
              })
            '';
          };

          # 2. vim-markdown - Traditional syntax highlighting and folding
          vim-markdown = {
            package = pkgs.vimPlugins.vim-markdown;
            setup = ''
              -- Folding settings
              vim.g.vim_markdown_folding_disabled = 0
              vim.g.vim_markdown_folding_level = 6
              vim.g.vim_markdown_folding_style_pythonic = 1
              
              -- Concealment (render checkboxes, emphasis, etc visually)
              vim.g.vim_markdown_conceal = 2
              vim.g.vim_markdown_conceal_code_blocks = 0
              
              -- Syntax highlighting
              vim.g.vim_markdown_frontmatter = 1
              vim.g.vim_markdown_toml_frontmatter = 1
              vim.g.vim_markdown_json_frontmatter = 1
              vim.g.vim_markdown_math = 1
              vim.g.vim_markdown_strikethrough = 1
              
              -- Link following
              vim.g.vim_markdown_follow_anchor = 1
              vim.g.vim_markdown_edit_url_in = 'current'
              
              -- TOC
              vim.g.vim_markdown_toc_autofit = 1
              
              -- Don't require .md extension for links
              vim.g.vim_markdown_no_extensions_in_markdown = 1
              vim.g.vim_markdown_autowrite = 1
              
              -- Enable checkboxes with nice symbols
              vim.g.vim_markdown_checkbox_states = {' ', 'x', '-'}
            '';
          };

          # 3. tabular - Dependency for vim-markdown
          tabular = {
            package = pkgs.vimPlugins.tabular;
          };

          # 4. vim-table-mode - Smart table formatting
          vim-table-mode = {
            package = pkgs.vimPlugins.vim-table-mode;
            setup = ''
              -- Use markdown-compatible tables
              vim.g.table_mode_corner = '|'
              vim.g.table_mode_corner_corner = '|'
              vim.g.table_mode_header_fillchar = '-'
              
              -- Keybindings
              vim.keymap.set('n', '<leader>mt', ':TableModeToggle<CR>', { desc = 'Toggle table mode' })
              vim.keymap.set('n', '<leader>mtr', ':TableModeRealign<CR>', { desc = 'Realign table' })
              vim.keymap.set('n', '<leader>mts', ':Tableize<CR>', { desc = 'Convert to table' })
            '';
          };

          # 5. markdown-preview.nvim - Live browser preview
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
              
              -- Keybinding
              vim.keymap.set('n', '<leader>mp', ':MarkdownPreviewToggle<CR>', { desc = 'Toggle markdown preview' })
            '';
          };
        };

        # LSP keymaps and settings via luaConfigRC
        luaConfigRC = {
          # Add nvf site directory to runtimepath for treesitter
          nvf-runtimepath = ''
            vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/nvf/site")
          '';

          # Tabby vim-tabby configuration
          tabby-config = ''
            vim.g.tabby_agent_start_command = {"tabby-agent", "--stdio"}
            vim.g.tabby_inline_completion_trigger = "auto"
            vim.g.tabby_inline_completion_keybinding_accept = "<Tab>"
            vim.g.tabby_inline_completion_keybinding_trigger_or_dismiss = "<C-\\>"
          '';

          # LSP attach keymaps
          lsp-keymaps = ''
            vim.api.nvim_create_autocmd("LspAttach", {
              callback = function(args)
                local map = function(keys, func, desc)
                  vim.keymap.set("n", keys, func, { buffer = args.buf, desc = desc })
                end
                map("gd", vim.lsp.buf.definition, "Go to definition")
                map("gr", vim.lsp.buf.references, "References")
                map("gi", vim.lsp.buf.implementation, "Implementation")
                map("K", vim.lsp.buf.hover, "Hover")
                map("<leader>r", vim.lsp.buf.rename, "Rename")
                map("<leader>ca", vim.lsp.buf.code_action, "Code action")
              end,
            })
          '';

          # Diagnostic keymaps
          diagnostic-keymaps = ''
            vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
            vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
            vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Float diagnostic" })
          '';

          # Notes: quick capture to inbox
          notes-capture = ''
            vim.keymap.set("n", "<leader>nc", function()
              local line = vim.fn.input("Capture: ")
              if line ~= "" then
                local file = io.open(os.getenv("HOME") .. "/notes/inbox.md", "a")
                if file then
                  file:write("- " .. line .. "\n")
                  file:close()
                  print(" Captured to inbox")
                end
              end
            end, { desc = "Capture to inbox" })
          '';

          # Notes: toggle checkbox
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
            end, { desc = "Toggle checkbox" })
          '';
          
          # Markdown: Better visual rendering
          markdown-visual = ''
            -- Enable concealment for markdown files
            vim.api.nvim_create_autocmd("FileType", {
              pattern = "markdown",
              callback = function()
                vim.opt_local.conceallevel = 2
                vim.opt_local.concealcursor = "nc"
                
                -- Custom conceal highlighting for better visibility
                vim.api.nvim_set_hl(0, "Conceal", { fg = "#83a598", bg = "NONE" })
              end,
            })
            
            -- Treesitter-based markdown highlighting improvements
            vim.api.nvim_create_autocmd("FileType", {
              pattern = "markdown",
              callback = function()
                -- Enhanced list and checkbox rendering
                vim.treesitter.language.register("markdown", "md")
              end,
            })
          '';
        };
      };
    };
  };
}
