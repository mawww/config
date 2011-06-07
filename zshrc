# History
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt hist_ignore_all_dups

bindkey -v

# Completion
zstyle :compinstall filename '/home/mawww/.zshrc'

autoload -Uz compinit
compinit

setopt extendedglob

# Prompt
autoload -U promptinit
promptinit
setopt prompt_subst

export PS1="%F{green}%n@%m%F{cyan}(%l) %F{blue}%~ %F{grey}>>> "

# Paths
export PATH="${HOME}/local/bin:${HOME}/local/i686-pc-mingw32/bin:${PATH}"
export MANPATH="${HOME}/local/share/man:${MANPATH}"
export LD_LIBRARY_PATH="${HOME}/local/lib;${LD_LIBRARY_PATH}"
export PYTHONPATH="${HOME}/local/lib/python"

# Distcc
export DISTCC_POTENTIAL_HOSTS="localhost compilux"

# Aliases
alias herrie="screen -S herrie -dR herrie"
alias wiki="vim ~/misc/wiki/index.wiki"
alias ls="ls --color=auto"

# Syntax highlighting
source ~/prj/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
