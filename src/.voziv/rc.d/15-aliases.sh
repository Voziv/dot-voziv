#!/bin/sh


# Mac has a really cool tool called pbcopy, xclip lets us do this on linux
# Copy to clipboard. EG: cat ~/.zshrc | pbcopy
if we_are_linux; then
  if type -p "xclip" &> /dev/null; then
    alias pbcopy="xclip -sel clip"
  fi
fi

# Default to neovim if we have it installed
if type -p "nvim" &> /dev/null; then
  alias  nv="nvim"
  alias  vi="nvim"
  alias vim="nvim"
fi

alias  tmux="tmux -u"

### convenience pipes (global)
alias -g      G='| grep --color'
alias -g   grev='| grep --color -v'
alias -g      L='| less -R'
alias -g      H='| head'
alias -g  quiet='2> /dev/null'
alias -g silent='&> /dev/null'

# Docker stuff
alias dc='docker compose'
alias k='kubectl'

### info aliases
alias ports='sudo netstat -uplant'        # list all TCP/UDP ports on the server
alias df='df -H'                       # report file system disk space usage


lsColorTag="--color=auto"
rmAlias="rm -I"

if we_are_mac; then
    lsColorTag="-G"
    rmAlias="rm"
fi

### convenience
alias    ls="\ls -l -phF $lsColorTag"
alias    ll="\ls -halp -F $lsColorTag"
alias     l="\ls -p $lsColorTag"
alias    la="\ls -pa $lsColorTag"
alias    l.="\ls -halpd $lsColorTag .*"

### safety aliases
alias    mv='mv -i'                       # prompts for safety
alias    rm=$rmAlias                      # "
alias    cp='cp -i'                       # "
alias    ln='ln -i'                       # "

