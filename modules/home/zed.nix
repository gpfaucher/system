{ pkgs, lib, ... }:

{
  programs.zed-editor = {
    enable = true;

    # Fully declarative — changes only via Nix, not Zed GUI
    mutableUserSettings = false;
    mutableUserKeymaps = false;

    # Extensions (installed at runtime by Zed, not Nix-managed)
    extensions = [
      "nix"
      "toml"
      "dockerfile"
      "docker-compose"
      "html"
      "git-firefly"
      "fish"
      "kdl"
    ];

    # System LSPs and formatters available to Zed via PATH
    extraPackages = with pkgs; [
      nixd
      nodePackages.typescript-language-server
      nodePackages.prettier
      ruff
      shellcheck
      shfmt
    ];

    userSettings = {
      # Vim mode
      vim_mode = true;

      # UI
      ui_font_size = lib.mkForce 14;
      buffer_font_size = lib.mkForce 13;
      hour_format = "hour24";
      tab_size = 2;
      show_whitespaces = "boundary";
      relative_line_numbers = true;

      # Terminal (font managed by Stylix)
      terminal = {
        shell = {
          program = "fish";
        };
        line_height = "comfortable";
        copy_on_select = true;
        working_directory = "current_project_directory";
      };

      # File behavior
      format_on_save = "on";
      autosave = "on_focus_change";
      ensure_final_newline_on_save = true;
      remove_trailing_whitespace_on_save = true;

      # Git
      git = {
        inline_blame.enabled = true;
      };

      # Inlay hints
      inlay_hints = {
        enabled = true;
      };

      # Language-specific settings
      languages = {
        Nix = {
          language_servers = [ "nixd" ];
          formatter = {
            external = {
              command = "nixfmt";
            };
          };
        };
        Python = {
          formatter = {
            external = {
              command = "ruff";
              arguments = [
                "format"
                "-"
              ];
            };
          };
        };
      };

      # LSP binary paths (prefer system packages over Zed-downloaded)
      lsp = {
        nixd = {
          binary = {
            path_lookup = true;
          };
        };
      };

      # Vim mode settings
      vim = {
        use_system_clipboard = "always";
        use_smartcase_find = true;
      };

      # Collaboration (disabled for local-first workflow)
      features = {
        copilot = false;
      };
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
    };

    userKeymaps = [
      # Workspace-level keybindings
      {
        context = "Workspace";
        bindings = {
          "ctrl-shift-t" = "workspace::NewTerminal";
          "ctrl-shift-e" = "workspace::ToggleLeftDock";
        };
      }
      # Vim normal mode additions
      {
        context = "vim_mode == normal";
        bindings = {
          # Window navigation (match nvim C-hjkl)
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
          # Buffer navigation (match nvim S-hl)
          "shift-h" = "pane::ActivatePreviousItem";
          "shift-l" = "pane::ActivateNextItem";
          # Leader-style (space) bindings
          "space f" = "file_finder::Toggle";
          "space g" = "project_search::ToggleFocus";
          "space b" = "tab_switcher::Toggle";
          "space e" = "workspace::ToggleLeftDock";
        };
      }
    ];
  };
}
