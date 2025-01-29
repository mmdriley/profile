# https://zsh.sourceforge.io/Doc/Release/Files.html#Startup_002fShutdown-Files

export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad

export EDITOR=nano

autoload -Uz compinit && compinit

# ~/.zshenv should be:
# ```
# eval "$(/opt/homebrew/bin/brew shellenv)"
# ```

[[ -n "${HOMEBREW_PREFIX}" ]] && {
  # homebrew is installed

  # brew install git
  # despite being in `bash_completion`, `git-prompt` works with zsh
  [[ -r "${HOMEBREW_PREFIX}/etc/bash_completion.d/git-prompt.sh" ]] &&
      . "${HOMEBREW_PREFIX}/etc/bash_completion.d/git-prompt.sh"
}

# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html#Visual-effects
__ps1_pre() {
  echo -n "%B%F{green}"  # bold+green
  echo -n '%n@%m'        # {user}@{host}
  echo -n "%f%b"         # reset
  echo -n ':'
  echo -n "%B%F{blue}"   # bold+blue
  echo -n '%~'           # current working directory
  echo -n '%f%b'         # reset
}

__ps1_post() {
  echo -n '\n'  # newline
  echo -n '%#'  # '#' or '$' depending on euid
  echo -n ' '
}

PS1="$(__ps1_pre)$(__ps1_post)"

__custom_git_ps1() {
  __git_ps1 \
    "$(__ps1_pre)" \
    ' [%s]' \
    "$(__ps1_post)"
}

functions __git_ps1 >/dev/null && {
  # __git_ps1 is a function

  setopt PROMPT_SUBST  # enable command substitution in PS1

  # ref: https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
  export GIT_PS1_SHOWCOLORHINTS=1
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  export GIT_PS1_SHOWUPSTREAM=auto

  PS1="$(__ps1_pre)\$(__git_ps1 ' [%s]')$(__ps1_post)"
}
