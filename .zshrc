# Helper function for status messages
print_status() {
    local component=$1
    local state=$2    # Changed from 'status' to 'state'
    if [ "$state" = "enabled" ]; then
        echo "\033[0;32m✓ $component configured\033[0m"
    else
        echo "\033[0;31m✗ $component not found\033[0m"
    fi
}

echo "\n🔧 Loading configurations..."

# Path Configuration (must come first)
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme Configuration
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
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


# TMUX Auto-Start
if command -v tmux >/dev/null 2>&1; then
    if [ "$TMUX" = "" ]; then 
        tmux

        # Custom tmux alias to run tmux in all panes
        function tmux-all() {
          tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}" | 
            while read pane; do
              tmux send-keys -t "$pane" "$*" Enter
            done
        }
    fi
    print_status "Tmux" "enabled"
else
    print_status "Tmux" "disabled"
fi

# Run a command in all tmux panes
if command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
  function tmux-all() {
    tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}" | 
      while read pane; do
        tmux send-keys -t "$pane" "$*" Enter
      done
  }
  print_status "tmux-all" "enabled"
else
  function tmux-all() {
    print_status "tmux-all" "disabled"
    return 1
  }
fi

# Python Environment Configuration
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    print_status "Python (pyenv)" "enabled"
else
    print_status "Python (pyenv)" "disabled"
fi

# Homebrew and Python compatibility
brew() {
    local original_path="$PATH"
    local pyenv_path=""
    
    # Only modify PATH if pyenv exists and works
    if command -v pyenv >/dev/null 2>&1; then
        pyenv_path="$(pyenv root)/shims:"
        if [[ -n "$pyenv_path" ]]; then
            PATH="${PATH//$pyenv_path/}"
        fi
    fi
    
    # Execute brew with fallbacks
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        /opt/homebrew/bin/brew "$@"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        /usr/local/bin/brew "$@"
    else
        echo "Error: brew not found in expected locations" >&2
        return 1
    fi
    
    # Restore original PATH
    PATH="$original_path"
}

# Check Homebrew availability
if [[ -x "/opt/homebrew/bin/brew" ]] || [[ -x "/usr/local/bin/brew" ]]; then
    print_status "Homebrew" "enabled"
else
    print_status "Homebrew" "disabled"
fi


# NVM Configuration
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    source "/opt/homebrew/opt/nvm/nvm.sh"
    source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    print_status "Node Version Manager" "enabled"
else
    print_status "Node Version Manager" "disabled"
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

# Go Configuration
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$PATH:$GOPATH/bin

if command -v go >/dev/null 2>&1; then
    print_status "Go" "enabled ($(go version))"
else
    print_status "Go" "disabled"
fi

# Google Cloud SDK Configuration
if [ -d "/opt/homebrew/share/google-cloud-sdk" ]; then
    if [ -f "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc" ]; then
        source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
    fi
    if [ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]; then
        source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
    fi
    print_status "Google Cloud SDK" "enabled"
else
    print_status "Google Cloud SDK" "disabled"
fi

# Conda Configuration
if [ -f "/opt/homebrew/Caskroom/miniconda/base/bin/conda" ]; then
    __conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
        print_status "Conda" "enabled"
    else
        if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
            . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
            print_status "Conda" "enabled"
        else
            export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
            print_status "Conda (PATH only)" "enabled"
        fi
    fi
    unset __conda_setup
else
    print_status "Conda" "disabled"
fi

# Zinit Installation
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

# Zinit Configuration
if [ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]; then
    source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
    autoload -Uz _zinit
    (( ${+_comps} )) && _comps[zinit]=_zinit
    
    # Load Zinit annexes
    zinit light-mode for \
        zdharma-continuum/zinit-annex-as-monitor \
        zdharma-continuum/zinit-annex-bin-gem-node \
        zdharma-continuum/zinit-annex-patch-dl \
        zdharma-continuum/zinit-annex-rust
    
    # Zinit home setup
    ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    [ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
    [ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    source "${ZINIT_HOME}/zinit.zsh"
    
    # Zinit plugins
    zinit light zdharma-continuum/fast-syntax-highlighting
    zinit light zsh-users/zsh-autosuggestions
    zinit light zsh-users/zsh-completions
    
    print_status "Zinit" "enabled"
else
    print_status "Zinit" "disabled"
fi

# Source aliases (should be last)
# These contain secrets and things
export LOCAL_SECRETS="$HOME/afterzsh"
alias cd-secrets="cd $LOCAL_SECRETS"

# Source additional aliases if they exist
if [ -f $LOCAL_SECRETS/aliases.sh ]; then
    source $LOCAL_SECRETS/aliases.sh
    print_status "Custom Aliases" "enabled"
else
    print_status "Custom Aliases" "disabled"
fi

# Custom Config Set Up
export DEV="$HOME/Dev"
export DEV_VIVACITY="$DEV/vivacity"

alias please='sudo'

# Directory shortcuts
alias cdev='cd $DEV'
alias cdev-vivacity='cd $DEV_VIVACITY'
alias cdotfiles='cd $DEV/dotfiles'
alias c='clear'
alias hgrep="history | grep"
export NOTES="/Users/$USER/Documents/obsidian-vault"
alias notes='cd $NOTES'
alias notes-push='git add . && git commit -m "notes: $(date +%Y-%m-%d)" && git push'


# Autosuggestion configuration
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#999999"

echo "\n✨ Configuration loading complete\n"

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
