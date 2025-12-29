{pkgs, ...}: {
  home.packages = with pkgs; [
    ghostty
    alacritty
    warp-terminal
  ];

  # Ghostty additional configuration (colors handled by Stylix)
  programs.ghostty = {
    enable = true;
    settings = {
      # Window settings - no decorations/borders
      window-decoration = false;
      window-padding-x = 4;
      window-padding-y = 4;
      gtk-titlebar = false;

      # Transparency
      background-opacity = 0.9;

      # Keybindings for terminal
      keybind = [
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+plus=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+zero=reset_font_size"
      ];

      # Behavior
      copy-on-select = "clipboard";
      confirm-close-surface = false;
      mouse-hide-while-typing = true;
      scrollback-limit = 10000;
    };
  };

  # Alacritty as backup (colors handled by Stylix)
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 4;
          y = 4;
        };
        decorations = "none";
      };
      scrolling.history = 10000;
    };
  };

  # Zellij - clean minimal config (colors handled by Stylix)
  programs.zellij = {
    enable = true;
    settings = {
      # Clean, minimal UI
      default_layout = "compact";
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
        unbind = ["Ctrl h"];
      };
    };
  };
}
