# Fish shell configuration

# Auto-start River on tty1
if test (tty) = "/dev/tty1"
    exec river
end

# Disable greeting
set fish_greeting

# Vi keybindings
set -g fish_key_bindings fish_vi_key_bindings

# Gruvbox Dark Fish Theme
set -g fish_color_normal d5c4a1
set -g fish_color_command b8bb26
set -g fish_color_keyword d3869b
set -g fish_color_error fb4934
set -g fish_color_param 8ec07c
set -g fish_color_string fabd2f
set -g fish_color_quote fabd2f
set -g fish_color_redirection 83a598
set -g fish_color_comment 665c54
set -g fish_color_operator d3869b
set -g fish_color_end d3869b
set -g fish_color_autosuggestion 665c54
set -g fish_color_history_current --bold
set -g fish_color_search_match --background=504945
set -g fish_color_selection --background=504945

# Pager Colors
set -g fish_pager_color_prefix 83a598
set -g fish_pager_color_completion d5c4a1
set -g fish_pager_color_description 665c54
set -g fish_pager_color_selected_background --background=504945
set -g fish_pager_color_progress 8ec07c

# Initialize Starship prompt
starship init fish | source

# Yazi shell wrapper (cd on exit)
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# Git abbreviations
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gd 'git diff'
abbr -a gs 'git status'
abbr -a lg 'lazygit'
