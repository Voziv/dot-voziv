#!/bin/bash

# Script Directory
script_dir=$(dirname ${BASH_SOURCE[0]})
script_dir=$(realpath ${script_dir})
if [[ ! -d "$script_dir" ]]; then script_dir="$PWD"; fi

runDate=$(date -d "today" +"%Y%m%d%H%M%S")

function install() {
    cd $script_dir
    stow -t $HOME src
}


echo "Do you wish to install? This will overwrite symlinks in $HOME with files in $script_dir/src"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install; break;;
        No ) exit;;
        default )
    esac
done
