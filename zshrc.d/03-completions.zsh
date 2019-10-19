#!/bin/zsh
scriptdir=${0:a:h}
completions_dir="$scriptdir/completions.d"
fpath=($completions_dir $fpath)

# Reload the zsh-completions
autoload -U compinit && compinit
