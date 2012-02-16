# History
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt hist_ignore_all_dups

# Vi keybindings
bindkey -v
bindkey -M viins '^r' history-incremental-search-backward
bindkey -M vicmd '^r' history-incremental-search-backward

# Completion
zstyle :compinstall filename '/home/mawww/.zshrc'

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

setopt extendedglob
unsetopt no_match

# Prompt
autoload -U promptinit
promptinit
setopt prompt_subst

export PS1="%F{green}%n@%m%F{cyan}(%l) %F{blue}%~ %F{grey}
>>> "

# Paths
export PATH="${HOME}/local/bin:${PATH}"
export MANPATH="${HOME}/local/share/man:${MANPATH}"
export LD_LIBRARY_PATH="${HOME}/local/lib;${LD_LIBRARY_PATH}"
export PYTHONPATH="${HOME}/local/lib/python:${PYTHONPATH}"

# Kakoune!
export EDITOR=kak

# Aliases
alias ls="ls --color=auto"

alias -s -- pdf=zathura
alias -s -- git='git clone'

source ~/.zshrc_local
