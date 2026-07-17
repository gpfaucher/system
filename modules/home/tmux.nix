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
      vim-tmux-navigator

      # Session persistence across reboots
      {
        plugin = resurrect;
        extraConfig = ''
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
      # Keep tmux alive when the current project session is closed.
      set -g detach-on-destroy off

      # True color support for Neovim
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",xterm-ghostty:RGB"

      # Split panes with | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # New windows in current path
      bind c new-window -c "#{pane_current_path}"

      # Terminal-native project and session navigation through sesh.
      bind T display-popup -E -w 80% -h 80% -d "#{pane_current_path}" -T "Projects" "sesh picker -i"
      bind L run-shell "sesh last"
      bind 9 run-shell "sesh connect --root '#{pane_current_path}'"

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

  xdg.configFile."sesh/sesh.toml".text = ''
    [tui]
    prompt = "Project > "
    placeholder = "Filter projects and sessions..."
    show_icons = true

    [default_session]
    preview_command = "eza --all --git --icons --color=always {}"

    [[session]]
    name = "system"
    path = "~/Developer/system"
    startup_command = "nvim"
    windows = [ "shell", "rebuild", "git" ]

    [[window]]
    name = "shell"

    [[window]]
    name = "rebuild"

    [[window]]
    name = "git"
    startup_script = "lazygit"
  '';
}
