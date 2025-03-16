#!/bin/zsh
# Common ZSH settings for all platforms

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme Configuration
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    # Add other plugins here
)

# Oh My Zsh Configuration
if [ -d "$ZSH" ]; then
    source $ZSH/oh-my-zsh.sh
    print_status "Oh My Zsh" "enabled"
else
    print_status "Oh My Zsh" "disabled"
fi

# Powerlevel10k Configuration
if [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme
    print_status "Powerlevel10k Theme" "enabled"
else
    print_status "Powerlevel10k Theme" "disabled"
fi

# p10k Configuration
if [ -f ~/.p10k.zsh ]; then
    source ~/.p10k.zsh
    print_status "p10k Configuration" "enabled"
else
    print_status "p10k Configuration" "disabled"
fi

# Enable focus tracking in terminal
printf '\e[?1004h'

# Focus change detection function
function handle_focus_change() {
    if [[ $1 = 'in' ]]; then
        # Terminal gained focus - set green border
        command tmux set -g pane-active-border-style 'fg=#a6e3a1,bg=default,bold' 2>/dev/null || true
    else
        # Terminal lost focus - set red border
        command tmux set -g pane-active-border-style 'fg=#f38ba8,bg=default,bold' 2>/dev/null || true
    fi
}

# Register focus handlers as zle widgets
zle -N focus_gained
zle -N focus_lost

# Define the widget functions
function focus_gained() { handle_focus_change 'in'; }
function focus_lost() { handle_focus_change 'out'; }

# Bind focus events to terminal sequences
bindkey -M emacs '^[[I' focus_gained
bindkey -M emacs '^[[O' focus_lost
bindkey -M vicmd '^[[I' focus_gained
bindkey -M vicmd '^[[O' focus_lost
bindkey -M viins '^[[I' focus_gained
bindkey -M viins '^[[O' focus_lost

# Disable focus tracking when exiting shell
function TRAPINT() {
    printf '\e[?1004l'
    return $((128 + $1))
}

# Log the configuration status
print_status "Focus tracking" "enabled"

# TMUX Auto-Start and reload config
if command -v tmux >/dev/null 2>&1; then
    # Reload tmux config if tmux is running
    if [ -n "$TMUX" ]; then
        tmux source-file ~/.tmux.conf 2>/dev/null
        print_status "Tmux config reload" "enabled"
    else
        # Start tmux if not already running
        tmux
    fi
    print_status "Tmux" "enabled"
else
    print_status "Tmux" "disabled"
fi

# Editor Configuration
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi
if command -v $EDITOR >/dev/null 2>&1; then
    print_status "Editor ($EDITOR)" "enabled"
else
    print_status "Editor ($EDITOR)" "disabled"
fi

# Custom Config Set Up
export DEV="$HOME/Dev"
export DEV_VIVACITY="$DEV/vivacity"

# Directory shortcuts
export NOTES="/Users/$USER/Documents/obsidian-vault"

# Autosuggestion configuration
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#999999"
