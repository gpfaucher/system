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
        };
      };
    };
  };
}
