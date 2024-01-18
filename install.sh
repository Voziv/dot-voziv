#!/bin/bash

# Script Directory
script_dir=$(dirname ${BASH_SOURCE[0]})
script_dir=$(realpath ${script_dir})
if [[ ! -d "$script_dir" ]]; then script_dir="$PWD"; fi

runDate=$(date -d "today" +"%Y%m%d%H%M%S")

function install() {
    ensure_user_bin
    install_symlinks
    install_profile
    install_zshrc
}

function ensure_user_bin() {
    echo "Ensuring $HOME/bin is created"
    mkdir -p "$HOME/bin"
}

function install_symlinks() {
    # Clean up old items, useful for upgrading other machines.
    rm_symlink "$HOME/.nvimrc" "$script_dir/.vimrc"
    rm_symlink "$HOME/.vimrc" "$script_dir/.vimrc"
    
    # Add symlinks
    do_symlink "$HOME/.config/nvim" "$script_dir/nvim"
    do_symlink "$HOME/.gitconfig" "$script_dir/git/gitconfig"
    do_symlink "$HOME/.tmux.conf" "$script_dir/.tmux.conf"
    do_symlink "$HOME/.screenrc" "$script_dir/.screenrc"
}

function do_symlink() {
    local link=$1
    local target=$2

    if [ -L "$link" ]; then
        if [ "$(readlink -- "$link")" = "$target" ]; then
            echo "$link already points to $target"
            return
        fi
        
        echo "Removing $link that points to `readlink $link`. Reason: Installing new link"
        rm "$link"
    else
        if [ -e "$link" ]; then
            echo "$link exists and is not a symlink. Not removing it to be safe."
            return
        fi

        echo "Symlinking $link to $target"
    fi

    ln -s "$target" "$link"
}

function rm_symlink() {
    local link=$1
    local expectedTarget=$2

    if [ -L "$link" ]; then
        echo "Removing $link that points to `readlink $link`. Reason: Deprecated"
        rm "$link"
    fi
}


function install_profile() {
    sourceString="source $script_dir/profile"
    if grep -q -F "$sourceString" "$HOME/.profile"; then 
        echo ".profile already configured. Skipping."
        return
    fi

    echo ".profile not configured Installing .profile"
    echo "$sourceString" >> "$HOME/.profile"
}

function install_zshrc() {
    sourceString="source $script_dir/.zshrc"
    if grep -q -F "$sourceString" "$HOME/.zshrc"; then 
        echo ".zshrc already configured. Skipping."
        return
    fi
    
    echo ".zshrc not configured Installing .zshrc"
    if [ -f "$HOME/.zshrc" ]; then
        mv "$HOME/.zshrc" "$HOME/.zshrc.pre-dot-voziv-${runDate}"
    fi

    echo "$sourceString" > "$HOME/.zshrc"
}

echo "Do you wish to install? This will overwrite symlinks in $HOME with files in $script_dir"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install; break;;
        No ) exit;;
        default )
    esac
done
