# Common ZSH settings for all platforms

# Path to your Oh My Zsh installation
# NOTE: This is for Oh My Zsh. Since you're using Zinit, this section
# is redundant and should be removed.
# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="powerlevel10k/powerlevel10k"
# plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
# if [ -d "$ZSH" ]; then
#     source $ZSH/oh-my-zsh.sh
# fi

# p10k Configuration
if [ -f ~/.p10k.zsh ]; then
    source ~/.p10k.zsh
fi

# Only enable focus tracking if supported by terminal and in tmux
if [ -n "$TMUX" ]; then
    printf '\e[?1004h'
    function handle_focus_change() {
        if [[ $1 = 'in' ]]; then
            command tmux set -g pane-active-border-style 'fg=#a6e3a1,bg=default,bold' 2>/dev/null || true
        else
            command tmux set -g pane-active-border-style 'fg=#f38ba8,bg=default,bold' 2>/dev/null || true
        fi
    }
    zle -N focus_gained
    zle -N focus_lost
    function focus_gained() { handle_focus_change 'in'; }
    function focus_lost() { handle_focus_change 'out'; }
    bindkey -M emacs '^[[I' focus_gained
    bindkey -M emacs '^[[O' focus_lost
    bindkey -M vicmd '^[[I' focus_gained
    bindkey -M vicmd '^[[O' focus_lost
    bindkey -M viins '^[[I' focus_gained
    bindkey -M viins '^[[O' focus_lost
    function TRAPINT() {
        printf '\e[?1004l'
        return $((128 + $1))
    }
fi

# TMUX Auto-Start and reload config
if command -v tmux >/dev/null 2>&1; then
    if [ -n "$TMUX" ]; then
        tmux source-file ~/.tmux.conf 2>/dev/null
    fi
fi

# Editor Configuration
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

# Custom Config Set Up
export DEV="$HOME/Dev"
export DEV_VIVACITY="$DEV/vivacity"

# Directory shortcuts
export NOTES="/Users/$USER/Documents/obsidian-vault"

# Autosuggestion configuration
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#999999"
