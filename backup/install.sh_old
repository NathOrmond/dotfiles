#!/bin/zsh

DOTFILES="$HOME/Dev/dotfiles"

# Create ~/.config if it doesn't exist
 mkdir -p ~/.config

# Direct home directory files
files=(".zshrc" ".tmux.conf" ".gitconfig" ".vimrc" ".bashrc" ".profile" ".p10k.zsh")
for file in "${files[@]}"; do
    if [ -f "$DOTFILES/$file" ]; then
        ln -sf "$DOTFILES/$file" "$HOME/$file"
        echo "Created symlink for $file"
    fi
done
 
# .config directory files
config_folders=("nvim" "alacritty" "lazygit" "starship")
for folder in "${config_folders[@]}"; do
    if [ -d "$DOTFILES/.config/$folder" ]; then
        ln -sf "$DOTFILES/.config/$folder" "$HOME/.config/$folder"
        echo "Created symlink for .config/$folder"
    fi
done
