# Set SSH_AUTH_SOCK to use 1Password as SSH Agent when not ssh'd in remotely.
if [ -z $SSH_TTY ] ; then
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     SSH_AUTH_SOCK=~/.1password/agent.sock;;
        Darwin*)    SSH_AUTH_SOCK=~/.1password/agent.sock;;
        CYGWIN*)    SSH_AUTH_SOCK=~/.1password/agent.sock;;
        MINGW*)     SSH_AUTH_SOCK=~/.1password/agent.sock;;
        MSYS_NT*)   SSH_AUTH_SOCK=~/.1password/agent.sock;;
        *)          machine="UNKNOWN:${unameOut}"
    esac
fi