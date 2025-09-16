# system-next-steps

This is a quick overview of what needs to be done the finish the last parts of my system configuration.

## nixos

- remove unused packages
- remove unused modules
- remove unused hosts (nexus)
- add secret management for ssh keys
- add a codex cli configuration with useful mcp servers for programming

## focus

- add c-o tmux keybind to switch sessions with tmux-sessionizer
- add c-o nvim keybind to switch sessions with tmux-sessionizer
- add tmux sessions to auto-save and auto-restore
- setup taskwarrior for task/time management:
    - add bugwarrior for integration with linear
    - add https://github.com/ribelo/taskwarrior.nvim to manage tasks from within neovim

## neovim

- make sure formatting works for all lsp (including python)
- switch to catpuccin-mocha for colorscheme
- quickfix met keyinds en: https://github.com/kevinhwang91/nvim-bqf
- normal (way smaller) icons for things like quickfix bubble
- add useful keybinds for all plugins. A lot are unbound right now like undotree.
- add which key for all plugins, and section all keybinds (and which key) in sections that make sense

## kde

- save plasma config with plasma-manager
- make catpuccin splash screen your background
- switch from evremap to kmonad: https://github.com/kmonad/kmonad
