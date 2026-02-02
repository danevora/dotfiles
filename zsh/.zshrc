# ~/.zshrc

# ─────────────────────────────────────────────────────────────
# Completion settings
# ─────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Show completion menu on successive tab press
zstyle ':completion:*' menu select

# ─────────────────────────────────────────────────────────────
# History
# ─────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# ─────────────────────────────────────────────────────────────
# Git prompt helpers
# ─────────────────────────────────────────────────────────────
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

parse_git_status() {
    local status=""
    local git_status=$(git status --porcelain 2>/dev/null)
    if [[ -n "$git_status" ]]; then
        status="*"
    fi
    if git log --oneline @{upstream}.. 2>/dev/null | grep -q .; then
        status="${status}↑"
    fi
    echo "$status"
}

# ─────────────────────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────────────────────
autoload -U colors && colors

# ─────────────────────────────────────────────────────────────
# Prompt
# ─────────────────────────────────────────────────────────────
setopt PROMPT_SUBST

precmd() {
    local BRANCH=$(parse_git_branch)
    local GIT_INFO=""
    if [[ -n "$BRANCH" ]]; then
        local STATUS=$(parse_git_status)
        GIT_INFO="%F{magenta}${BRANCH}%F{yellow}${STATUS}%f "
    fi

    # Store for use in PROMPT
    _GIT_INFO="$GIT_INFO"
}

PROMPT=$'\n%B%F{cyan}%n%f%b@%B%F{green}%m%f%b %B%F{blue}%~%f%b ${_GIT_INFO}\n%(?.%B%F{green}.%B%F{red})❯%f%b '

# ─────────────────────────────────────────────────────────────
# Aliases
# ─────────────────────────────────────────────────────────────
# macOS uses different ls flags
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

# ─────────────────────────────────────────────────────────────
# Tools (nvm, pyenv, etc)
# ─────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv &>/dev/null && eval "$(pyenv init -)"

export PATH="$HOME/.local/bin:$PATH"

# Homebrew (macOS)
if [[ "$OSTYPE" == "darwin"* ]] && [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
