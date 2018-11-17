#!/bin/zsh

# Copy to clipboard. EG: cat ~/.zshrc | pbcopy
alias pbcopy="xclip -sel clip"

# Docker stuff
alias dc='docker-compose'


### convenience
alias zreload="source ${HOME}/.zshrc"
alias    ls='\ls -l -phF'
alias    ll='\ls -halp -F'
alias     l='\ls -p'
alias    la='\ls -pa'
alias    l.='\ls -halpd .*'
alias    kk='\k -ha --no-vcs'
alias    kgit='\k -ha'
alias     j='jobs -l'
alias     h='history'
alias     t='\tree -Fn --dirsfirst -I node_modules'
alias    td='\tree -Fn --dirsfirst -I node_modules -d' # same, but dirs only
alias  scns='scn -ls'
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

