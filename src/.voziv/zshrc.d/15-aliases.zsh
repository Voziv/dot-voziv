#!/bin/zsh

### convenience
alias zreload="source ${HOME}/.zshrc"

### convenience pipes (global aliases — zsh only)
alias -g      G='| grep --color'
alias -g   grev='| grep --color -v'
alias -g      L='| less -R'
alias -g      H='| head'
alias -g  quiet='2> /dev/null'
alias -g silent='&> /dev/null'
