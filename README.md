# dotfiles

## Install

```bash
git clone https://github.com/danevora/dotfiles.git ~/Code/dotfiles
cd ~/Code/dotfiles
./install.sh
```

## Structure

```
dotfiles/
├── claude/          # Claude Code config (~/.claude)
├── zsh/             # .zshrc, .zshenv
├── bash/            # .bashrc, .bash_profile
├── git/             # .gitconfig, .gitignore_global
├── vim/             # .vimrc, .vim/
├── nvim/            # Neovim (~/.config/nvim)
├── tmux/            # .tmux.conf
├── ssh/             # SSH config (not keys!)
├── vscode/          # VS Code settings
└── install.sh       # Symlink installer
```

## Adding configs

1. Move config to appropriate folder in this repo
2. Add symlink logic to `install.sh`
3. Commit and push

## Manual linking

If you only want specific configs:

```bash
ln -s ~/Code/dotfiles/claude ~/.claude
ln -s ~/Code/dotfiles/zsh/.zshrc ~/.zshrc
```
