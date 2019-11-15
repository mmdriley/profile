# ~/.bashrc is executed when an interactive, non-login shell starts

# Exit if we've somehow been invoked for a non-interactive shell.
[ -n "$PS1" ] || return

export EDITOR=nano
alias ..='cd ..'

# append to (rather than replace) history file on exit
shopt -s histappend

# update LINES and COLUMNS after each external command
# enabled by default since Bash 5.0, see https://git.io/Je4B1
shopt -s checkwinsize

# don't add duplicate commands or commands starting with space to history
export HISTCONTROL='ignoredups:ignorespace'  # aka ignoreboth

case "$(uname)" in
  Darwin)
    # Don't warn about using Bash on macOS 10.15+
    export BASH_SILENCE_DEPRECATION_WARNING=1

    # Enable color for various commands
    export CLICOLOR=1

    # Use Debian-y colors for `ls`
    export LSCOLORS=Exfxcxdxbxegedabagacad

    [[ -d "${HOME}/homebrew/bin" ]] && {
      PATH=${HOME}/homebrew/bin:${PATH}
      BREW=$(brew --prefix)

      # brew install bash-completion
      [[ -r "${BREW}/etc/profile.d/bash_completion.sh" ]] &&
        . "${BREW}/etc/profile.d/bash_completion.sh"

      # brew install git
      [[ -r "${BREW}/etc/bash_completion.d/git-prompt.sh" ]] &&
        . "${BREW}/etc/bash_completion.d/git-prompt.sh"

      unset BREW
    }
    ;;

  Linux)
    # baseline reference:
    # https://bazaar.launchpad.net/~doko/+junk/pkg-bash-debian/view/head:/skel.bashrc

    # Make `less` more friendly for non-text inputs
    [[ -x /usr/bin/lesspipe ]] && eval "$(lesspipe)"

    # Enable colors
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    # Configure colors for `ls`
    [[ -x /usr/bin/dircolors ]] && eval "$(dircolors --bourne-shell)"

    # Activate Bash completion
    # Why this path?
    #   https://packages.debian.org/stable/all/bash-completion/filelist
    [[ -f /usr/share/bash-completion/bash_completion ]] &&
      . /usr/share/bash-completion/bash_completion
    ;;
esac

__ps1_pre() {
  local pre

  # Set terminal title.
  # The macOS Terminal has its own (configurable) ideas about what information
  # is displayed in the title bar -- see e.g. the `update_terminal_cwd`
  # function in `/etc/bashrc_Apple_Terminal` -- so we don't add a title there.
  # We still explicitly set an *empty* title to clean up after SSH sessions to
  # hosts that might set it.
  pre+='\[\e]0;'  # start setting title -- see `tput tsl` (to status line)
  if [[ "${TERM_PROGRAM}" != "Apple_Terminal" ]]; then
    pre+='\u@\h:\w'  # {user}@{host}:{working directory}
  fi
  pre+='\a\]'  # end title -- see `tput fsl` (from status line)

  pre+='\[\e[1;32m\]'  # bold+green
  pre+='\u@\h'  # {user}@{host}
  pre+='\[\e[m\]'  # reset
  pre+=':'
  pre+='\[\e[1;34m\]'  # bold+blue
  pre+='\w'  # current working directory
  pre+='\[\e[m\]'  # reset

  echo -n "${pre}"
}

__ps1_post() {
  local post
  post+='\n'  # newline
  post+='\$'  # '#' or '$' depending on euid
  post+=' '

  echo -n "${post}"
}

PS1="$(__ps1_pre)$(__ps1_post)"

__git_ps1_custom() {
  local format
  format+=' ['
  format+='%s'  # git status message
  format+=']'

  __git_ps1 "$(__ps1_pre)" "$(__ps1_post)" "${format}"
}

if [[ "$(type -t __git_ps1)" == "function" ]]; then
  export GIT_PS1_SHOWUPSTREAM=auto  # mark ahead/behind/equal upstream
  export GIT_PS1_SHOWDIRTYSTATE=1  # mark unstaged and staged changes
  export GIT_PS1_SHOWUNTRACKEDFILES=1  # mark untracked files
  export GIT_PS1_SHOWCOLORHINTS=1  # add color to dirty/untracked markers

  # Check for bash-preexec's include guard to see if it's installed. We can't
  # check for `precmd_functions` because that won't be set until bash-preexec
  # initializes, which happens the first time $PROMPT_COMMAND is evaluated.
  # https://git.io/JeRzW
  if [[ -n "${__bp_imported+set}" ]]; then
    # bash-preexec is installed and controls $PROMPT_COMMAND. Add our command
    # to the array of pre-command functions.

    # Assign to a specific, unlikely-to-collide index so we don't add the
    # command again each time this file is sourced.
    precmd_functions[$((36#gitps1))]='__git_ps1_custom'
  else
    # Easy case.
    export PROMPT_COMMAND='__git_ps1_custom'
  fi
fi
