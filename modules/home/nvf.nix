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
        # Gruvbox dark theme with hard contrast
        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
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

        # Languages with LSP
        languages = {
          enableLSP = true;
          enableTreesitter = true;

          lua = {
            enable = true;
            lsp.enable = true;
            lsp.server = "lua_ls";
          };

          ts = {
            enable = true;
            lsp.enable = true;
            lsp.server = "ts_ls";
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
              server = "basedpyright";
            };
          };

          nix = {
            enable = true;
            lsp.enable = true;
          };
        };

        # Treesitter configuration
        treesitter = {
          enable = true;
          autoInstall = true;
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
            settings = {
              keymap = {
                preset = "enter";
                "<Tab>" = ["select_next" "fallback"];
                "<S-Tab>" = ["select_prev" "fallback"];
              };
              appearance = {
                nerd_font_variant = "mono";
              };
              sources = {
                default = ["lsp" "path" "snippets" "buffer"];
              };
              completion = {
                documentation = {
                  auto_show = true;
                };
              };
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
          };
        };

        # Which-key for keybind hints
        utility = {
          which-key = {
            enable = true;
          };
        };

        # Keymaps
        keymaps = [
          # Window navigation
          {
            key = "<C-h>";
            mode = "n";
            action = "<C-w>h";
            options.desc = "Focus left window";
          }
          {
            key = "<C-j>";
            mode = "n";
            action = "<C-w>j";
            options.desc = "Focus below window";
          }
          {
            key = "<C-k>";
            mode = "n";
            action = "<C-w>k";
            options.desc = "Focus above window";
          }
          {
            key = "<C-l>";
            mode = "n";
            action = "<C-w>l";
            options.desc = "Focus right window";
          }

          # Buffer navigation
          {
            key = "<S-h>";
            mode = "n";
            action = "<cmd>bprevious<cr>";
            options.desc = "Previous buffer";
          }
          {
            key = "<S-l>";
            mode = "n";
            action = "<cmd>bnext<cr>";
            options.desc = "Next buffer";
          }
          {
            key = "<leader>bd";
            mode = "n";
            action = "<cmd>bdelete<cr>";
            options.desc = "Delete buffer";
          }

          # Quick save
          {
            key = "<C-s>";
            mode = ["n" "i" "v"];
            action = "<cmd>w<cr>";
            options.desc = "Save file";
          }

          # Better escape
          {
            key = "jk";
            mode = "i";
            action = "<Esc>";
            options.desc = "Exit insert mode";
          }

          # Center after movements
          {
            key = "<C-d>";
            mode = "n";
            action = "<C-d>zz";
            options.desc = "Scroll down centered";
          }
          {
            key = "<C-u>";
            mode = "n";
            action = "<C-u>zz";
            options.desc = "Scroll up centered";
          }
          {
            key = "n";
            mode = "n";
            action = "nzzzv";
            options.desc = "Next search centered";
          }
          {
            key = "N";
            mode = "n";
            action = "Nzzzv";
            options.desc = "Previous search centered";
          }

          # Quickfix
          {
            key = "]q";
            mode = "n";
            action = "<cmd>cnext<cr>";
            options.desc = "Next quickfix";
          }
          {
            key = "[q";
            mode = "n";
            action = "<cmd>cprev<cr>";
            options.desc = "Previous quickfix";
          }
          {
            key = "<leader>qq";
            mode = "n";
            action = "<cmd>copen<cr>";
            options.desc = "Open quickfix";
          }
          {
            key = "<leader>qc";
            mode = "n";
            action = "<cmd>cclose<cr>";
            options.desc = "Close quickfix";
          }

          # Clear search highlight
          {
            key = "<Esc>";
            mode = "n";
            action = "<cmd>nohlsearch<cr>";
            options.desc = "Clear search highlight";
          }

          # Telescope keymaps
          {
            key = "<leader>sf";
            mode = "n";
            action = "<cmd>Telescope find_files<cr>";
            options.desc = "Find files";
          }
          {
            key = "<leader>sg";
            mode = "n";
            action = "<cmd>Telescope live_grep<cr>";
            options.desc = "Live grep";
          }
          {
            key = "<leader>sb";
            mode = "n";
            action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
            options.desc = "Search buffer";
          }
          {
            key = "<leader>sh";
            mode = "n";
            action = "<cmd>Telescope help_tags<cr>";
            options.desc = "Help tags";
          }
          {
            key = "<leader><space>";
            mode = "n";
            action = "<cmd>Telescope buffers<cr>";
            options.desc = "Buffers";
          }
          {
            key = "<leader>gc";
            mode = "n";
            action = "<cmd>Telescope git_commits<cr>";
            options.desc = "Git commits";
          }
          {
            key = "<leader>gs";
            mode = "n";
            action = "<cmd>Telescope git_status<cr>";
            options.desc = "Git status";
          }

          # Oil file browser
          {
            key = "<leader>f";
            mode = "n";
            action = "<cmd>Oil --float<cr>";
            options.desc = "File browser";
          }

          # Lazygit
          {
            key = "<leader>gg";
            mode = "n";
            action = "<cmd>LazyGit<cr>";
            options.desc = "LazyGit";
          }

          # Venv selector
          {
            key = "<leader>vs";
            mode = "n";
            action = "<cmd>VenvSelect<cr>";
            options.desc = "Select venv";
          }
          {
            key = "<leader>vc";
            mode = "n";
            action = "<cmd>VenvSelectCached<cr>";
            options.desc = "Select cached venv";
          }
        ];

        # Extra plugins not in nvf
        extraPlugins = with pkgs.vimPlugins; {
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

          # Venv selector for Python
          venv-selector = {
            package = venv-selector;
            setup = ''
              require("venv-selector").setup({
                settings = {
                  search = {
                    monorepo = {
                      command = "fd 'python$' apps functions --type x --full-path",
                      type = "anaconda",
                    },
                  },
                },
              })
            '';
          };
        };

        # LSP keymaps and basedpyright settings via luaConfigRC
        luaConfigRC = {
          # Basedpyright specific settings
          basedpyright-settings = ''
            vim.lsp.config("basedpyright", {
              settings = {
                basedpyright = {
                  analysis = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "openFilesOnly",
                  },
                },
              },
            })
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

          # Lua LS settings
          lua-ls-settings = ''
            vim.lsp.config("lua_ls", {
              settings = {
                Lua = {
                  telemetry = { enable = false },
                  workspace = { checkThirdParty = false },
                },
              },
            })
          '';
        };
      };
    };
  };
}
