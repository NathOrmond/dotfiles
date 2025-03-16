#!/bin/zsh
# macOS specific settings

# macOS PATH additions
export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH

# Homebrew configuration
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# macOS clipboard aliases
alias copy="pbcopy"
alias paste="pbpaste"

# macOS specific aliases
alias showfiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder"
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# Homebrew package installation function
function install-pkg() {
    brew install "$@"
}

# Python management (pyenv)
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    print_status "Python (pyenv)" "enabled"
else
    print_status "Python (pyenv)" "disabled"
fi

# Node Version Manager
if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"
    source "/opt/homebrew/opt/nvm/nvm.sh"
    source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    print_status "Node Version Manager" "enabled"
else
    print_status "Node Version Manager" "disabled"
fi

# Go configuration
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$PATH:$GOPATH/bin

# Google Cloud SDK
if [ -d "/opt/homebrew/share/google-cloud-sdk" ]; then
    source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
    source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
    print_status "Google Cloud SDK" "enabled"
else
    print_status "Google Cloud SDK" "disabled"
fi

# macOS specific tmux configuration
if command -v tmux &> /dev/null; then
    # Enable copy-paste integration
    if command -v reattach-to-user-namespace &> /dev/null; then
        print_status "tmux clipboard integration" "enabled"
    else
        brew install reattach-to-user-namespace
        print_status "tmux clipboard integration" "installed"
    fi
fi
