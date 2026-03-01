{
  config,
  pkgs,
  lib,
  ...
}:
let
  # OpenCode.nvim - AI coding assistant integration
  # Pinned to specific commit for reproducibility (#3, #19)
  opencode-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "opencode-nvim";
    version = "unstable-2026-01-28";
    src = pkgs.fetchFromGitHub {
      owner = "sudo-tee";
      repo = "opencode.nvim";
      rev = "60e14377357f334a5ca50ff359e6f47179a339aa";
      sha256 = "0xsy241bwvl2mxjxkcsyrgp6kk5k8b959dqmh5jim6pwk32nbs9z";
    };
    doCheck = false;
    meta.homepage = "https://github.com/sudo-tee/opencode.nvim";
  };
in
{
  imports = [
    ./options.nix
    ./lsp.nix
    ./keymaps.nix
    ./plugins.nix
    ./markdown.nix
  ];

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

        # Telescope with fzf
        telescope = {
          enable = true;
        };

        # Autocomplete via blink-cmp (#20 - added signature help)
        autocomplete = {
          blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
            setupOpts = {
              keymap.preset = "enter";
              sources.default = [ "lsp" "path" "snippets" "buffer" ];
              completion.documentation.auto_show = true;
              signature = {
                enabled = true;
                window.border = "rounded";
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
            theme = lib.mkForce "auto";
          };
        };

        # Formatter integration via conform.nvim (#8)
        formatter = {
          conform-nvim = {
            enable = true;
            setupOpts = {
              formatters_by_ft = {
                javascript = [ "prettier" ];
                typescript = [ "prettier" ];
                javascriptreact = [ "prettier" ];
                typescriptreact = [ "prettier" ];
                css = [ "prettier" ];
                html = [ "prettier" ];
                json = [ "prettier" ];
                yaml = [ "prettier" ];
                markdown = [ "prettier" ];
                graphql = [ "prettier" ];
                python = [ "ruff_format" "ruff_organize_imports" ];
                nix = [ "nixfmt" ];
                sh = [ "shfmt" ];
                bash = [ "shfmt" ];
                lua = [ "stylua" ];
                go = [ "gofmt" ];
                rust = [ "rustfmt" ];
                terraform = [ "terraform_fmt" ];
                tf = [ "terraform_fmt" ];
                "_" = [ "trim_whitespace" ];
              };
              format_on_save = {
                timeout_ms = 1000;
                lsp_format = "fallback";
              };
              default_format_opts = {
                lsp_format = "fallback";
              };
            };
          };
        };

        # Debugger integration (#9)
        debugger = {
          nvim-dap = {
            enable = true;
            ui = {
              enable = true;
              autoStart = true;
            };
            mappings = {
              continue = "<F5>";
              restart = "<F6>";
              terminate = "<F7>";
              toggleBreakpoint = "<leader>db";
              toggleRepl = "<leader>dr";
              toggleDapUI = "<leader>du";
              runToCursor = "<leader>dc";
              stepInto = "<F11>";
              stepOut = "<S-F11>";
              stepOver = "<F10>";
              hover = "<leader>dh";
            };
          };
        };

        # Session management (#10)
        session = {
          nvim-session-manager = {
            enable = true;
            setupOpts = {
              autoload_mode = "CurrentDir";
              autosave_last_session = true;
              autosave_only_in_session = true;
            };
          };
        };

        # Indent guides (#11)
        visuals = {
          indent-blankline = {
            enable = true;
            setupOpts = {
              indent = {
                char = "│";
              };
              scope = {
                enabled = true;
                show_start = true;
                show_end = false;
              };
              exclude = {
                filetypes = [
                  "help"
                  "dashboard"
                  "lazy"
                  "mason"
                  "oil"
                  "TelescopePrompt"
                ];
              };
            };
          };
        };

        # Trouble.nvim for diagnostics list (#14)
        lsp.trouble = {
          enable = true;
          mappings = {
            workspaceDiagnostics = "<leader>xw";
            documentDiagnostics = "<leader>xd";
            lspReferences = "<leader>xr";
            quickfix = "<leader>xq";
            locList = "<leader>xl";
            symbols = "<leader>xs";
          };
        };

        # Surround plugin for non-markdown (#12)
        utility = {
          surround = {
            enable = true;
            useVendoredKeybindings = true;
          };

          # Flash.nvim motion plugin (#25)
          motion = {
            flash-nvim = {
              enable = true;
              mappings = {
                jump = "s";
                treesitter = "S";
                remote = "r";
                treesitter_search = "R";
                toggle = "<c-s>";
              };
            };
          };
        };

        # Treesitter textobjects (#13)
        treesitter = {
          enable = true;
          highlight.enable = true;
          indent.enable = true;
          textobjects = {
            enable = true;
            setupOpts = {
              select = {
                enable = true;
                lookahead = true;
                keymaps = {
                  "af" = "@function.outer";
                  "if" = "@function.inner";
                  "ac" = "@class.outer";
                  "ic" = "@class.inner";
                  "aa" = "@parameter.outer";
                  "ia" = "@parameter.inner";
                  "ai" = "@conditional.outer";
                  "ii" = "@conditional.inner";
                  "al" = "@loop.outer";
                  "il" = "@loop.inner";
                  "ab" = "@block.outer";
                  "ib" = "@block.inner";
                };
              };
              move = {
                enable = true;
                set_jumps = true;
                goto_next_start = {
                  "]m" = "@function.outer";
                  "]]" = "@class.outer";
                  "]a" = "@parameter.inner";
                };
                goto_next_end = {
                  "]M" = "@function.outer";
                  "][" = "@class.outer";
                };
                goto_previous_start = {
                  "[m" = "@function.outer";
                  "[[" = "@class.outer";
                  "[a" = "@parameter.inner";
                };
                goto_previous_end = {
                  "[M" = "@function.outer";
                  "[]" = "@class.outer";
                };
              };
              swap = {
                enable = true;
                swap_next = {
                  "<leader>sa" = "@parameter.inner";
                };
                swap_previous = {
                  "<leader>sA" = "@parameter.inner";
                };
              };
            };
          };
        };

        # Extra plugins not natively in nvf
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

              vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add", silent = true })
              vim.keymap.set("n", "<leader>he", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu", silent = true })
              vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end, { desc = "Harpoon 1", silent = true })
              vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end, { desc = "Harpoon 2", silent = true })
              vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end, { desc = "Harpoon 3", silent = true })
              vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end, { desc = "Harpoon 4", silent = true })
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
        };

        # Lua config sections
        luaConfigRC = {
          # Add nvf site directory to runtimepath for treesitter
          nvf-runtimepath = ''
            vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/nvf/site")
          '';
        };
      };
    };
  };
}
