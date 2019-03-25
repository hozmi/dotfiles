# .bashrc

# -- peco --
function inject () {
    # https://unix.stackexchange.com/questions/213799/can-bash-write-to-its-own-input-stream/213821
    # (zsh)
    # print -z $@
    # (bash)
    if [ -t 1 ]; then
        bind '"\e[0n": "'"$*"'"'; printf '\e[5n'
        #bind '"\e[0n": "\007"'
    fi
}

function peco-history () {
    local res=$(history | sort -k 2 -k 1nr | uniq -f 1 | cut -c 8- | peco | head -n 1)
    if [ -n "$res" ] ; then
        inject $res
    fi
}

function peco-tmux-session () {
    local res=$(tmux list-sessions | peco | awk -F':' '{ print $1 }' | head -n 1)
    if [ -n "$res" ] ; then
        inject "tmux attach -t $res"
    fi
}

function peco-ps-kill () {
    local res=$(ps aux | peco | awk '{ print $2 }' | xargs echo)
    if [ -n "$res" ] ; then
        inject "kill $res"
    fi
}

function peco-pushd () {
    if [ -n "$*" ] ; then
        pushd "$*" > /dev/null
        return
    fi
    # else
    local res=$(dirs -v | peco | awk '{ print $1 }')
    if [ -n "$res" ] ; then
        pushd +$res > /dev/null
    fi
}
alias dirs='dirs -v'
alias pd='peco-pushd'

function peco-lsdir () {
    local res=$(ls -lF $@ | grep '/$' | peco | awk '{ print $9 }')
    if [ -n "$res" ] ; then
        inject "cd $res"
    fi
}


# -- ranger --
[ -n "$RANGER_LEVEL" ] && PS1='(ranger) '"$PS1"

function ranger-cd () {
    # Automatically change the directory in bash after closing ranger
    tempfile="$(mktemp -t tmp.XXXXXX)"
    ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
}

# -- misc --
function readlink_f () {
    # readlink -f $1
    targetfile=$1
    cd $(dirname $targetfile)
    targetfile=$(basename $targetfile)

    while [ "$targetfile" != "" ] ; do
        targetfile=$(readlink $targetfile)
        cd $(dirname $targetfile)
        targetfile=$(basename $targetfile)
    done
    targetfile=$(pwd -P)/$targetfile

    echo $targetfile
}

# -- wsl (Windows Subsystem for Linux) --
function explorer () {
    local res=$(wslpath -w $@)
    if [ $? = 0 ] ; then
        explorer.exe $res
    else
        explorer.exe
    fi
}


# -- key bindings --
#if [ -t 1 ] ; then
#    bind -x '"\C-r":peco-history'
#fi

#EOF