#!/bin/zsh
DOTFILES="$HOME/Dev/dotfiles"

echo "🔧 Installing dotfiles from $DOTFILES..."

# Create ~/.config if it doesn't exist
mkdir -p ~/.config

# Direct home directory files
files=(".zshrc" ".tmux.conf" ".gitconfig" ".vimrc" ".bashrc" ".profile" ".p10k.zsh" ".zprofile")
for file in "${files[@]}"; do
    if [ -f "$DOTFILES/$file" ]; then
        ln -sf "$DOTFILES/$file" "$HOME/$file"
        echo "✅ Created symlink for $file"
    else
        echo "❌ Source file $file not found in $DOTFILES"
    fi
done
 
# .config directory files
config_folders=("nvim" "alacritty" "lazygit" "starship")
for folder in "${config_folders[@]}"; do
    if [ -d "$DOTFILES/.config/$folder" ]; then
        ln -sf "$DOTFILES/.config/$folder" "$HOME/.config/$folder"
        echo "✅ Created symlink for .config/$folder"
    else
        echo "❌ Source folder .config/$folder not found in $DOTFILES"
    fi
done

# Detect platform (Mac or Linux)
PLATFORM="unknown"
if [[ "$(uname)" == "Darwin" ]]; then
    PLATFORM="mac"
    echo "📱 Platform detected: macOS"
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install packages from Brewfile if it exists
    if [ -f "$DOTFILES/.Brewfile" ]; then
        echo "🍺 Installing packages from Brewfile..."
        brew bundle --file="$DOTFILES/.Brewfile"
    fi
    
elif [[ "$(uname)" == "Linux" ]]; then
    PLATFORM="linux"
    echo "🐧 Platform detected: Linux"
    
    # Install essential packages for Linux
    echo "📦 Installing essential Linux packages..."
    sudo apt-get update
    sudo apt-get install -y zsh tmux git curl wget xclip neovim python3-pip
    
    # Ensure we have a clipboard-enabled version of vim
    if ! vim --version 2>/dev/null | grep -q '+clipboard'; then
        echo "🔄 Installing vim with clipboard support..."
        sudo apt-get install -y vim-gtk3
    fi
    
    # Install Oh My Zsh if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "🐚 Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Install powerlevel10k theme if not already installed
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        echo "🎨 Installing powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi
fi

# Create the afterzsh directory if it doesn't exist
AFTERZSH="$HOME/afterzsh"
if [ ! -d "$AFTERZSH" ]; then
    mkdir -p "$AFTERZSH"
    echo "📁 Created secrets directory at $AFTERZSH"
    echo "   👉 Add your sensitive information and machine-specific settings here"
    
    # Create a basic aliases.sh file if it doesn't exist
    if [ ! -f "$AFTERZSH/aliases.sh" ]; then
        cat > "$AFTERZSH/aliases.sh" << EOL
# Custom aliases
# Add your aliases here

# Common aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'

# Docker aliases
alias dps='docker ps'
alias di='docker images'
alias dc='docker-compose'

# Platform-specific aliases are handled in .zshrc
EOL
        echo "📝 Created basic aliases.sh file in $AFTERZSH"
    fi
    
    # Create a template for secrets.sh
    if [ ! -f "$AFTERZSH/secrets.sh" ]; then
        cat > "$AFTERZSH/secrets.sh" << EOL
# Sensitive information and secrets
# This file is not tracked by git

# Example: API tokens
# export GITHUB_TOKEN="your-token-here"
# export AWS_ACCESS_KEY_ID="your-key-here"
# export AWS_SECRET_ACCESS_KEY="your-secret-here"

# Example: Private aliases
# alias ssh-work="ssh user@work-server.example.com"

# Add your secrets below:

EOL
        echo "📝 Created secrets.sh template in $AFTERZSH (not tracked by git)"
        
        # Add sourcing of secrets.sh to aliases.sh if not already there
        if ! grep -q "source ~/afterzsh/secrets.sh" "$AFTERZSH/aliases.sh"; then
            echo "# Source secrets" >> "$AFTERZSH/aliases.sh"
            echo "if [ -f \"$AFTERZSH/secrets.sh\" ]; then" >> "$AFTERZSH/aliases.sh"
            echo "    source \"$AFTERZSH/secrets.sh\"" >> "$AFTERZSH/aliases.sh"
            echo "fi" >> "$AFTERZSH/aliases.sh"
        fi
    fi
    
    # Copy Jupyter helpers if available
    if [ -f "$DOTFILES/scripts/jupyter-aliases.sh" ]; then
        cp "$DOTFILES/scripts/jupyter-aliases.sh" "$AFTERZSH/jupyter-aliases.sh"
        chmod +x "$AFTERZSH/jupyter-aliases.sh"
        if ! grep -q "source ~/afterzsh/jupyter-aliases.sh" "$AFTERZSH/aliases.sh"; then
            echo "# Source Jupyter helpers" >> "$AFTERZSH/aliases.sh"
            echo "if [ -f \"$AFTERZSH/jupyter-aliases.sh\" ]; then" >> "$AFTERZSH/aliases.sh"
            echo "    source \"$AFTERZSH/jupyter-aliases.sh\"" >> "$AFTERZSH/aliases.sh"
            echo "fi" >> "$AFTERZSH/aliases.sh"
        fi
        echo "📝 Added Jupyter helpers to $AFTERZSH"
    fi
else
    echo "✅ Using existing secrets directory at $AFTERZSH"
fi

# Ask about Conda installation
if ! command -v conda &> /dev/null; then
    echo ""
    read -q "REPLY?Do you want to install Anaconda/Conda? (y/n) "
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "$DOTFILES/scripts/conda-setup.sh" ]; then
            echo "🐍 Installing Conda..."
            chmod +x "$DOTFILES/scripts/conda-setup.sh"
            "$DOTFILES/scripts/conda-setup.sh" --install
        else
            echo "❌ conda-setup.sh not found in dotfiles directory"
        fi
    fi
else
    echo "✅ Conda is already installed"
fi

# Install ZSH plugins and Tmux Plugin Manager
if [ -f "$DOTFILES/scripts/setup-plugins.sh" ]; then
    echo "🔌 Setting up ZSH plugins and Tmux Plugin Manager..."
    chmod +x "$DOTFILES/scripts/setup-plugins.sh"
    "$DOTFILES/scripts/setup-plugins.sh"
else
    echo "❌ setup-plugins.sh not found in scripts directory"
fi

# Reload tmux configuration if tmux is running
if command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
    echo "🔄 Reloading tmux configuration..."
    tmux source-file "$HOME/.tmux.conf"
fi

echo "✨ Dotfiles installation complete!"
echo "🔄 Reloading zsh configuration..."

# Source zsh configuration
exec zsh -l#!/bin/zsh
DOTFILES="$HOME/Dev/dotfiles"

echo "🔧 Installing dotfiles from $DOTFILES..."

# Create ~/.config if it doesn't exist
mkdir -p ~/.config

# Direct home directory files
files=(".zshrc" ".tmux.conf" ".gitconfig" ".vimrc" ".bashrc" ".profile" ".p10k.zsh")
for file in "${files[@]}"; do
    if [ -f "$DOTFILES/$file" ]; then
        ln -sf "$DOTFILES/$file" "$HOME/$file"
        echo "✅ Created symlink for $file"
    else
        echo "❌ Source file $file not found in $DOTFILES"
    fi
done
 
# .config directory files
config_folders=("nvim" "alacritty" "lazygit" "starship")
for folder in "${config_folders[@]}"; do
    if [ -d "$DOTFILES/.config/$folder" ]; then
        ln -sf "$DOTFILES/.config/$folder" "$HOME/.config/$folder"
        echo "✅ Created symlink for .config/$folder"
    else
        echo "❌ Source folder .config/$folder not found in $DOTFILES"
    fi
done

# Detect platform (Mac or Linux)
PLATFORM="unknown"
if [[ "$(uname)" == "Darwin" ]]; then
    PLATFORM="mac"
    echo "📱 Platform detected: macOS"
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install packages from Brewfile if it exists
    if [ -f "$DOTFILES/.Brewfile" ]; then
        echo "🍺 Installing packages from Brewfile..."
        brew bundle --file="$DOTFILES/.Brewfile"
    fi
    
elif [[ "$(uname)" == "Linux" ]]; then
    PLATFORM="linux"
    echo "🐧 Platform detected: Linux"
    
    # Install essential packages for Linux
    echo "📦 Installing essential Linux packages..."
    sudo apt-get update
    sudo apt-get install -y zsh tmux git curl wget xclip neovim python3-pip
    
    # Ensure we have a clipboard-enabled version of vim
    if ! vim --version 2>/dev/null | grep -q '+clipboard'; then
        echo "🔄 Installing vim with clipboard support..."
        sudo apt-get install -y vim-gtk3
    fi
    
    # Install Oh My Zsh if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "🐚 Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Install powerlevel10k theme if not already installed
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        echo "🎨 Installing powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi
fi

# Create the afterzsh directory if it doesn't exist
if [ ! -d "$HOME/afterzsh" ]; then
    mkdir -p "$HOME/afterzsh"
    echo "📁 Created afterzsh directory"
    
    # Create a basic aliases.sh file if it doesn't exist
    if [ ! -f "$HOME/afterzsh/aliases.sh" ]; then
        cat > "$HOME/afterzsh/aliases.sh" << EOL
# Custom aliases
# Add your aliases here

# Common aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'

# Docker aliases
alias dps='docker ps'
alias di='docker images'
alias dc='docker-compose'

# Platform-specific aliases are handled in .zshrc
EOL
        echo "📝 Created basic aliases.sh file"
    fi
fi

# Reload tmux configuration if tmux is running
if command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
    echo "🔄 Reloading tmux configuration..."
    tmux source-file "$HOME/.tmux.conf"
fi

echo "✨ Dotfiles installation complete!"
echo "🔄 Reloading zsh configuration..."

# Source zsh configuration
exec zsh -l
