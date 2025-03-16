#!/bin/bash
# Script to install ZSH plugins and Tmux Plugin Manager

echo "🔧 Setting up ZSH plugins and Tmux Plugin Manager..."

# Get script directory and dotfiles root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"  # Parent of scripts directory

# Function to print status messages
print_status() {
    local component=$1
    local state=$2
    if [ "$state" = "enabled" ]; then
        echo -e "\033[0;32m✓ $component installed\033[0m"
    elif [ "$state" = "updated" ]; then
        echo -e "\033[0;33m↻ $component updated\033[0m"
    else
        echo -e "\033[0;31m✗ $component failed\033[0m"
    fi
}

# Function to install or update a git repository
install_or_update_repo() {
    local repo_url=$1
    local target_dir=$2
    local component_name=$3
    
    if [ -d "$target_dir/.git" ]; then
        echo "Updating $component_name..."
        (cd "$target_dir" && git pull -q) && print_status "$component_name" "updated" || print_status "$component_name" "failed"
    else
        echo "Installing $component_name..."
        rm -rf "$target_dir"  # Remove directory if it exists but is not a git repo
        mkdir -p "$(dirname "$target_dir")"
        git clone -q "$repo_url" "$target_dir" && print_status "$component_name" "enabled" || print_status "$component_name" "failed"
    fi
}

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_status "Oh My Zsh" "enabled"
else
    print_status "Oh My Zsh" "enabled"
fi

# Install or update Powerlevel10k theme
install_or_update_repo \
    "https://github.com/romkatv/powerlevel10k.git" \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" \
    "Powerlevel10k Theme"

# Install or update zsh-autosuggestions
install_or_update_repo \
    "https://github.com/zsh-users/zsh-autosuggestions" \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" \
    "zsh-autosuggestions plugin"

# Install or update zsh-syntax-highlighting
install_or_update_repo \
    "https://github.com/zsh-users/zsh-syntax-highlighting" \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" \
    "zsh-syntax-highlighting plugin"

# Install or update Tmux Plugin Manager
install_or_update_repo \
    "https://github.com/tmux-plugins/tpm" \
    "$HOME/.tmux/plugins/tpm" \
    "Tmux Plugin Manager"

# Create .tmux/resurrect directory if it doesn't exist yet
mkdir -p "$HOME/.tmux/resurrect"

echo "✨ ZSH plugins and Tmux Plugin Manager setup complete!"
echo "ℹ️  To install Tmux plugins, press prefix + I (capital I) in a Tmux session"
