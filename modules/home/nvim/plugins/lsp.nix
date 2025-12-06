_: {
  programs.nixvim.diagnostic.settings = {
    virtual_text = true;
  };

  programs.nixvim.plugins = {
    lspkind = {
      enable = true;
      cmp.enable = false;
      settings = {
        mode = "symbol_text"; # include text labels to reduce reliance on icons
        preset = "default";
        symbol_map = {Copilot = "C";};
        maxwidth = 50;
        ellipsis_char = "...";
      };
    };

    luasnip = {
      enable = true;
      settings = {
        enable_autosnippets = true;
        store_selection_keys = "<Tab>";
      };
    };

    lspsaga = {
      enable = true;
      settings = {
        symbol_in_winbar = {
          enable = false;
        };
        implement = {
          enable = false;
        };
        lightbulb = {
          virtual_text = true;
        };
      };
    };

    actions-preview = {
      enable = true;
    };

    lsp = {
      enable = true;
      servers = {
        ts_ls.enable = true;
        cssls.enable = true;
        tailwindcss.enable = true;
        html.enable = true;
        astro.enable = true;
        phpactor.enable = true;
        svelte.enable = false;
        marksman.enable = true;
        nil_ls.enable = true;
        dockerls.enable = true;
        bashls.enable = true;
        clangd.enable = true;
        csharp_ls.enable = true;
        yamlls.enable = true;

        basedpyright = {
          enable = true;
          settings = {
            basedpyright = {
              python = {
                pythonPath = "./.devenv/state/venv/bin/python";
              };
              analysis = {
                diagnosticsMode = "workspace";
                typeCheckingMode = "off";
                autoSearchPaths = true;
                useLibraryCodeForTypes = true;
              };
            };
          };
        };

        gopls = {
          enable = true;
          autostart = true;
        };

        lua_ls = {
          enable = true;
          settings.telemetry.enable = false;
        };

        rust_analyzer = {
          enable = true;
          installRustc = true;
          installCargo = true;
        };
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      action = "<cmd>Lspsaga hover_doc<cr>";
      key = "K";
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Lspsaga finder<cr>";
      key = "gi";
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Lspsaga rename<cr>";
      key = "<leader>r";
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Lspsaga term_toggle<cr>";
      key = "<leader>/";
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Lspsaga code_action<cr>";
      key = "<leader>q";
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Lspsaga show_workspace_diagnostics<cr>";
      key = "<leader>d";
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Lspsaga goto_definition<cr>";
      key = "gd";
      options = {
        silent = true;
      };
    }
  ];
}
