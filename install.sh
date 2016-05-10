#!/bin/bash

install () {
    rm -rf $2
    ln -sf $1 $2
}

confirm () {
    SRCNAME="$(cd `dirname $0`; pwd)/$1"
    FNAME="$HOME/.$1"

    NAMES="$SRCNAME.$2 $SRCNAME.$2.sh $SRCNAME.$OS $SRCNAME.$OS.sh $SRCNAME.sh "
    for NAME in $NAMES; do
        if [ -e "$NAME" ]; then
            SRCNAME="$NAME"
            break
        fi
    done

    remove $FNAME
    echo "LINKING: $SRCNAME -> $FNAME"
    install $SRCNAME $FNAME
}

remove () {
    if [ -L "$1" ]; then
        echo "DELETING old link $1"
        rm $1
    elif [ -e "$1" ]; then
        echo "MOVING: $1 to $HOME/.old-dotfiles/"
        mkdir -p $HOME/.old-dotfiles
        mv -f "$1" "$HOME/.old-dotfiles/" 2>/dev/null || rm -rf $1
    fi
}

if [ -z "$HOME" -a "`whoami`" == "root" ]; then
    export HOME="/root"
fi

if [ -d "/proc" ]; then
    OS="linux"
    [[ -z "$HOME" ]] && export HOME="/home/`whoami`"
else
    OS="mac"
    [[ -z "$HOME" ]] && export HOME="/Users/`whoami`"
fi

# create symlinks to the dotfiles directory
confirm "bash_profile"
confirm "bash_functions"
confirm "vim"
confirm "vimrc"
confirm "gvimrc"
confirm "gemrc"
confirm "sqliterc"
[[ $OS == "mac" ]] && confirm "gitconfig"
lsb_release -a >/dev/null 2>&1 && confirm "bashrc" "ubuntu"
