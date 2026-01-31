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
├── claude/          # ~/.claude
├── git/             # ~/.gitconfig
└── install.sh
```

## Adding configs

1. Create folder: `dotfiles/<tool>/`
2. Add config files inside
3. Add symlink logic to `install.sh`
4. Commit and push
