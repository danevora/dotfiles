#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; }
prompt() { echo -e "${CYAN}[?]${NC} $1"; }

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

# ─────────────────────────────────────────────────────────────
# Interactive setup
# ─────────────────────────────────────────────────────────────
echo "╔════════════════════════════════════════╗"
echo "║         Dotfiles Installer             ║"
echo "╚════════════════════════════════════════╝"
echo ""

# OS selection
prompt "Select your OS:"
echo "  1) macOS"
echo "  2) Ubuntu/WSL"
echo "  3) Windows (Git Bash)"
read -p "Choice [1-3]: " os_choice

case $os_choice in
    1) OS="macos" ;;
    2) OS="linux" ;;
    3) OS="windows" ;;
    *) error "Invalid choice"; exit 1 ;;
esac
info "OS: $OS"

# Username
default_user=$(whoami)
prompt "Username [$default_user]: "
read -p "" username
username=${username:-$default_user}
info "Username: $username"

# Set home path based on OS
case $OS in
    macos)   USER_HOME="/Users/$username" ;;
    linux)   USER_HOME="/home/$username" ;;
    windows) USER_HOME="/c/Users/$username" ;;
esac
info "Home path: $USER_HOME"

echo ""

# ─────────────────────────────────────────────────────────────
# Git config
# ─────────────────────────────────────────────────────────────
prompt "Git full name: "
read -p "" git_name
prompt "Git email: "
read -p "" git_email

prompt "Default editor:"
echo "  1) vim"
echo "  2) nvim"
echo "  3) code (VS Code)"
echo "  4) nano"
read -p "Choice [1-4]: " editor_choice
case $editor_choice in
    1) GIT_EDITOR="vim" ;;
    2) GIT_EDITOR="nvim" ;;
    3) GIT_EDITOR="code --wait" ;;
    4) GIT_EDITOR="nano" ;;
    *) GIT_EDITOR="vim" ;;
esac
info "Editor: $GIT_EDITOR"

prompt "Default branch [main]: "
read -p "" default_branch
default_branch=${default_branch:-main}
info "Default branch: $default_branch"

echo ""
echo "Installing dotfiles from $DOTFILES"
echo ""

# ─────────────────────────────────────────────────────────────
# Dependencies
# ─────────────────────────────────────────────────────────────
install_if_missing() {
    local cmd="$1"
    local pkg="${2:-$1}"  # package name, defaults to command name

    if command -v "$cmd" &>/dev/null; then
        info "$cmd already installed"
        return
    fi

    case $OS in
        macos)  brew install "$pkg" ;;
        linux)  sudo apt install -y "$pkg" ;;
    esac
    info "Installed $pkg"
}

install_if_missing jq

echo ""

# ─────────────────────────────────────────────────────────────
# Claude
# ─────────────────────────────────────────────────────────────
if [ -d "$DOTFILES/claude" ]; then
    link "$DOTFILES/claude" "$HOME/.claude"

    # Update settings.json with correct paths
    settings="$DOTFILES/claude/settings.json"
    if [ -f "$settings" ]; then
        # Replace any home path pattern with the correct one
        sed -i.bak "s|/Users/[^/]*/|$USER_HOME/|g; s|/home/[^/]*/|$USER_HOME/|g; s|/c/Users/[^/]*/|$USER_HOME/|g" "$settings"
        rm -f "$settings.bak"
        info "Updated claude/settings.json paths"
    fi
fi

# ─────────────────────────────────────────────────────────────
# Git
# ─────────────────────────────────────────────────────────────
if [ -d "$DOTFILES/git" ]; then
    # Generate .gitconfig from user input
    cat > "$DOTFILES/git/.gitconfig" << EOF
[user]
	name = $git_name
	email = $git_email
[core]
	editor = $GIT_EDITOR
[init]
	defaultBranch = $default_branch
[pull]
	rebase = true
[push]
	autoSetupRemote = true
EOF
    info "Generated git/.gitconfig"
    link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
fi

# ─────────────────────────────────────────────────────────────
# Shell config (zsh for macOS, bash for Linux)
# ─────────────────────────────────────────────────────────────
case $OS in
    macos)
        if [ -f "$DOTFILES/zsh/.zshrc" ]; then
            link "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
        fi
        ;;
    linux)
        if [ -f "$DOTFILES/bash/.bashrc" ]; then
            link "$DOTFILES/bash/.bashrc" "$HOME/.bashrc"
        fi
        ;;
esac

echo ""
info "Done!"
