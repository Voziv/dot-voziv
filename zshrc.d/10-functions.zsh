#!/bin/zsh

# reference to dir containing source files
zshdir=${0:h}

# reference to dir containing completion function files
fpath+="`dirname $0`/completions"

### shortcut functions to edit zsh configurations
function zedit () {
    file=$1
    case "$file" in
        aliases|functions|zshrc|completions|paths)
            vi ${zshdir}/${file}
            ;;
        *)
            echo "Invalid file"
            return 0
            ;;
    esac
}

function md() {
    if [[ ! -z "/usr/local/bin/mdless" ]]; then
        mdless --no-pager $1
    else
        echo "mdless not installed - run 'gem install mdless'"
    fi
}

# TODO check if screen session of <fruit> name already exists
# before creating a same-named session.
function scn() {

    fruits=(
        banana      mango       orange
        peach       cherry      pineapple
        watermelon  rasberry    strawberry
        grape       grapefruit  pomegranate)

    numFruits=${#fruits}

    if (( $# > 0 )) {
        screen $@
    } else {
        name=$fruits[$[RANDOM % numFruits + 1]]

        screen -S "$name"
    }
}

#
# A completely useless function, that just does what the name implies
#
function look-busy() {
    while (true) {
        for i in $(find . -name \*); do
            \ls $i
            for j in $i; do
                if [[ -d $j ]]; then
                    \ls -a $j
                else
                    od $j --width=40  -A x -t x1z -v | awk -F=' ' '{ print $0 }' | grep --color -e '>.\+'
                    sleep $[RANDOM % 3]
                fi
            done
        done
    }
}

function calc() {
    echo "$@" | bc
}

function grade() {
    print "scale=2; $1 / $2 * 100" | bc
}
