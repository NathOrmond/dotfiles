# Helper Scripts

This directory contains utility scripts for managing dotfiles.

## Available Scripts

- `backup-dotfiles.sh`: Creates a timestamped backup of your current dotfiles
- `restore-commit.sh`: Restores dotfiles to the specific commit a11de4193c30fbf1df5d78209b36cc5d14431eaa
- `conda-setup.sh`: Cross-platform conda installation and configuration
- `jupyter-aliases.sh`: Helper functions and aliases for Jupyter notebooks

## Usage Examples

### Backup your dotfiles
```bash
./backup-dotfiles.sh
```

### Restore to a specific commit
```bash
./restore-commit.sh
```

### Install or update Conda
```bash
./conda-setup.sh --install
```

### Check Conda status
```bash
./conda-setup.sh
```
