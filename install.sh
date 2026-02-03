#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    OS="linux"
fi
info "Detected OS: $OS"

# Backup and link
link() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        mv "$dest" "${dest}.backup.$(date +%s)"
        warn "Backed up: $dest"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    info "Linked: $dest -> $src"
}

# Claude (individual files, not whole folder)
mkdir -p "$HOME/.claude"
[ -f "$DOTFILES/claude/CLAUDE.md" ] && link "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
[ -f "$DOTFILES/claude/settings.json" ] && link "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
[ -f "$DOTFILES/claude/statusline-command.sh" ] && link "$DOTFILES/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

# Shell
case $OS in
    macos)
        [ -f "$DOTFILES/zsh/.zshrc" ] && link "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
        ;;
    linux)
        [ -f "$DOTFILES/bash/.bashrc" ] && link "$DOTFILES/bash/.bashrc" "$HOME/.bashrc"
        [ -f "$DOTFILES/bash/.inputrc" ] && link "$DOTFILES/bash/.inputrc" "$HOME/.inputrc"
        ;;
esac

info "Done!"
