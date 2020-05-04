#!/usr/bin/env bash

# echo "DOLLAR 1: $1" >> $TMPDIR/notify_send.log
# echo "DOLLAR 2: $2" >> $TMPDIR/notify_send.log
# echo "DOLLAR ALL: $@" >> $TMPDIR/notify_send.log

ARGS=$(getopt -o a:e:u: -l "app-name:,expire-time:,urgency:" -n "$(basename "$0")" -- "$@")
eval set -- "$ARGS";

if [[ $? -ne 0 ]]
then
  usage
  exit 1
fi

APP_NAME=termux
EXPIRE_TIME=
URGENCY=default # high/low/max/min/default
VIBRATION_PATTERN=800,500,1000

while true
do
  case "$1" in
    -a|--app-name)
      shift
      if [[ -n "$1" ]]
      then
        APP_NAME="$1"
        shift
      fi
      ;;
    -e|--expire-time)
      shift
      if [[ -n "$1" ]]
      then
        EXPIRE_TIME="$1"
        shift
      fi
      ;;
    -u|--urgency)
      shift
      if [[ -n "$1" ]]
      then
        case "$1" in
          low)
            URGENCY=low
            ;;
          normal)
            URGENCY=default
            ;;
          critical)
            URGENCY=high
            ;;
        esac
        URGENCY="$1"
        shift
      fi
      ;;
    --)
      shift
      break
      ;;
  esac
done

TITLE="$1"
CONTENT="$2"

termux-notification \
  --group "$APP_NAME" \
  --vibrate "$VIBRATION_PATTERN" \
  --priority "$URGENCY" \
  -t "$TITLE" \
  -c "$CONTENT"

# vim: set ft=bash et ts=2 sw=2 :