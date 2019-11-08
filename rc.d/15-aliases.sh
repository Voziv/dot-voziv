#!/bin/sh
lsColorTag="--color=auto"

if [[ "$OSTYPE" == "darwin"* ]]; then
    lsColorTag="-G"
fi

# Copy to clipboard. EG: cat ~/.zshrc | pbcopy
alias pbcopy="xclip -sel clip"

### convenience
alias    ls="\ls -l -phF $lsColorTag"
alias    ll="\ls -halp -F $lsColorTag"
alias     l="\ls -p $lsColorTag"
alias    la="\ls -pa $lsColorTag"
alias    l.="\ls -halpd $lsColorTag .*"
alias     j='jobs -l'
alias     h='history'
alias    nv="nvim" # let's try out this whole neovim thing ...
alias    vi="nvim"
alias   vim="nvim"
#alias  tmux="tmux2.3 -2"
alias  tmux="tmux -u"

### convenience (more specific)
alias   mem='ps ax -o %mem=--MEM--,user=---USER---,pid=---PID--,cmd | grep -v root | sort -Vr'

### convenience pipes (global)
alias -g      G='| grep --color'
alias -g   grev='| grep --color -v'
alias -g      L='| less -R'
alias -g      H='| head'
alias -g  quiet='2> /dev/null'
alias -g silent='&> /dev/null'

# Docker stuff
alias dc='docker-compose'

### info aliases
alias ports='sudo netstat -uplant'        # list all TCP/UDP ports on the server
alias    df='df -H'                       # report file system disk space usage
alias    du='du -ch --summarize'          # print estimated disk usage
alias uptime='uptime --pretty'            # show uptime output in 'pretty' time format


### safety aliases
alias    mv='mv -i'                       # prompts for safety
alias    rm='rm -I'                       # "
alias    cp='cp -i'                       # "
alias    ln='ln -i'                       # "
