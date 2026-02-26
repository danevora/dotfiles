# CLAUDE.md

## Symlinking Convention

**Always symlink folders, not individual files.**

Structure: `dotfiles/<tool>/` → `~/.<tool>/` or `~/.config/<tool>/`

If the target is a single file (like `~/.bashrc`), still keep it in a folder in this repo (`bash/.bashrc`) but symlink the file directly since that's what the system expects.

Examples:
- `dotfiles/claude/` → `~/.claude/` (folder)
- `dotfiles/bash/.bashrc` → `~/.bashrc` (file, because that's the expected location)
- `dotfiles/nvim/` → `~/.config/nvim/` (folder)

## Adding New Configs

1. Create folder: `dotfiles/<tool>/`
2. Add config files inside
3. Add symlink logic to `install.sh`
4. Update `.gitignore` if needed (for sensitive/machine-specific files)
5. Check if `README.md` structure section needs updating
6. Commit and push

## Cross-Platform

Supports macOS and WSL. Use conditionals in `install.sh` when paths differ:
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS path
else
    # Linux/WSL path
fi
```
