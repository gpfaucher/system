_: {
  programs.nixvim.plugins = {
    claude-code = {
      enable = true;
    };
    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        appearance = {
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "mono";
        };
        keymap = {
          preset = "enter";
          "<Tab>" = [
            "select_next"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "fallback"
          ];
          "<C-l>" = [
            "snippet_forward"
            "fallback"
          ];
          "<C-h>" = [
            "snippet_backward"
            "fallback"
          ];
        };

        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
            "git"
          ];
          providers = {
            git = {
              module = "blink-cmp-git";
              name = "git";
              score_offset = 100;
              opts = {
                commit = {};
                git_centers = {
                  git_hub = {};
                };
              };
            };
          };
        };

        completion = {
          trigger = {
            show_on_blocked_trigger_characters = [
              " "
              ":"
            ];
          };
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 500;
          };
          menu = {
            enabled = true;
            min_width = 15;
            max_height = 10;
            border = "none";
            winblend = 0;
            winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None";
            # Keep the cursor X lines away from the top/bottom of the window
            scrolloff = 2;
            # Note that the gutter will be disabled when border ~= 'none'
            scrollbar = true;
            # -- Which directions to show the window,
            # -- falling back to the next direction when there's not enough space
            direction_priority = [
              "s"
              "n"
            ];

            # -- Whether to automatically show the window when new completion items are available
            auto_show = true;
            # Reference: https://cmp.saghen.dev/configuration/reference.html#completion-menu-draw
            draw = {
              padding = 3;
              gap = 2;
              treesitter = ["lsp"];
            };
          };
        };
      };
    };

    blink-cmp-git.enable = true;
  };
}
