#!/bin/zsh
scriptdir=${0:a:h}
completions_dir="$scriptdir/completions.d"
fpath=($completions_dir $fpath)

if type -p "kubectl" &> /dev/null; then
  source <(kubectl completion zsh)
fi

if type -p "doctl" &> /dev/null; then
  source <(doctl completion zsh)
fi

if type -p "helm" &> /dev/null; then
  source <(helm completion zsh)
fi

if type -p "minikube" &> /dev/null; then
  source <(minikube completion zsh)
fi

if type -p "k3d" &> /dev/null; then
  source <(k3d completion zsh)
fi

if type -p "gcloud" &> /dev/null; then
  if we_are_mac; then
    if [ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]; then
      source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
    fi
  else
    if [ -f "/usr/share/google-cloud-sdk/completion.zsh.inc" ]; then
      source /usr/share/google-cloud-sdk/completion.zsh.inc
    fi
  fi
fi

# Reload the zsh-completions. -u trusts the completion dirs without the security
# audit: Workbrew owns /opt/homebrew/share as group-writable, which otherwise
# trips compinit's insecure-directory prompt whenever it rebuilds the dump.
autoload -Uz compinit && compinit -u

# Support bash completions
bashcompinit