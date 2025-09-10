{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g default-terminal "$TERM"
      set -ag terminal-overrides ",$TERM:Tc"
      set-option -a terminal-features 'alacritty:RGB'
      set -g prefix C-a

      bind s choose-tree -sZ -O name

      set -g base-index 1
      setw -g pane-base-index 1

      unbind %
      bind | split-window -h

      unbind '"'
      bind - split-window -v

      bind-key -r f run-shell "tmux neww tms"
      bind-key -r M-h run-shell "tmux neww tms -s 0"
      bind-key -r M-t run-shell "tmux neww tms -s 1"
      bind-key -r M-n run-shell "tmux neww tms -s 2"
      bind-key -r M-s run-shell "tmux neww tms -s 3"

      unbind r
      bind r source-file ~/.tmux.conf

      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5

      bind -r m resize-pane -Z

      set -g mouse on
      set-window-option -g mode-keys vi

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      unbind -T copy-mode-vi MouseDragEnd1Pane
      bind-key b set-option status

      set -g pane-border-lines single
      set-option -g status-position top

      set -g pane-border-style fg="grey"

      set -g pane-active-border-style fg="white"
      set -g status-style fg=white,bg=default,bold
      set -g status-left ""
      set -g status-right "#[fg=white]#S"
      set-option -g message-style fg=red,bg=default,bold
      set-window-option -g window-status-style bold
      set -g window-status-format '#[fg=white]#{window_index}:#{?#{==:#W,zsh},#(echo "#{pane_current_command}"),#W}'
      set -g window-status-current-format '#[fg=grey]#{window_index}:#{?#{==:#W,zsh},#(echo "#{pane_current_command}"),#W}'

      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'

      # Kinesis keyboard friendly bindings
      # Map common navigation keys to vi-style movement
      bind-key k select-pane -U
      bind-key j select-pane -D
      bind-key h select-pane -L
      bind-key l select-pane -R
    '';
    plugins = with pkgs.tmuxPlugins; [
      open
      yank
      sensible
      sessionist
      resurrect
    ];
  };

  home.packages = with pkgs; [
    tmux-sessionizer
  ];
}
