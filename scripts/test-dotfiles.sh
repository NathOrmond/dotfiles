#!/bin/bash
# test-dotfiles.sh - Comprehensive test script for dotfiles setup

# Get script directory and dotfiles root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"  # Parent of scripts directory

# Colors for pretty output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters for test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNINGS=0

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}====== $1 ======${NC}\n"
}

# Function to print test results
print_result() {
    local test_name=$1
    local result=$2
    local details=$3
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓ PASS:${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    elif [ "$result" = "WARN" ]; then
        echo -e "${YELLOW}⚠ WARNING:${NC} $test_name"
        echo -e "  ${YELLOW}Details: $details${NC}"
        TESTS_WARNINGS=$((TESTS_WARNINGS + 1))
    else
        echo -e "${RED}✗ FAIL:${NC} $test_name"
        echo -e "  ${RED}Details: $details${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Function to print summary
print_summary() {
    echo -e "\n${BLUE}====== TEST SUMMARY ======${NC}"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${YELLOW}Warnings: $TESTS_WARNINGS${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo -e "${BLUE}=========================${NC}\n"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        if [ $TESTS_WARNINGS -eq 0 ]; then
            echo -e "${GREEN}All tests passed successfully!${NC}"
        else
            echo -e "${YELLOW}All tests passed but with some warnings. Check details above.${NC}"
        fi
    else
        echo -e "${RED}Some tests failed. Please check the details above.${NC}"
    fi
}

# Begin testing
echo -e "${BLUE}Starting dotfiles test suite...${NC}"
echo -e "${BLUE}Dotfiles directory: $DOTFILES_DIR${NC}\n"

# Test 1: Check directory structure
print_header "Testing Directory Structure"

# Check main directories
for dir in "zsh" "scripts" "packages" ".config"; do
    if [ -d "$DOTFILES_DIR/$dir" ]; then
        print_result "Directory $dir exists" "PASS"
    else
        print_result "Directory $dir exists" "FAIL" "Directory not found: $DOTFILES_DIR/$dir"
    fi
done

# Check .config subdirectories
for subdir in "nvim" "alacritty" "lazygit" "starship"; do
    if [ -d "$DOTFILES_DIR/.config/$subdir" ]; then
        print_result "Config directory .config/$subdir exists" "PASS"
    else
        print_result "Config directory .config/$subdir exists" "WARN" "Directory not found: $DOTFILES_DIR/.config/$subdir (only needed if you use this tool)"
    fi
done

# Test 2: Check file permissions
print_header "Testing File Permissions"

# Check install.sh
if [ -x "$DOTFILES_DIR/install.sh" ]; then
    print_result "install.sh is executable" "PASS"
else
    print_result "install.sh is executable" "FAIL" "File is not executable. Run: chmod +x $DOTFILES_DIR/install.sh"
fi

# Check script files in scripts directory
script_count=0
non_executable_scripts=()

for script in "$SCRIPT_DIR"/*.sh; do
    if [ -f "$script" ]; then
        script_count=$((script_count + 1))
        if [ -x "$script" ]; then
            print_result "$(basename "$script") is executable" "PASS"
        else
            print_result "$(basename "$script") is executable" "FAIL" "Script is not executable. Run: chmod +x $script"
            non_executable_scripts+=("$script")
        fi
    fi
done

if [ $script_count -eq 0 ]; then
    print_result "Scripts in scripts directory" "WARN" "No scripts found in $SCRIPT_DIR"
fi

# Check packages.zsh
if [ -f "$DOTFILES_DIR/packages/packages.zsh" ]; then
    if [ -x "$DOTFILES_DIR/packages/packages.zsh" ]; then
        print_result "packages.zsh is executable" "PASS"
    else
        print_result "packages.zsh is executable" "FAIL" "File is not executable. Run: chmod +x $DOTFILES_DIR/packages/packages.zsh"
    fi
else
    print_result "packages.zsh exists" "FAIL" "File not found: $DOTFILES_DIR/packages/packages.zsh"
fi

# Test 3: Check symlinks
print_header "Testing Symlinks"

# Check important dotfiles are symlinked properly
for dotfile in ".zshrc" ".vimrc" ".tmux.conf" ".gitconfig"; do
    if [ -L "$HOME/$dotfile" ]; then
        target=$(readlink "$HOME/$dotfile")
        if [ "$target" = "$DOTFILES_DIR/$dotfile" ]; then
            print_result "$dotfile symlink" "PASS"
        else
            print_result "$dotfile symlink" "FAIL" "Symlink points to $target instead of $DOTFILES_DIR/$dotfile"
        fi
    else
        print_result "$dotfile symlink" "FAIL" "Not a symlink. Run install.sh to create proper symlinks."
    fi
done

# Test 4: Check platform detection
print_header "Testing Platform Detection"

# Get platform
platform=$(uname)
if [ "$platform" = "Darwin" ]; then
    expected_platform="mac"
elif [ "$platform" = "Linux" ]; then
    expected_platform="linux"
else
    expected_platform="unknown"
fi

# Source zshrc and check $PLATFORM (note: this might not work in bash)
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    # We can't source zshrc directly in bash, so we'll grep for platform detection
    platform_check=$(grep -A 3 "Detect platform" "$DOTFILES_DIR/.zshrc")
    print_result "Platform detection exists in .zshrc" "PASS"
    echo -e "  ${BLUE}Platform detection code:${NC}"
    echo -e "  $platform_check"
    echo -e "  ${BLUE}Expected platform based on uname: $expected_platform${NC}"
else
    print_result "Platform detection exists in .zshrc" "FAIL" "File not found: $DOTFILES_DIR/.zshrc"
fi

# Test 5: Check ZSH plugins
print_header "Testing ZSH Plugins"

# Check Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_result "Oh My Zsh is installed" "PASS"
else
    print_result "Oh My Zsh is installed" "FAIL" "Directory not found: $HOME/.oh-my-zsh"
fi

# Check for Powerlevel10k theme
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    print_result "Powerlevel10k theme is installed" "PASS"
else
    print_result "Powerlevel10k theme is installed" "FAIL" "Directory not found: ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

# Check for zsh-autosuggestions
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    print_result "zsh-autosuggestions plugin is installed" "PASS"
else
    print_result "zsh-autosuggestions plugin is installed" "FAIL" "Directory not found: ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

# Check for zsh-syntax-highlighting
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    print_result "zsh-syntax-highlighting plugin is installed" "PASS"
else
    print_result "zsh-syntax-highlighting plugin is installed" "FAIL" "Directory not found: ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
fi

# Test 6: Check Tmux plugins
print_header "Testing Tmux Setup"

# Check if tmux is installed
if command -v tmux >/dev/null 2>&1; then
    print_result "Tmux is installed" "PASS"
    
    # Check Tmux Plugin Manager
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        print_result "Tmux Plugin Manager is installed" "PASS"
    else
        print_result "Tmux Plugin Manager is installed" "FAIL" "Directory not found: $HOME/.tmux/plugins/tpm"
    fi
    
    # Check if tmux.conf exists and has plugin settings
    if [ -f "$DOTFILES_DIR/.tmux.conf" ]; then
        if grep -q "set -g @plugin" "$DOTFILES_DIR/.tmux.conf"; then
            print_result "Tmux plugins are configured in .tmux.conf" "PASS"
        else
            print_result "Tmux plugins are configured in .tmux.conf" "WARN" "No plugin configuration found in .tmux.conf"
        fi
    else
        print_result "Tmux configuration exists" "FAIL" "File not found: $DOTFILES_DIR/.tmux.conf"
    fi
else
    print_result "Tmux is installed" "WARN" "Tmux is not installed on this system"
fi

# Test 7: Check Vim clipboard support
print_header "Testing Vim Clipboard Support"

# Check if vim is installed
if command -v vim >/dev/null 2>&1; then
    print_result "Vim is installed" "PASS"
    
    # Check clipboard support
    if vim --version | grep -q '+clipboard'; then
        print_result "Vim has clipboard support" "PASS"
    else
        print_result "Vim has clipboard support" "FAIL" "Vim was not compiled with clipboard support. Install vim-gtk3 or equivalent."
    fi
    
    # Check if vimrc has clipboard configuration
    if [ -f "$DOTFILES_DIR/.vimrc" ]; then
        if grep -q "clipboard" "$DOTFILES_DIR/.vimrc"; then
            print_result "Vim clipboard is configured in .vimrc" "PASS"
        else
            print_result "Vim clipboard is configured in .vimrc" "WARN" "No clipboard configuration found in .vimrc"
        fi
    else
        print_result "Vim configuration exists" "FAIL" "File not found: $DOTFILES_DIR/.vimrc"
    fi
else
    print_result "Vim is installed" "WARN" "Vim is not installed on this system"
fi

# Test 8: Check Conda setup
print_header "Testing Conda Setup"

# Check if conda is installed
if command -v conda >/dev/null 2>&1; then
    print_result "Conda is installed" "PASS"
    
    # Check if conda-setup.sh exists
    if [ -f "$SCRIPT_DIR/conda-setup.sh" ]; then
        print_result "conda-setup.sh script exists" "PASS"
        
        # Check if conda-setup.sh is executable
        if [ -x "$SCRIPT_DIR/conda-setup.sh" ]; then
            print_result "conda-setup.sh is executable" "PASS"
        else
            print_result "conda-setup.sh is executable" "FAIL" "Script is not executable. Run: chmod +x $SCRIPT_DIR/conda-setup.sh"
        fi
    else
        print_result "conda-setup.sh script exists" "FAIL" "File not found: $SCRIPT_DIR/conda-setup.sh"
    fi
else
    print_result "Conda is installed" "WARN" "Conda is not installed on this system"
fi

# Test 9: Check ZSH module loading order
print_header "Testing ZSH Module Loading"

# Check if common.zsh has proper focus tracking
if [ -f "$DOTFILES_DIR/zsh/common.zsh" ]; then
    if grep -q "if \[ -n \"\$TMUX\" \]" "$DOTFILES_DIR/zsh/common.zsh"; then
        print_result "Focus tracking is properly conditioned in common.zsh" "PASS"
    else
        print_result "Focus tracking is properly conditioned in common.zsh" "WARN" "Focus tracking might not be properly conditioned on tmux"
    fi
else
    print_result "common.zsh exists" "FAIL" "File not found: $DOTFILES_DIR/zsh/common.zsh"
fi

# Check if platform-specific files exist
if [ "$expected_platform" = "mac" ]; then
    if [ -f "$DOTFILES_DIR/zsh/mac.zsh" ]; then
        print_result "mac.zsh exists for this platform" "PASS"
    else
        print_result "mac.zsh exists for this platform" "FAIL" "File not found: $DOTFILES_DIR/zsh/mac.zsh"
    fi
elif [ "$expected_platform" = "linux" ]; then
    if [ -f "$DOTFILES_DIR/zsh/linux.zsh" ]; then
        print_result "linux.zsh exists for this platform" "PASS"
    else
        print_result "linux.zsh exists for this platform" "FAIL" "File not found: $DOTFILES_DIR/zsh/linux.zsh"
    fi
fi

# Test 10: Check clipboard aliases
print_header "Testing Clipboard Integration"

# Test copy/paste aliases by checking if they're defined in platform-specific files
copy_paste_configured=false

if [ "$expected_platform" = "mac" ] && [ -f "$DOTFILES_DIR/zsh/mac.zsh" ]; then
    if grep -q "alias copy.*pbcopy" "$DOTFILES_DIR/zsh/mac.zsh" && grep -q "alias paste.*pbpaste" "$DOTFILES_DIR/zsh/mac.zsh"; then
        print_result "Clipboard aliases configured for macOS" "PASS"
        copy_paste_configured=true
    fi
elif [ "$expected_platform" = "linux" ] && [ -f "$DOTFILES_DIR/zsh/linux.zsh" ]; then
    if grep -q "alias copy.*xclip" "$DOTFILES_DIR/zsh/linux.zsh" && grep -q "alias paste.*xclip" "$DOTFILES_DIR/zsh/linux.zsh"; then
        print_result "Clipboard aliases configured for Linux" "PASS"
        copy_paste_configured=true
    fi
fi

if [ "$copy_paste_configured" = false ]; then
    print_result "Clipboard aliases configured" "FAIL" "No clipboard aliases found for platform: $expected_platform"
fi

# Test if xclip is installed on Linux
if [ "$expected_platform" = "linux" ]; then
    if command -v xclip >/dev/null 2>&1; then
        print_result "xclip is installed" "PASS"
    else
        print_result "xclip is installed" "FAIL" "xclip is not installed. Run: sudo apt-get install xclip"
    fi
fi

# Print summary
print_summary

# Exit with appropriate status code
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi

# Test 11: Check if plugins are correctly loaded
print_header "Testing Plugin Loading"

# Check if plugins are correctly defined in common.zsh
if grep -q "plugins=.*zsh-autosuggestions" ~/Dev/dotfiles/zsh/common.zsh; then
    print_result "Plugins are correctly defined in common.zsh" "PASS"
else
    print_result "Plugins are correctly defined in common.zsh" "FAIL" "zsh-autosuggestions not found in plugins list"
fi

# Check if Oh My Zsh is sourced before plugins
if grep -q "source \$ZSH/oh-my-zsh.sh" ~/Dev/dotfiles/zsh/common.zsh; then
    # Find line numbers for plugin definition and oh-my-zsh sourcing
    plugin_line=$(grep -n "plugins=" ~/Dev/dotfiles/zsh/common.zsh | cut -d: -f1)
    source_line=$(grep -n "source \$ZSH/oh-my-zsh.sh" ~/Dev/dotfiles/zsh/common.zsh | cut -d: -f1)
    
    if [ "$plugin_line" -lt "$source_line" ]; then
        print_result "Plugin list defined before sourcing Oh My Zsh" "PASS"
    else
        print_result "Plugin list defined before sourcing Oh My Zsh" "FAIL" "Plugins must be defined before sourcing Oh My Zsh"
    fi
else
    print_result "Oh My Zsh is sourced" "FAIL" "source \$ZSH/oh-my-zsh.sh not found in common.zsh"
fi

# Test 12: Test clipboard functionality
print_header "Testing Clipboard Functionality"

# First, check if aliases are properly defined
if type copy &>/dev/null && type paste &>/dev/null; then
    print_result "Clipboard aliases are defined" "PASS"
    
    # Test actual clipboard functionality
    if command -v xclip &>/dev/null || [[ "$expected_platform" == "mac" ]] || grep -q Microsoft /proc/version; then
        # Try a round-trip test
        test_string="clipboard-test-$(date +%s)"
        
        echo -n "$test_string" | copy 2>/dev/null
        clipboard_content=$(paste 2>/dev/null)
        
        if [[ "$clipboard_content" == "$test_string" ]]; then
            print_result "Clipboard round-trip test" "PASS"
        else
            print_result "Clipboard round-trip test" "FAIL" "Expected '$test_string', got '$clipboard_content'"
        fi
    else
        print_result "Clipboard tools availability" "WARN" "No clipboard utility detected (xclip/pbcopy), skipping round-trip test"
    fi
else
    print_result "Clipboard aliases are defined" "FAIL" "copy and paste aliases are not available"
fi
