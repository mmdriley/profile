# .bashrc is executed for interactive, non-login shells

PATH=$PATH:${HOME}/bin

export EDITOR=nano

alias ..="cd .."

complete -C "/usr/local/bin/aws_completer" aws

source "${HOME}/bin/git-prompt.sh"

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWUPSTREAM=git

BOLD=$(tput bold)
RESET=$(tput sgr0)
export PROMPT_COMMAND='__git_ps1 "'"${BOLD}\w${RESET}"'" "\n$ " " [%s]"'

export CLICOLOR=xterm-color
export LSCOLORS=Exfxcxdxbxegedabagacad

export HISTCONTROL=ignorespace
shopt -s histappend checkwinsize
