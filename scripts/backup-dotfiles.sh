#!/bin/bash
# Script to backup existing dotfiles before making changes

# Get script directory and dotfiles root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"  # Parent of scripts directory

# Create a timestamp for the backup folder
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$DOTFILES_DIR/backup/backup_$TIMESTAMP"

echo "🔄 Creating backup of dotfiles at $BACKUP_DIR"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Copy all existing dotfiles to backup folder
cp -r "$DOTFILES_DIR"/.zshrc "$BACKUP_DIR"/ 2>/dev/null
cp -r "$DOTFILES_DIR"/.vimrc "$BACKUP_DIR"/ 2>/dev/null
cp -r "$DOTFILES_DIR"/.tmux.conf "$BACKUP_DIR"/ 2>/dev/null
cp -r "$DOTFILES_DIR"/.gitconfig "$BACKUP_DIR"/ 2>/dev/null
cp -r "$DOTFILES_DIR"/install.sh "$BACKUP_DIR"/ 2>/dev/null

echo "✅ Dotfiles backed up successfully"

# Create a marker file with Git commit hash for future reference
CURRENT_COMMIT=$(cd "$DOTFILES_DIR" && git rev-parse HEAD)
echo "$CURRENT_COMMIT" > "$BACKUP_DIR/commit_hash.txt"

# Log details about the backup
cat > "$BACKUP_DIR/backup_info.txt" << INNEREOF
Dotfiles Backup
===============
Date: $(date)
Git Commit: $CURRENT_COMMIT
Backed up from: $DOTFILES_DIR

This backup was created before restructuring the dotfiles.
INNEREOF

echo "📝 Backup information saved to $BACKUP_DIR/backup_info.txt"
