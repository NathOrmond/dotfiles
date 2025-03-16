#!/bin/bash
# Script to restore dotfiles to a specific commit

# Get script directory and dotfiles root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"  # Parent of scripts directory

SPECIFIC_COMMIT="a11de4193c30fbf1df5d78209b36cc5d14431eaa"

# Function to confirm action
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Operation cancelled"
        exit 1
    fi
}

echo "🔄 Preparing to restore dotfiles to commit: $SPECIFIC_COMMIT"
echo "Current dotfiles location: $DOTFILES_DIR"

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ Error: Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

# Check if it's a git repository
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "❌ Error: $DOTFILES_DIR is not a git repository"
    exit 1
fi

# Backup current state before restoration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$DOTFILES_DIR/backup/prerestoration_$TIMESTAMP"

echo "📦 Creating backup of current state at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -r "$DOTFILES_DIR"/.zshrc "$BACKUP_DIR"/ 2>/dev/null
cp -r "$DOTFILES_DIR"/.vimrc "$BACKUP_DIR"/ 2>/dev/null
cp -r "$DOTFILES_DIR"/.tmux.conf "$BACKUP_DIR"/ 2>/dev/null
cp -r "$DOTFILES_DIR"/.gitconfig "$BACKUP_DIR"/ 2>/dev/null
cp -r "$DOTFILES_DIR"/install.sh "$BACKUP_DIR"/ 2>/dev/null

# Get current branch
CURRENT_BRANCH=$(cd "$DOTFILES_DIR" && git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

confirm "This will reset your dotfiles to commit $SPECIFIC_COMMIT. Continue?"

# Navigate to dotfiles directory and reset to specific commit
cd "$DOTFILES_DIR"

# Check if there are uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    echo "⚠️ Uncommitted changes detected"
    confirm "Do you want to stash your changes before proceeding?"
    git stash save "Automatic stash before restoration to $SPECIFIC_COMMIT"
    echo "✅ Changes stashed"
fi

echo "🔄 Resetting to commit $SPECIFIC_COMMIT..."
git fetch
git checkout $SPECIFIC_COMMIT

# Check if reset was successful
if [ $? -eq 0 ]; then
    echo "✅ Successfully restored dotfiles to commit $SPECIFIC_COMMIT"
    echo "💡 Note: You are now in 'detached HEAD' state"
    echo "   To return to your branch, run: git checkout $CURRENT_BRANCH"
    echo ""
    echo "📝 The previous state was backed up to: $BACKUP_DIR"
else
    echo "❌ Failed to restore dotfiles"
    echo "📝 You can manually restore from the backup at: $BACKUP_DIR"
    exit 1
fi

# Re-run the install script if it exists
if [ -f "$DOTFILES_DIR/install.sh" ]; then
    confirm "Do you want to run the install script to update symlinks?"
    chmod +x "$DOTFILES_DIR/install.sh"
    "$DOTFILES_DIR/install.sh"
fi
