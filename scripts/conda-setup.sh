#!/bin/zsh
# Get script directory and dotfiles root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"  # Parent of scripts directory

# Cross-platform Conda installation and setup

# Detect platform
if [[ "$(uname)" == "Darwin" ]]; then
    export PLATFORM="mac"
elif [[ "$(uname)" == "Linux" ]]; then
    export PLATFORM="linux"
else
    echo "Unsupported platform"
    exit 1
fi

# Check if conda is already installed
check_conda_installed() {
    if command -v conda &> /dev/null; then
        echo "✅ Conda is already installed."
        return 0
    else
        return 1
    fi
}

# Install conda on macOS
install_conda_mac() {
    echo "🍎 Installing Conda on macOS..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "🍺 Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    
    # Install Anaconda through Homebrew
    brew install --cask anaconda
    
    # Get the correct path based on architecture
    if [[ "$(uname -m)" == "arm64" ]]; then
        # Apple Silicon (M1/M2)
        CONDA_PATH="/opt/homebrew/anaconda3"
    else
        # Intel Mac
        CONDA_PATH="/usr/local/anaconda3"
    fi
    
    # Add to PATH in zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "$CONDA_PATH/bin" "$HOME/.zshrc"; then
            echo "export PATH=\"$CONDA_PATH/bin:\$PATH\"" >> "$HOME/.zshrc"
        fi
    fi
    
    # Initialize conda
    eval "$("$CONDA_PATH/bin/conda" "shell.zsh" "hook")"
    
    echo "✅ Conda installed successfully on macOS."
}

# Install conda on Linux/WSL
install_conda_linux() {
    echo "🐧 Installing Conda on Linux..."
    
    # Download latest Anaconda installer
    ANACONDA_VERSION="Anaconda3-2023.09-Linux-x86_64.sh"
    DOWNLOAD_URL="https://repo.anaconda.com/archive/$ANACONDA_VERSION"
    
    # Download if not already present
    if [[ ! -f "$HOME/$ANACONDA_VERSION" ]]; then
        echo "📥 Downloading Anaconda..."
        wget -q "$DOWNLOAD_URL" -O "$HOME/$ANACONDA_VERSION"
    fi
    
    # Run the installer
    echo "🔧 Running Anaconda installer..."
    bash "$HOME/$ANACONDA_VERSION" -b -p "$HOME/anaconda3"
    
    # Initialize conda
    eval "$("$HOME/anaconda3/bin/conda" "shell.zsh" "hook")"
    
    # Add to PATH in zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "$HOME/anaconda3/bin" "$HOME/.zshrc"; then
            echo "export PATH=\"$HOME/anaconda3/bin:\$PATH\"" >> "$HOME/.zshrc"
        fi
    fi
    
    # Clean up installer
    rm "$HOME/$ANACONDA_VERSION"
    
    echo "✅ Conda installed successfully on Linux."
}

# Configure conda after installation
configure_conda() {
    echo "🔧 Configuring Conda..."
    
    # Add common channels
    conda config --add channels conda-forge
    
    # Create base environment with common packages
    echo "📦 Installing common packages..."
    conda install -y jupyter numpy pandas matplotlib scikit-learn
    
    # Create environment for fastai if requested
    read -q "REPLY?Do you want to create a fastai environment? (y/n) "
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🧠 Creating fastai environment..."
        conda create -y -n fastai
        conda activate fastai
        conda install -y -c fastai fastai
        conda install -y -c fastai fastbook
    fi
    
    echo "✅ Conda configuration complete."
}

# Main installation function
install_conda() {
    # Check if conda is already installed
    if check_conda_installed; then
        read -q "REPLY?Conda is already installed. Do you want to reconfigure it? (y/n) "
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping conda installation and configuration."
            return
        fi
    fi
    
    # Install based on platform
    if [[ "$PLATFORM" == "mac" ]]; then
        install_conda_mac
    elif [[ "$PLATFORM" == "linux" ]]; then
        install_conda_linux
    fi
    
    # Configure conda
    configure_conda
}

# Run the installation
if [[ "$1" == "--install" ]]; then
    install_conda
else
    # Just check and report status
    if check_conda_installed; then
        echo "Conda is installed and ready to use."
        echo "To reconfigure conda, run: $(basename "$0") --install"
    else
        echo "Conda is not installed."
        echo "To install conda, run: $(basename "$0") --install"
    fi
fi
