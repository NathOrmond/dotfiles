#!/bin/bash
# fix-permissions.sh - Makes all scripts executable in the dotfiles repository

# Get script directory and dotfiles root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"  # Parent of scripts directory

echo "🔧 Fixing permissions for dotfiles scripts..."

# Make all scripts in the scripts directory executable
echo "📁 Setting permissions for scripts in: $SCRIPT_DIR"
find "$SCRIPT_DIR" -name "*.sh" -type f -exec chmod +x {} \;
echo "✅ Fixed permissions for all scripts in scripts directory"

# Make install.sh executable
if [ -f "$DOTFILES_DIR/install.sh" ]; then
    chmod +x "$DOTFILES_DIR/install.sh"
    echo "✅ Fixed permissions for install.sh"
else
    echo "❌ install.sh not found"
fi

# Make packages.zsh executable
if [ -f "$DOTFILES_DIR/packages/packages.zsh" ]; then
    chmod +x "$DOTFILES_DIR/packages/packages.zsh"
    echo "✅ Fixed permissions for packages.zsh"
else
    echo "❌ packages.zsh not found"
fi

# Make zsh module files executable
if [ -d "$DOTFILES_DIR/zsh" ]; then
    find "$DOTFILES_DIR/zsh" -name "*.zsh" -type f -exec chmod +x {} \;
    echo "✅ Fixed permissions for zsh module files"
else
    echo "❌ zsh directory not found"
fi

# Make any other executable scripts in the dotfiles directory
find "$DOTFILES_DIR" -maxdepth 1 -name "*.sh" -type f -exec chmod +x {} \;

echo "✨ All permissions fixed successfully!"
echo "ℹ️  All scripts should now be executable"
