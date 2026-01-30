#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; }

# Backup and link
link() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        rm "$dest"
        info "Removed existing symlink: $dest"
    elif [ -e "$dest" ]; then
        mv "$dest" "${dest}.backup.$(date +%s)"
        warn "Backed up existing: $dest"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    info "Linked: $dest -> $src"
}

echo "Installing dotfiles from $DOTFILES"
echo ""

# Claude
[ -d "$DOTFILES/claude" ] && link "$DOTFILES/claude" "$HOME/.claude"

# Zsh
[ -f "$DOTFILES/zsh/.zshrc" ] && link "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES/zsh/.zshenv" ] && link "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"

# Bash
[ -f "$DOTFILES/bash/.bashrc" ] && link "$DOTFILES/bash/.bashrc" "$HOME/.bashrc"
[ -f "$DOTFILES/bash/.bash_profile" ] && link "$DOTFILES/bash/.bash_profile" "$HOME/.bash_profile"

# Git
[ -f "$DOTFILES/git/.gitconfig" ] && link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
[ -f "$DOTFILES/git/.gitignore_global" ] && link "$DOTFILES/git/.gitignore_global" "$HOME/.gitignore_global"

# Vim
[ -f "$DOTFILES/vim/.vimrc" ] && link "$DOTFILES/vim/.vimrc" "$HOME/.vimrc"
[ -d "$DOTFILES/vim/.vim" ] && link "$DOTFILES/vim/.vim" "$HOME/.vim"

# Neovim
[ -d "$DOTFILES/nvim" ] && link "$DOTFILES/nvim" "$HOME/.config/nvim"

# Tmux
[ -f "$DOTFILES/tmux/.tmux.conf" ] && link "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

# SSH config (not keys)
[ -f "$DOTFILES/ssh/config" ] && link "$DOTFILES/ssh/config" "$HOME/.ssh/config"

# VS Code
if [ -d "$DOTFILES/vscode" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        VSCODE_DIR="$HOME/Library/Application Support/Code/User"
    else
        VSCODE_DIR="$HOME/.config/Code/User"
    fi
    [ -f "$DOTFILES/vscode/settings.json" ] && link "$DOTFILES/vscode/settings.json" "$VSCODE_DIR/settings.json"
    [ -f "$DOTFILES/vscode/keybindings.json" ] && link "$DOTFILES/vscode/keybindings.json" "$VSCODE_DIR/keybindings.json"
fi

echo ""
info "Done!"
