#!/bin/bash
# Show debugging information for dotfiles setup

echo "ZSH Version:"
zsh --version

echo -e "\nOh My Zsh directory contents:"
ls -la ~/.oh-my-zsh/custom/plugins/

echo -e "\nTMux plugins directory contents:"
ls -la ~/.tmux/plugins/

echo -e "\nCurrent PLATFORM value:"
echo $PLATFORM

echo -e "\nAliases currently defined:"
alias

echo -e "\nTMux configuration:"
grep "set -g @plugin" ~/.tmux.conf

echo -e "\nTMux prefix setting:"
tmux show -g prefix 2>/dev/null || echo "TMux not running"

echo -e "\nFocus tracking in common.zsh:"
grep -A 10 "focus tracking" ~/Dev/dotfiles/zsh/common.zsh
