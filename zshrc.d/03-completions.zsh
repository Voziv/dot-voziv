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

# Reload the zsh-completions
autoload -U compinit && compinit
