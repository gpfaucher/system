{pkgs, ...}: {
  imports = [
    ./completion.nix
    ./lsp.nix
    ./linting.nix
    ./editing.nix
    ./files.nix
    ./keymaps.nix
    ./octo.nix
  ];

  programs.nixvim.plugins = {
    tmux-navigator = {
      enable = true;
      keymaps = [
        {
          action = "left";
          key = "<C-w>h";
        }
        {
          action = "down";
          key = "<C-w>j";
        }
        {
          action = "up";
          key = "<C-w>k";
        }
        {
          action = "right";
          key = "<C-w>l";
        }
        {
          action = "previous";
          key = "<C-w>\\";
        }
      ];
    };

    lualine.enable = true; # Status bar.
    neoscroll.enable = true; # Smooth scrolling
    treesitter.enable = true; # Includes all parsers for treesitter
    web-devicons.enable = true; # Icons.
    sleuth.enable = true; # Dynamic tabwidth.
    ts-autotag.enable = true; # Automatic tags.
    nvim-autopairs.enable = true;
    # nvim-bqf (Better quickfix UI) via extraPlugins below

    # Lazygit
    lazygit = {
      enable = true;
    };

    # Git signs in code
    gitsigns = {
      enable = true;
      settings.current_line_blame = true;
    };

    # Prettier fancier command window
    noice.enable = true;

    # Removed trouble.nvim per request

    # Good old Telescope
    telescope = {
      enable = true;
      extensions = {
        fzf-native = {
          enable = true;
        };
      };
    };

    # Todo comments
    todo-comments = {
      enable = true;
      settings.colors = {
        error = [
          "DiagnosticError"
          "ErrorMsg"
          "#DC2626"
        ];
        warning = [
          "DiagnosticWarn"
          "WarningMsg"
          "#FBBF24"
        ];
        info = [
          "DiagnosticInfo"
          "#2563EB"
        ];
        hint = [
          "DiagnosticHint"
          "#10B981"
        ];
        default = [
          "Identifier"
          "#7C3AED"
        ];
        test = [
          "Identifier"
          "#FF00FF"
        ];
      };
    };

    undotree = {
      enable = true;
      settings = {
        autoOpenDiff = true;
        focusOnToggle = true;
      };
    };

    # Highlight word under cursor
    illuminate = {
      enable = true;
      settings = {
        under_cursor = false;
        filetypes_denylist = [
          "Outline"
          "TelescopePrompt"
          "alpha"
          "harpoon"
          "reason"
        ];
      };
    };

    # Nix expressions in Neovim
    nix = {
      enable = true;
    };

    mini = {
      enable = true;
      modules = {
        starter.enable = true;
        pairs.enable = true;
      };
    };
  };

  programs.nixvim.extraConfigLua = ''
    require("telescope").load_extension("lazygit")
    pcall(function() require('telescope').load_extension('frecency') end)
  '';

  programs.nixvim.extraPlugins = with pkgs.vimPlugins; [
    glow-nvim # Glow inside of Neovim
    clipboard-image-nvim
    telescope-frecency-nvim
    sqlite-lua
    flash-nvim
    nvim-bqf
    taskwarrior3
    harpoon2 # Quick file navigation
  ];

  # Setup harpoon
  programs.nixvim.extraConfigLuaPost = ''
    -- Harpoon setup
    local harpoon = require("harpoon")
    harpoon:setup({})
  '';
}
