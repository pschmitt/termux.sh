#!/usr/bin/env bash

case "$1" in
  -b)
    # Skip the -b arg
    shift
    ;;
  -d)
    set -x
    DEBUG=1
    shift
    ;;
esac

# https://scripter.co/nim-check-if-stdin-stdout-are-associated-with-terminal-or-pipe/
if [[ -t 1 ]]  # output to terminal
then
  if [[ -t 0 ]] # input from terminal
  then
    if [[ -n "$DEBUG" ]]
    then
      echo "Get clipboard content" >&2
    fi
    termux-clipboard-get
  else  # input from pipe
    text=""
    while read -r LINE
    do
      text+="$LINE\n"
    done < /dev/stdin
    text=" ${text%\\n}"  # remove trailing \n
    if [[ -n "$DEBUG" ]]
    then
      echo -e "Setting clipboard to \"$text\"" >&2
    fi
    termux-clipboard-set -- "$text"
  fi
else  # output to pipe
  if [[ -n "$DEBUG" ]]
  then
    echo "Get clipboard content" >&2
  fi
  termux-clipboard-get
fi

# vim: set ft=bash et ts=2 sw=2 :
