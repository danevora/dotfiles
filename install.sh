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

echo ""
info "Done!"
