#!/bin/sh


function md() {
    if [[ ! -z "/usr/local/bin/mdless" ]]; then
        mdless --no-pager $1
    else
        echo "mdless not installed - run 'gem install mdless'"
    fi
}