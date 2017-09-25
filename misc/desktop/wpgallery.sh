#!/bin/bash

# Change desktop wallpaper randomly after some time.

# https://github.com/abelikoff/shell-tools


pictdir="$HOME/Pictures/wallpapers"
timeout=20m

prog=$(basename $0)

function usage() {
    echo "
Usage:  $prog  [<wallpaper_dir> [<timeout>]]


$prog sets and periodically changes the wallpaper.


$prog supports the following options:

    -g                        - Use gsettings to set wallpaper.
                                (default: use ImageMagick)
    -h                        - display this message

"
}

function fatal() {
    echo "$prog:  ERROR: " $@ 2>&1
    exit 1
}


# parse options

unset use_gsettings

while getopts ":gh" opt ; do
    case $opt in
        g) use_gsettings=1
           ;;

        h) usage
           exit 0
           ;;

        :) fatal "option '-$OPTARG' requires an argument"
           ;;

        \?) fatal "unknown option: '-$OPTARG'"
            ;;
    esac
done

shift $((OPTIND-1))

if [[ $# -gt 2 ]]; then
    usage
    exit 1
fi

if [[ $# -ge 1 ]]; then
    pictdir="$1"
fi

if [[ $# -eq 2 ]]; then
    timeout="$2"
fi

if [[ ! -d $pictdir ]]; then
    fatal "no such directory: $pictdir"
fi


# check if program is already running

if pidof -x $prog > /dev/null; then
    for p in $(pidof -x $prog); do
        if [[ $p -ne $$ ]]; then
            fatal "already running"
        fi
    done
fi

if [[ ! $use_gsettings ]]; then
    geometry="$(xdpyinfo  | grep -oP 'dimensions:\s+\K\S+')"

    which display > /dev/null || {
        fatal "ImageMagick not installed (can't find 'display' program)"
    }
fi


# always match, always case insensitive

shopt -s nocaseglob
shopt -s nullglob

while true; do
    pic_file=$(ls $pictdir/*.jpg $pictdir/*.jpeg | shuf -n1)

    if [[ $pic_file == "" ]]; then
        fatal "no image files in $pictdir"
    else
        if [[ -n $use_gsettings ]]; then
            gsettings set org.gnome.desktop.background picture-uri \
              "file://${pic_file}"
        else
            display -size "${geometry}" -window root "${pic_file}"
        fi
    fi

    sleep $timeout
done
