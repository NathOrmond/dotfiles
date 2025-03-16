# Dotfiles

Nathan Ormond dotfiles env set up. 
Should be cross-platform. Currently supprts:

- macOS 
- Linux (WSL Ubuntu) 

environments.

## Overview

This dotfiles repository provides a consistent development environment across
different operating systems. It features:

- Modular configuration with platform-specific settings
- Cross-platform clipboard support
- Unified package management approach
- Automatic installation and configuration
- Enhanced terminal experience with tmux and ZSH

## Quick Start

### First-Time Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/Dev/dotfiles

# 2. Make the install script executable
chmod +x ~/Dev/dotfiles/install.sh

# 3. Run the installation script
cd ~/Dev/dotfiles && ./install.sh
```

The installation script will:
- Detect your platform (macOS or Linux)
- Create necessary symbolic links
- Install required packages and dependencies
- Configure your shell environment
- Set up tmux with custom keybindings
- Create a secrets directory at `~/afterzsh` (not tracked by git)

### Manual Update

To manually update your configurations:

```bash
cd ~/Dev/dotfiles
git pull
chmod +x ./install.sh  # Ensure script is executable
./install.sh
```

## Directory Structure

```
~/Dev/dotfiles/
├── .config/                  # Configuration files for various tools
│   ├── nvim/                 # Neovim configuration
│   ├── alacritty/            # Alacritty terminal configuration
│   ├── lazygit/              # Lazygit configuration
│   └── starship/             # Starship prompt configuration
├── zsh/                      # ZSH configurations
│   ├── common.zsh            # Common ZSH settings
│   ├── mac.zsh               # macOS-specific settings
│   ├── linux.zsh             # Linux-specific settings
│   ├── aliases.zsh           # Common aliases
│   ├── functions.zsh         # Common functions
│   └── plugins.zsh           # ZSH plugins configuration
├── packages/                 # Package management
│   ├── packages.zsh          # Cross-platform package installer
│   ├── Brewfile              # Homebrew packages for macOS
│   └── apt-packages.txt      # APT packages for Linux
├── .zshrc                    # Main ZSH configuration (sources modular files)
├── .tmux.conf                # TMUX configuration
├── .gitconfig                # Git configuration
├── .vimrc                    # Vim configuration
├── .p10k.zsh                 # Powerlevel10k configuration
└── install.sh                # Installation script
```

## Key Features

### Platform Detection

The system automatically detects your platform and applies the appropriate
settings:

```zsh
if [[ "$(uname)" == "Darwin" ]]; then
    export PLATFORM="mac"
    source "$DOTFILES/zsh/mac.zsh"
elif [[ "$(uname)" == "Linux" ]]; then
    export PLATFORM="linux"
    source "$DOTFILES/zsh/linux.zsh"
fi
```

### Anaconda/Conda Setup

The dotfiles provide automated cross-platform Conda installation:

- **macOS**: Installs via Homebrew
- **Linux/WSL**: Downloads and installs the latest Anaconda distribution

During installation, you'll be prompted to install Conda if it's not already
present. You can also manually run the Conda setup script:

```bash
~/Dev/dotfiles/conda-setup.sh --install
```

This will:
1. Check if Conda is already installed
2. Install Conda using the appropriate method for your platform
3. Configure channels and base environments
4. Optionally create a fastai environment

#### Jupyter Notebook in WSL

To use Jupyter notebooks in WSL, several helper functions are provided:

```bash
# Start Jupyter notebook without browser on default port 8888
jup

# Start Jupyter with custom port
jup 9999

# Start Jupyter in specific directory
jup 8888 ~/projects/data-science

# Create symlink to Windows Documents folder
jup-link

# Setup a complete Jupyter environment with common packages
jup-setup
```

Additional aliases:
- `jnb`: Start Jupyter notebook (no browser in WSL)
- `jlab`: Start Jupyter lab (no browser in WSL)
- `notebooks-link`: Create symlink to Windows documents

For convenient access to Windows files, the `jup-link` command will create
a symlink to your Windows Documents folder:

```bash
# This creates a symlink from your Windows Documents to ~/notebooks
jup-link

# Then start Jupyter with access to these files
jup 8888 ~/notebooks
```

### Vim Configuration

The dotfiles include a comprehensive vim configuration with cross-platform
support:

#### Key Vim Features:
- **Modern UI**: Line numbers, syntax highlighting, cursor line
- **Enhanced Navigation**: Window navigation with Ctrl+h/j/k/l
- **Smart Search**: Case-insensitive, highlighting, incremental
- **Code Friendly**: Auto-indent, smart tab handling
- **Cross-Platform Clipboard**: Works on macOS, Linux, and WSL

#### Important Vim Key Mappings:
- `,<space>`: Clear search highlighting
- `,w`: Quick save
- `,q`: Quick quit
- `,x`: Save and quit
- `,r`: Reload vimrc
- `,y`: Copy to system clipboard
- `,p`: Paste from system clipboard

### Cross-Platform Clipboard

Use `copy` and `paste` commands consistently across platforms:

- macOS: Uses native `pbcopy` and `pbpaste`
- Linux: Uses `xclip` (installed automatically if missing)

Example usage:
```bash
# Copy directory listing to clipboard
ls -la | copy

# Paste clipboard content
paste > output.txt
```

### Package Management

The system provides unified package installation across platforms:

- macOS: Uses Homebrew via `brew install`
- Linux: Uses apt via `apt-get install`

Use the `install-pkg` function for cross-platform installation:
```bash
install-pkg git
install-pkg tmux
```

## Important Aliases and Commands

### Directory Navigation

```bash
cdev                # cd to $HOME/Dev
cdev-vivacity       # cd to $DEV_VIVACITY
cdotfiles           # cd to $DEV/dotfiles
cd-secrets          # cd to $HOME/afterzsh
notes               # cd to $NOTES
```

### Git Shortcuts

```bash
gs                 # git status
ga                 # git add
gc                 # git commit
gp                 # git push
gl                 # git pull
```

### Utilities

```bash
c                  # clear terminal
hgrep              # history | grep
please             # sudo (alias for politeness)
notes-push         # quick command to commit and push notes
```

### Tmux Commands and Keybindings

The tmux configuration includes several customisations:

- **Prefix**: `Ctrl+a` (instead of default `Ctrl+b`)
- **Pane Navigation**:
    - `Prefix + h/j/k/l`: Navigate panes (left/down/up/right)
    - `Prefix + |`: Split pane vertically
    - `Prefix + -`: Split pane horizontally
- **Window Management**:
    - `Prefix + c`: Create new window
    - `Prefix + n/p`: Next/previous window
    - `Prefix + ,`: Rename window
- **Special Features**:
    - Focus tracking changes pane borders (green when focused, red
    when unfocused)
    - `tmux-all [command]`: Run a command in all tmux panes

## Custom Functions

### tmux-all

Run commands in all tmux panes simultaneously:

```bash
tmux-all ls -la     # Run ls -la in all panes
tmux-all cd ~/Dev   # Change directory in all panes
```

### install-pkg

Cross-platform package installation:

```bash
install-pkg python3   # Installs python3 using the appropriate package manager
```

## Assumptions and Requirements

### Prerequisites

- Git (required for initial installation)
- ZSH shell
- Administrative privileges for package installation

### Platform-Specific

#### macOS
- Homebrew will be installed if not present
- XCode Command Line Tools are required (will be prompted to install if missing)

#### Linux (WSL)
- Ubuntu-based distribution assumed
- `apt` package manager
- `sudo` access required for package installation

### Directory Structure

The system expects:
- `$HOME/Dev/dotfiles`: Location of this repository
- `$HOME/afterzsh`: Location for custom, machine-specific aliases and secrets
- `$HOME/Documents/obsidian-vault`: Default location for notes (customize as
  needed)

## Customisation

### Secret Management

The dotfiles use a dedicated directory structure for secrets and
machine-specific configurations:

```
$HOME/afterzsh/          # Directory for secrets and local configurations
  ├── aliases.sh         # Machine-specific aliases
  ├── secrets.sh         # API keys, tokens, and other secrets
  ├── work.sh            # Work-specific settings
  ├── jupyter-aliases.sh # Jupyter notebook helpers
  └── ...                # Other local configuration files
```

**Key benefits of this approach:**
    - Keeps sensitive information out of the git repository
    - Allows for machine-specific customisations
    - Automatically sourced by `.zshrc` at startup

The main `.zshrc` sources these files at the end of its execution:

```zsh
# Source secrets and custom configurations
export LOCAL_SECRETS="$HOME/afterzsh"
if [[ -f "$LOCAL_SECRETS/aliases.sh" ]]; then
    source "$LOCAL_SECRETS/aliases.sh"
    print_status "Custom Aliases" "enabled"
fi
```

**Important Notes:**
- The `install.sh` script automatically creates the
`~/afterzsh` directory if it doesn't exist
- It also creates a template `secrets.sh` file for you
to add your sensitive information
- The full path is displayed during installation so
you know exactly where to put your secrets
- NEVER commit the contents of the `~/afterzsh`
directory to git

**Best practices for using afterzsh:**
- Store API keys, tokens, and passwords in
`secrets.sh`
- Add machine-specific PATH adjustments in
`aliases.sh`
- Keep work-specific configurations separate
in their own files
- Use `secrets.sh` for information that
  shouldn't be in a public repository

### Local Overrides

Add machine-specific configurations without modifying the repository:

1. Create or edit `$HOME/afterzsh/aliases.sh`
2. Add your custom aliases, functions, or environment variables
3. These will be automatically sourced when you start a new shell

### Adding New Tools

To add support for new tools:

1. Add configuration files to the appropriate directory within `.config/`
2. Update the `install.sh` script to create the necessary symlinks
3. If needed, add package installation to platform-specific scripts

## Troubleshooting

### Missing Tools

If a tool is reported as "not found" during startup:

1. Check if the package is installed using your package manager
2. Verify that the package is in your PATH
3. For manual installation: `install-pkg [package-name]`

### Installation Issues

If you encounter issues during installation:

1. Make sure the install script is executable:
```bash
    chmod +x ~/Dev/dotfiles/install.sh
```

2. If you get "Permission denied" errors:
```bash
# Fix permissions for all scripts
find ~/Dev/dotfiles -name "*.sh" -exec chmod +x {} \;
```

3. If you're on WSL and can't execute the script, check
file permissions:
```bash
# Convert Windows line endings to Unix
dos2unix ~/Dev/dotfiles/install.sh
```

### Fixing Broken Symlinks

If your configuration isn't working as expected:

```bash
# Re-run the install script
cd ~/Dev/dotfiles
./install.sh
```

### Cross-Platform Vim Clipboard

The `.vimrc` includes special configuration to ensure clipboard functionality
works correctly across platforms:

- **macOS**: Uses the system clipboard automatically
- **Linux**: Uses `xclip` for system clipboard integration
- **WSL**: Uses Windows clipboard commands (`clip.exe` and PowerShell)

#### Key mappings for clipboard operations:

```
<leader>y - Yank (copy) to system clipboard
<leader>p - Paste from system clipboard
```

#### Troubleshooting Vim Clipboard Issues:

1. In Vim, run `:CheckClipboard` to verify clipboard support
2. On Ubuntu/Linux, ensure you have a clipboard-enabled version of Vim:
```bash
sudo apt-get update
sudo apt-get install vim-gtk3
```
3. Make sure `xclip` is installed (installed automatically by the setup script)
4. Check the vim version with `vim --version | grep clipboard`
   - Look for `+clipboard` and `+xterm_clipboard`

### WSL-Specific Issues

If encountering permission issues in WSL:

1. Check that files are owned by your user: `ls -la ~/Dev/dotfiles`
2. Fix ownership if needed: `sudo chown -R $USER:$USER ~/Dev/dotfiles`
3. Fix permissions: `chmod +x ~/Dev/dotfiles/install.sh`

## Contributing

To contribute to these dotfiles:

1. Fork the repository
2. Create a feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for
details.
