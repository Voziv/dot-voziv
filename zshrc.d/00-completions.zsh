#!/bin/zsh
scriptdir=${0:a:h}
completions_dir="$scriptdir/completions.d"
fpath=($completions_dir $fpath)
