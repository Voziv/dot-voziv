#!/bin/bash

# Script Directory
script_dir=$(dirname ${BASH_SOURCE[0]})
script_dir=$(realpath ${script_dir})
if [[ ! -d "$script_dir" ]]; then script_dir="$PWD"; fi


function install() {
    do_symlink "$HOME/.gitconfig" "$script_dir/git/gitconfig"
    do_symlink "$HOME/.vimrc" "$script_dir/.vimrc"
    do_symlink "$HOME/.nvimrc" "$script_dir/.vimrc"
    do_symlink "$HOME/.tmux.conf" "$script_dir/.tmux.conf"
    do_symlink "$HOME/.screenrc" "$script_dir/.screenrc"
}

function do_symlink() {
    local link=$1
    local target=$2

    if [ -L "$link" ]; then
        rm "$link"
#        echo  "rm $link"
    else
        if [ -f "$link" ]; then
            echo "$link is a file. Not removing it to be safe."
        fi
    fi

    # ln -s <target> <link>
    ln -s "$target" "$link"
#    echo "ln -s $target $link"
}


function install_profile() {
    # TODO lrobert: Make sure .profile sources "$script_dir/profile"
    echo "Installing profile"
}

function install_zshrc() {
    # TODO lrobert: Make sure .profile sources "$script_dir/profile"
    echo "Installing zshrc"
}

echo "Do you wish to install? This will overwrite symlinks in $HOME with files in $script_dir"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install; break;;
        No ) exit;;
        default )
    esac
done
