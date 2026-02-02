# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ─────────────────────────────────────────────────────────────
# Completion settings
# ─────────────────────────────────────────────────────────────
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'

# ─────────────────────────────────────────────────────────────
# History
# ─────────────────────────────────────────────────────────────
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# ─────────────────────────────────────────────────────────────
# Git prompt helpers
# ─────────────────────────────────────────────────────────────
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

parse_git_status() {
    local status=""
    local git_status=$(git status --porcelain 2>/dev/null)
    if [ -n "$git_status" ]; then
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
RESET='\[\033[0m\]'
BOLD='\[\033[1m\]'
RED='\[\033[0;31m\]'
GREEN='\[\033[0;32m\]'
YELLOW='\[\033[0;33m\]'
BLUE='\[\033[0;34m\]'
PURPLE='\[\033[0;35m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[0;37m\]'
BOLD_GREEN='\[\033[1;32m\]'
BOLD_BLUE='\[\033[1;34m\]'
BOLD_YELLOW='\[\033[1;33m\]'
BOLD_CYAN='\[\033[1;36m\]'
BOLD_PURPLE='\[\033[1;35m\]'
BOLD_RED='\[\033[1;31m\]'

# ─────────────────────────────────────────────────────────────
# Prompt
# ─────────────────────────────────────────────────────────────
set_prompt() {
    local EXIT_CODE=$?
    local PROMPT_SYMBOL="❯"

    if [ $EXIT_CODE -eq 0 ]; then
        local SYMBOL_COLOR="${BOLD_GREEN}"
    else
        local SYMBOL_COLOR="${BOLD_RED}"
    fi

    local BRANCH=$(parse_git_branch)
    local GIT_INFO=""
    if [ -n "$BRANCH" ]; then
        local STATUS=$(parse_git_status)
        GIT_INFO="${BOLD_PURPLE}${BRANCH}${BOLD_YELLOW}${STATUS}${RESET} "
    fi

    local TITLE="\[\e]0;\u@\h: \w\a\]"

    PS1="${TITLE}\n${BOLD_CYAN}\u${RESET}@${BOLD_GREEN}\h${RESET} ${BOLD_BLUE}\w${RESET} ${GIT_INFO}\n${SYMBOL_COLOR}${PROMPT_SYMBOL}${RESET} "
}

PROMPT_COMMAND=set_prompt

# ─────────────────────────────────────────────────────────────
# Aliases
# ─────────────────────────────────────────────────────────────
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ─────────────────────────────────────────────────────────────
# Completion
# ─────────────────────────────────────────────────────────────
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
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
