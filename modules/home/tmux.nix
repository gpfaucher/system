{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    keyMode = "vi";
    prefix = "C-a";
    escapeTime = 10;
    baseIndex = 1;
    historyLimit = 50000;
    mouse = true;
    sensibleOnTop = true;
    focusEvents = true;

    plugins = with pkgs.tmuxPlugins; [
      # Seamless Ctrl+hjkl between Neovim and tmux panes
      vim-tmux-navigator

      # Session persistence across reboots
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }

      # Auto-save sessions (must come after resurrect)
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      # True color support for Neovim
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",xterm-ghostty:RGB"

      # Ayu Dark status bar colors
      set -g status-style "bg=#0b0e14,fg=#e6e1cf"
      set -g status-left "#[fg=#59c2ff,bold] #S "
      set -g status-right "#[fg=#e6e1cf]%H:%M "
      set -g status-left-length 20
      set -g window-status-current-style "fg=#aad94c,bold"
      set -g window-status-style "fg=#565b66"
      set -g pane-border-style "fg=#1c2029"
      set -g pane-active-border-style "fg=#59c2ff"
      set -g message-style "bg=#0b0e14,fg=#e6e1cf"

      # Split panes with | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # New windows in current path
      bind c new-window -c "#{pane_current_path}"

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # Resize panes with vim keys
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Undercurl support (for Neovim diagnostics)
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    '';
  };
}
