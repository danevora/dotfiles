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
└── install.sh       # Symlink installer
```

## Adding configs

1. Move config to appropriate folder in this repo
2. Add symlink logic to `install.sh`
3. Commit and push

## Manual linking

```bash
ln -s ~/Code/dotfiles/claude ~/.claude
```
