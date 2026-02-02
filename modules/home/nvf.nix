{
  config,
  pkgs,
  lib,
  ...
}:
let
  # OpenCode.nvim - AI coding assistant integration
  opencode-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "opencode-nvim";
    version = "unstable-2026-01-28";
    src = pkgs.fetchFromGitHub {
      owner = "sudo-tee";
      repo = "opencode.nvim";
      rev = "main";
      sha256 = "0xkxdcpp06wxzy0isx0pfb11ys4pbd9s61g51fpcfvy1wsk8xi8b";
    };
    doCheck = false;
    meta.homepage = "https://github.com/sudo-tee/opencode.nvim";
  };

  # Claude Code Neovim integration (coder/claudecode.nvim)
  claudecode-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "claudecode-nvim";
    version = "unstable-2026-02-02";
    src = pkgs.fetchFromGitHub {
      owner = "coder";
      repo = "claudecode.nvim";
      rev = "main";
      sha256 = "125scrzl96k30q2vjvfx0bl38rhfp5z3nfirzfjbji3vg3xl1807";
    };
    doCheck = false;
    meta.homepage = "https://github.com/coder/claudecode.nvim";
  };
in
{
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
        # Use base16 theme (inherits Stylix's ayu-dark colors)
        theme = {
          enable = lib.mkForce true;
          name = lib.mkForce "base16";
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
            lsp.servers = [ "ts_ls" ];
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
              servers = [ "basedpyright" ];
            };
          };

          nix = {
            enable = true;
            lsp.enable = true;
          };

          terraform = {
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
        autocomplete = {
          blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
            setupOpts = {
              keymap.preset = "enter";
              sources.default = ["lsp" "path" "snippets" "buffer"];
              completion.documentation.auto_show = true;
            };
          };
        };

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
            theme = lib.mkForce "auto";
          };
        };

        # Which-key for keybind hints (configured as extra plugin below)

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
            mode = [
              "n"
              "i"
              "v"
            ];
            action = "<cmd>w<cr>";
            desc = "Save file";
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
                { "<leader>c", group = "Claude" },
                { "<leader>d", group = "Diagnostics" },
                { "<leader>f", group = "File" },
                { "<leader>g", group = "Git" },
                { "<leader>h", group = "Harpoon" },
                { "<leader>m", group = "Markdown" },
                { "<leader>n", group = "Notes" },
                { "<leader>o", group = "OpenCode" },
                { "<leader>q", group = "Quickfix" },
                { "<leader>s", group = "Search" },
              })
            '';
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

          # nvim-lspconfig
          nvim-lspconfig = {
            package = nvim-lspconfig;
            setup = ''
              require("lspconfig")
            '';
          };

          # snacks.nvim - Required by claudecode.nvim for terminal provider
          snacks-nvim = {
            package = pkgs.vimPlugins.snacks-nvim;
            setup = ''
              require("snacks").setup({})
            '';
          };

          # OpenCode.nvim - AI coding assistant
          opencode = {
            package = opencode-nvim;
            setup = ''
              require("opencode").setup({
                position = "right",
                window_width = 60,

                -- Keymaps
                keymaps = {
                  editor = {
                    toggle = "<leader>oo",      -- Toggle OpenCode window
                    open_input = "<leader>oi",  -- Open input in insert mode
                    quick_chat = "<leader>o/",  -- Quick chat with selection
                    timeline = "<leader>oT",    -- Conversation timeline
                    sessions = "<leader>os",    -- Session picker
                  },
                  input_window = {
                    submit = "<S-CR>",          -- Submit prompt
                  },
                },

                -- Context settings
                context = {
                  cursor_data = true,
                  diagnostics = { info = false, warn = true, error = true },
                  current_file = true,
                  selection = true,
                  git_diff = true,
                },
              })
            '';
          };

          # Claude Code Neovim integration (coder/claudecode.nvim)
          # Provides WebSocket MCP server for Claude CLI integration
          claudecode = {
            package = claudecode-nvim;
            setup = ''
              require("claudecode").setup({
                auto_start = true,
                terminal = {
                  split_side = "right",
                  split_width_percentage = 0.4,
                  provider = "snacks",
                },
                diff = {
                  enabled = true,
                  auto_close_on_accept = true,
                },
              })

              -- Keymaps for Claude Code
              vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCodeToggle<cr>", { desc = "Toggle Claude Code" })
              vim.keymap.set("n", "<leader>cs", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
              vim.keymap.set("v", "<leader>cs", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection to Claude" })
              vim.keymap.set("n", "<leader>cA", "<cmd>ClaudeCodeAdd<cr>", { desc = "Add file to Claude context" })
              vim.keymap.set("n", "<leader>ct", "<cmd>ClaudeCodeTreeAdd<cr>", { desc = "Add from file tree" })
              vim.keymap.set("n", "<leader>cd", "<cmd>ClaudeCodeDiff<cr>", { desc = "Show Claude diff" })
            '';
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
                  
                  -- List operations (use Ctrl+Enter for new list item, keep Enter normal)
                  map("i", "<C-CR>", "<Cmd>MDListItemBelow<CR>", vim.tbl_extend("force", opts, { desc = "New list item below" }))
                  map("n", "o", function()
                    local line = vim.api.nvim_get_current_line()
                    if line:match("^%s*[-*+]%s") or line:match("^%s*%d+%.%s") then
                      return "o" .. line:match("^%s*[-*+%d]+[.:]?%s*")
                    end
                    return "o"
                  end, vim.tbl_extend("force", opts, { expr = true, desc = "Smart list continuation" }))
                end,
              })
            '';
          };

          # 2. vim-markdown - Traditional syntax highlighting and folding
          vim-markdown = {
            package = pkgs.vimPlugins.vim-markdown;
            setup = ''
              -- Folding settings
              vim.g.vim_markdown_folding_disabled = 1

              -- Let render-markdown.nvim handle concealment
              vim.g.vim_markdown_conceal = 0
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

          # 6. render-markdown.nvim - Beautiful markdown rendering
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
                -- Checkbox icons (not raw [ ] and [x])
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
                -- Colors inherited from theme (ayu-dark)
                -- We just need to ensure it's enabled for markdown files
              })
            '';
          };
        };

        # LSP keymaps and settings via luaConfigRC
        luaConfigRC = {
          # Telescope configuration for hidden files
          telescope-config = ''
            local telescope = require("telescope")
            telescope.setup({
              defaults = {
                hidden = true,  -- Show hidden files (dotfiles)
                -- ripgrep and fd respect .gitignore by default
              },
              pickers = {
                find_files = {
                  hidden = true,  -- Ensure hidden files are shown in find_files picker
                  no_ignore = false,  -- Respect .gitignore files
                },
                live_grep = {
                  additional_args = function()
                    return {"--hidden"}
                  end,
                },
              },
            })
          '';

          # Add nvf site directory to runtimepath for treesitter
          nvf-runtimepath = ''
            vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/nvf/site")
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

          # Diagnostic configuration
          diagnostic-config = ''
            -- Configure diagnostic display
            vim.diagnostic.config({
              virtual_text = true,
              signs = true,
              underline = true,
              update_in_insert = false,
              severity_sort = true,
              float = {
                border = "rounded",
                source = "always",
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
                  source = "always",
                  prefix = " ",
                  scope = "cursor",
                }
                vim.diagnostic.open_float(nil, opts)
              end
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
    };
  };
}
