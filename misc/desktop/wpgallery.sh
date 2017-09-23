#!/bin/bash

# Change desktop wallpaper randomly after some time.

# https://github.com/abelikoff/shell-tools


pictdir="$HOME/Pictures/wallpapers"
timeout=20m

prog=$(basename $0)

if [[ $# -eq 1 && $1 == "-h" ]]; then
    echo "Usage:  $prog  [<wallpaper_dir> [<timeout>]]"
    exit 0
fi

if [[ $# -gt 2 ]]; then
    echo "Usage:  $prog  [<wallpaper_dir> [<timeout>]]" 2>&1
    exit 1
fi

if [[ $# -ge 1 ]]; then
    pictdir="$1"
fi

if [[ $# -eq 2 ]]; then
    timeout="$2"
fi

if [[ ! -d $pictdir ]]; then
    echo "$prog: ERROR: no such directory: $pictdir" 2>&1
    exit 1
fi


# check if program is already running

if pidof -x $prog > /dev/null; then
    for p in $(pidof -x $prog); do
        if [[ $p -ne $$ ]]; then
            echo "$prog: ERROR: already running" 2>&1
            exit 1
        fi
    done
fi


# always match, always case insensitive

shopt -s nocaseglob
shopt -s nullglob

while true; do
    pic_file=$(ls $pictdir/*.jpg $pictdir/*.jpeg | shuf -n1)

    if [[ $pic_file == "" ]]; then
        echo "$prog: no image files in $pictdir" 2>&1
        exit 1
    else
        gsettings set org.gnome.desktop.background picture-uri \
            "file://${pic_file}"
    fi

    sleep $timeout
done

