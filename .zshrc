#!/bin/zsh
# Main .zshrc file that sources modular components
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Helper function for status messages
print_status() {
    local component=$1
    local state=$2
    if [ "$state" = "enabled" ]; then
        echo "\033[0;32m✓ $component configured\033[0m"
    else
        echo "\033[0;31m✗ $component not found\033[0m"
    fi
}

echo "\n🔧 Loading configurations..."

# Detect platform (Mac or Linux)
if [[ "$(uname)" == "Darwin" ]]; then
    export PLATFORM="mac"
elif [[ "$(uname)" == "Linux" ]]; then
    export PLATFORM="linux"
else
    export PLATFORM="unknown"
fi
print_status "Platform detection ($PLATFORM)" "enabled"

# Path to dotfiles
export DOTFILES="$HOME/Dev/dotfiles"

# Source modular configuration files
if [[ -d "$DOTFILES/zsh" ]]; then
    # Source common configuration
    if [[ -f "$DOTFILES/zsh/common.zsh" ]]; then
        source "$DOTFILES/zsh/common.zsh"
        print_status "Common ZSH configuration" "enabled"
    else
        print_status "Common ZSH configuration" "disabled"
    fi
    
    # Source platform-specific configuration
    if [[ "$PLATFORM" == "mac" && -f "$DOTFILES/zsh/mac.zsh" ]]; then
        source "$DOTFILES/zsh/mac.zsh"
        print_status "macOS configuration" "enabled"
    elif [[ "$PLATFORM" == "linux" && -f "$DOTFILES/zsh/linux.zsh" ]]; then
        source "$DOTFILES/zsh/linux.zsh"
        print_status "Linux configuration" "enabled"
    else
        print_status "Platform-specific configuration" "disabled"
    fi
    
    # Source functions
    if [[ -f "$DOTFILES/zsh/functions.zsh" ]]; then
        source "$DOTFILES/zsh/functions.zsh"
        print_status "ZSH functions" "enabled"
    else
        print_status "ZSH functions" "disabled"
    fi
    
    # Source aliases
    if [[ -f "$DOTFILES/zsh/aliases.zsh" ]]; then
        source "$DOTFILES/zsh/aliases.zsh"
        print_status "ZSH aliases" "enabled"
    else
        print_status "ZSH aliases" "disabled"
    fi
    
    # Source plugins configuration
    if [[ -f "$DOTFILES/zsh/plugins.zsh" ]]; then
        source "$DOTFILES/zsh/plugins.zsh"
        print_status "ZSH plugins" "enabled"
    else
        print_status "ZSH plugins" "disabled"
    fi
else
    print_status "Modular ZSH configurations" "disabled"
fi

# Check if vim has clipboard support
check_vim_clipboard() {
    if [[ "$PLATFORM" == "linux" ]]; then
        if command -v vim >/dev/null 2>&1; then
            if ! vim --version | grep -q '+clipboard'; then
                echo "📋 Vim does not have clipboard support. Installing vim-gtk3..."
                sudo apt-get update && sudo apt-get install -y vim-gtk3
                echo "✅ Installed vim with clipboard support."
            fi
        fi
    fi
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
export GOROOT=opt/homebrew/bin
export GOPATH=$GOROOT/go
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
if [[ -f "$LOCAL_SECRETS/aliases.sh" ]]; then
    source "$LOCAL_SECRETS/aliases.sh"
    print_status "Custom Aliases" "enabled"
else
    print_status "Custom Aliases" "disabled"
fi

# Check if dotfiles need installation
if [[ -d "$DOTFILES" ]]; then
    # Check if .zshrc is a symlink pointing to the correct location
    if [[ ! -L "$HOME/.zshrc" || "$(readlink "$HOME/.zshrc")" != "$DOTFILES/.zshrc" ]]; then
        echo "Dotfiles need to be installed. Running install script..."
        if [[ -f "$DOTFILES/install.sh" ]]; then
            chmod +x "$DOTFILES/install.sh"
            "$DOTFILES/install.sh"
        fi
    fi
    
    # Check for vim clipboard support
    check_vim_clipboard
fi

# Custom Config Set Up
export DEV="$HOME/Dev"
export DEV_VIVACITY="$DEV/vivacity"
# 1PASS SSH agent
export SSH_AUTH_SOCK=~/.1password/agent.sock
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

export SSH_AUTH_SOCK=~/.1password/agent.sock


# Autosuggestion configuration
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#999999"

echo "\n✨ Configuration loading complete\n"
export PATH="/root/anaconda3/bin:$PATH"
