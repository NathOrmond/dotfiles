# Linux-specific ZSH configuration
echo "DEBUG: Starting Linux-specific configuration"
#!/bin/zsh

# Linux/WSL specific settings

# Linux-specific ZSH configuration - BEGIN
echo "DEBUG: Starting Linux configuration"# Linux PATH additions
export PATH=/usr/local/bin:$PATH

# Check if we're in WSL
if grep -q Microsoft /proc/version; then
    export IS_WSL=true
else
    export IS_WSL=false
fi

# Linux clipboard aliases
if command -v xclip &> /dev/null; then
    alias copy="xclip -selection clipboard"
    alias paste="xclip -selection clipboard -o"
elif [[ "$IS_WSL" == "true" ]]; then
    alias copy="clip.exe"
    alias paste="powershell.exe -command 'Get-Clipboard' 2>/dev/null"
else
    echo "WARNING: No clipboard command found. Clipboard aliases not set."
fi

# Linux specific aliases
alias ls="ls --color=auto"
alias open="xdg-open"
alias update="sudo apt-get update && sudo apt-get upgrade -y"
alias install="sudo apt-get install -y"

# Linux clipboard aliases
if command -v xclip &> /dev/null; then
    alias copy="xclip -selection clipboard"
    alias paste="xclip -selection clipboard -o"
else
    # Try to install xclip
    if command -v apt-get &> /dev/null; then
        echo "Installing xclip for clipboard support..."
        sudo apt-get update && sudo apt-get install -y xclip
        alias copy="xclip -selection clipboard"
        alias paste="xclip -selection clipboard -o"
    else
        echo "xclip not available and couldn't be installed."
        # Fallback for WSL
        if [[ "$IS_WSL" == "true" ]]; then
            alias copy="clip.exe"
            alias paste="powershell.exe -command 'Get-Clipboard' 2>/dev/null"
        fi
    fi
fi

# Linux specific aliases
alias ls="ls --color=auto"
alias open="xdg-open"
alias update="sudo apt-get update && sudo apt-get upgrade -y"
alias install="sudo apt-get install -y"

# Package installation function
function install-pkg() {
    sudo apt-get update && sudo apt-get install -y "$@"
}

# Node Version Manager
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"
    source "$HOME/.nvm/nvm.sh"
    print_status "Node Version Manager" "enabled"
else
    print_status "Node Version Manager" "disabled"
fi

# Go configuration
if [ -d "/usr/local/go" ]; then
    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go
    export PATH=$GOROOT/bin:$PATH:$GOPATH/bin
    print_status "Go" "enabled"
elif [ -d "/usr/lib/go" ]; then
    export GOROOT=/usr/lib/go
    export GOPATH=$HOME/go
    export PATH=$GOROOT/bin:$PATH:$GOPATH/bin
    print_status "Go" "enabled"
else
    print_status "Go" "disabled"
fi

# Google Cloud SDK
if [ -d "/usr/lib/google-cloud-sdk" ]; then
    source "/usr/lib/google-cloud-sdk/path.zsh.inc"
    source "/usr/lib/google-cloud-sdk/completion.zsh.inc"
    print_status "Google Cloud SDK" "enabled"
else
    print_status "Google Cloud SDK" "disabled"
fi

# WSL-specific configurations
if [[ "$IS_WSL" == "true" ]]; then
    # Setup for GUI applications
    export DISPLAY=:0
    
    # Fix for slow WSL2 I/O performance
    export DOCKER_HOST=tcp://localhost:2375
    
    print_status "WSL configuration" "enabled"
fi

