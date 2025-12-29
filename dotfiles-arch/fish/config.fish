# Fish shell configuration

# Auto-start River on tty1
if test (tty) = "/dev/tty1"
    exec river
end

# Disable greeting
set fish_greeting

# Vi keybindings
set -g fish_key_bindings fish_vi_key_bindings

# Oxocarbon Fish Theme (for syntax highlighting)
set -g fish_color_normal f2f4f8
set -g fish_color_command 42be65
set -g fish_color_keyword be95ff
set -g fish_color_error ee5396
set -g fish_color_param 3ddbd9
set -g fish_color_string 33b1ff
set -g fish_color_quote 33b1ff
set -g fish_color_redirection 78a9ff
set -g fish_color_comment 525252
set -g fish_color_operator be95ff
set -g fish_color_end be95ff
set -g fish_color_autosuggestion 525252
set -g fish_color_history_current --bold
set -g fish_color_search_match --background=33b1ff40
set -g fish_color_selection --background=262626

# Pager (Tab Completion Menu) Colors
set -g fish_pager_color_prefix 78a9ff
set -g fish_pager_color_completion f2f4f8
set -g fish_pager_color_description 525252
set -g fish_pager_color_selected_background --background=262626
set -g fish_pager_color_progress 3ddbd9

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

# Key bindings
function fish_user_key_bindings
    bind -M insert ctrl-o "tms; commandline -f repaint"
    bind -M default ctrl-o "tms; commandline -f repaint"
end

# Git abbreviations
abbr -a ga 'git add'
abbr -a gl "git log --pretty=format:'%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate --date=short"
abbr -a gc 'git commit -a'
abbr -a gca 'git commit --amend'
abbr -a gd 'git diff'
abbr -a gcom 'git checkout master'
abbr -a grh 'git reset --hard'
abbr -a lg 'lazygit'

# SSH tunnel aliases (update these for your infrastructure)
alias staging-tunnel "ssh -fN paddock-staging-tunnel && echo 'Staging tunnel open: Postgres localhost:5432'"
alias staging-tunnel-stop "pkill -f 'ssh.*paddock-staging-tunnel'"
alias staging-tunnel-status "pgrep -f 'ssh.*paddock-staging-tunnel' >/dev/null && echo 'Running' || echo 'Not running'"
alias prod-tunnel "ssh -fN paddock-prod-tunnel && echo 'Prod tunnel open: Postgres localhost:5433, Redis localhost:6380'"
alias prod-tunnel-stop "pkill -f 'ssh.*paddock-prod-tunnel'"
alias prod-tunnel-status "pgrep -f 'ssh.*paddock-prod-tunnel' >/dev/null && echo 'Running' || echo 'Not running'"
