#!/bin/bash
# Script to automatically install TMux plugins without user interaction

# Get script directory and dotfiles root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"  # Parent of scripts directory

echo "🔌 Installing TMux plugins..."

# Check if TPM is installed
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "⚠️ TMux Plugin Manager not found. Installing..."
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# Save the current TMux configuration to a temporary file
TMUX_TEMP=$(mktemp)
cat "$DOTFILES_DIR/.tmux.conf" > "$TMUX_TEMP"

# Install TMux plugins non-interactively
TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins" \
"$HOME/.tmux/plugins/tpm/bin/install_plugins" > /dev/null 2>&1

# Reload TMux configuration if TMux is running
if command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
    tmux source-file "$DOTFILES_DIR/.tmux.conf"
    echo "✅ TMux configuration reloaded"
fi

echo "✅ TMux plugins installed successfully"
