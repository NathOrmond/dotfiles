print_status() {
    local component=$1
    local state=$2
    if [ "$state" = "enabled" ]; then
        echo "\033[0;32m✓ $component configured\033[0m"
    else
        echo "\033[0;31m✗ $component not found\033[0m"
    fi
}

# Check if vim has clipboard support (this is a function but calls echo)
check_vim_clipboard() {
    if [[ "$PLATFORM" == "linux" ]]; then
        if command -v vim >/dev/null 2>&1; then
            if ! vim --version | grep -q '+clipboard'; then
                echo "📋 Vim does not have clipboard support. Installing vim-gtk3..."
                sudo apt-get update && sudo apt-get install -y vim-gtk3
                echo "✅ Installed vim with clipboard support."
            fi
        fi
    fi
}
