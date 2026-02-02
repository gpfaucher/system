{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      # Clean, minimal UI - no default_layout to avoid conflicts with --layout flag
      pane_frames = false;
      simplified_ui = true;
      hide_session_name = true;
      show_startup_tips = false;

      # Disable mouse for resizing (use keyboard instead)
      mouse_mode = false;

      # Theme will be set by stylix automatically
      ui = {
        pane_frames = {
          hide_session_name = true;
          rounded_corners = false;
        };
      };

      # Start in locked mode - all keys pass through to neovim/apps
      # Press Ctrl+g to unlock zellij for pane/tab management
      default_mode = "locked";

      keybinds = {
        unbind = [ "Ctrl h" ]; # Don't conflict with nvim window nav
      };
    };
  };

  # Agent layout for spawn-agent
  # Auto-starts nvim and claude in their panes
  xdg.configFile."zellij/layouts/agent.kdl".text = ''
    layout {
      pane size=1 borderless=true {
        plugin location="compact-bar"
      }
      pane split_direction="vertical" {
        pane size="60%" command="nvim"
        pane split_direction="horizontal" {
          pane size="60%" command="claude"
          pane name="shell"
        }
      }
    }
  '';
}
