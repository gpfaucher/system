# Auto-start River on tty1
if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
    exec river
end

starship init fish | source

fish_config theme choose "Catppuccin Mocha"
