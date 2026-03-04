{ pkgs, lib, ... }:

{
  programs.zed-editor = {
    enable = true;

    # Fully declarative — changes only via Nix, not Zed GUI
    mutableUserSettings = false;
    mutableUserKeymaps = false;

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

    extraPackages = with pkgs; [
      nixd
      nodePackages.typescript-language-server
      nodePackages.prettier
      ruff
      shellcheck
      shfmt
    ];

    userSettings = {
      vim_mode = true;
      ui_font_size = lib.mkForce 14;
      buffer_font_size = lib.mkForce 13;
      hour_format = "hour24";
      tab_size = 2;
      show_whitespaces = "boundary";
      relative_line_numbers = true;

      terminal = {
        shell = {
          program = "fish";
        };
        line_height = "comfortable";
        copy_on_select = true;
        working_directory = "current_project_directory";
      };

      format_on_save = "on";
      autosave = "on_focus_change";
      ensure_final_newline_on_save = true;
      remove_trailing_whitespace_on_save = true;

      git = {
        inline_blame.enabled = true;
      };

      inlay_hints = {
        enabled = true;
      };

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

      lsp = {
        nixd = {
          binary = {
            path_lookup = true;
          };
        };
      };

      vim = {
        use_system_clipboard = "always";
        use_smartcase_find = true;
      };

      features = {
        copilot = false;
      };
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
    };

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          "ctrl-shift-t" = "workspace::NewTerminal";
          "ctrl-shift-e" = "workspace::ToggleLeftDock";
        };
      }
      {
        context = "vim_mode == normal";
        bindings = {
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "shift-h" = "pane::ActivatePreviousItem";
          "shift-l" = "pane::ActivateNextItem";
          "space f" = "file_finder::Toggle";
          "space g" = "project_search::ToggleFocus";
          "space b" = "tab_switcher::Toggle";
          "space e" = "workspace::ToggleLeftDock";
        };
      }
    ];
  };
}
