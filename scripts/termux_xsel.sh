#!/data/data/com.termux/files/usr/bin/env bash

while [[ -n "$*" ]]
do
  case "$1" in
    -p|--primary|--secondary|-s|--clipboard|-b)
      # Skip the selection arg
      shift
      ;;
    -o|--output)
      OUT=1
      shift
      ;;
    -i|--input)
      IN=1
      shift
      ;;
    -d|--debug)
      set -x
      DEBUG=1
      shift
      ;;
  esac
done

# https://scripter.co/nim-check-if-stdin-stdout-are-associated-with-terminal-or-pipe/
if [[ -n "$OUT" && -z "$IN" ]] || [[ -t 0 ]]
then
  if [[ -n "$DEBUG" ]]
  then
    echo "Get clipboard content" >&2
  fi
  termux-clipboard-get
else  # input from pipe
  text=$(< /dev/stdin)
  if [[ -n "$DEBUG" ]]
  then
    echo -e "Setting clipboard to \"$text\"" >&2
  fi
  termux-clipboard-set -- "$text"
fi

# vim: set ft=bash et ts=2 sw=2 :
