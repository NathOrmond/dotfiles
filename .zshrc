#!/bin/zsh
# Main .zshrc file that sources modular components

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

# Source custom secrets and configurations
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

echo "\n✨ Configuration loading complete\n"
