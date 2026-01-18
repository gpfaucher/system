# ZSH Configuration
# Fast startup, vi mode, good completions

# =============================================================================
# Vi Mode
# =============================================================================
bindkey -v
export KEYTIMEOUT=1

# Change cursor shape for different vi modes
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Use beam cursor on startup and for each new prompt
zle-line-init() {
  zle -K viins
  echo -ne '\e[5 q'
}
zle -N zle-line-init

# =============================================================================
# History
# =============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS   # Delete old duplicate entry
setopt HIST_IGNORE_SPACE      # Don't record entries starting with space
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
setopt HIST_VERIFY            # Show command with history expansion before running
setopt APPEND_HISTORY         # Append to history file
setopt INC_APPEND_HISTORY     # Add commands immediately

# =============================================================================
# Completions
# =============================================================================
autoload -Uz compinit

# Only regenerate .zcompdump once a day for faster startup
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Completion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# =============================================================================
# Aliases
# =============================================================================
# Git aliases
alias ga='git add'
alias gc='git commit -a'
alias gca='git commit --amend'
alias gd='git diff'
alias grh='git reset --hard'
alias lg='lazygit'

# Modern CLI tools
alias ls='eza --icons'
alias ll='eza -la --icons'
alias cat='bat'
alias vim='nvim'

# =============================================================================
# Plugins (source if installed)
# =============================================================================
# zsh-autosuggestions
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting (must be sourced last among plugins)
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf keybindings
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# =============================================================================
# External Tool Integrations
# =============================================================================
# Starship prompt
eval "$(starship init zsh)"

# direnv hook
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# =============================================================================
# Auto-start River on tty1
# =============================================================================
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  exec river
fi
