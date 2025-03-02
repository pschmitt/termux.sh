#!/usr/bin/env bash

# echo "DOLLAR 1: $1" >> $TMPDIR/notify_send.log
# echo "DOLLAR 2: $2" >> $TMPDIR/notify_send.log
# echo "DOLLAR ALL: $@" >> $TMPDIR/notify_send.log

usage() {
  echo "Usage:"
  echo -e "  $(basename "$0") [OPTION…] <SUMMARY> [BODY]\n"
  echo "Options:"
  echo "  -a, --app-name          Specifies the app name"
  echo "  -c, --category TYPE     Specifies the notification category. (NOT IMPLEMENTED)"
  echo "  -i, --icon=ICON         Specifies an icon filename or stock icon to display."
  echo "  -t, --expire-time TIME  Specifies the timeout in milliseconds at which to expire the notification."
  echo "  -u, --urgency LEVEL     Specifies the urgency level (low, normal, critical)."
}

ARGS=$(getopt -o a:c:i:t:u: -l "app-name:,category:,icon:,expire-time:,urgency:" \
              -n "$(basename "$0")" -- "$@")

# FIXME Disable SC2181 since doing "if ! ARGS=.." makes the script unparsable in vim
# https://github.com/tree-sitter/tree-sitter-bash/issues/86
# if ! ARGS=$(getopt -o a:t:u: -l "app-name:,expire-time:,urgency:" \
#               -n "$(basename "$0")" -- "$@")
# shellcheck disable=2181
if [[ "$?" != "0" ]]
then
  usage >&2
  exit 2
fi

eval set -- "$ARGS";

APP_NAME=termux
CATEGORY=
EXPIRE_TIME=
ICON=
URGENCY=default # high/low/max/min/default
VIBRATION_PATTERN=800,500,1000
EXTRA_ARGS=()

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
    -c|--category)
      shift
      if [[ -n "$1" ]]
      then
        CATEGORY="$1"
        shift
      fi
      ;;
    -i|--icon)
      shift
      if [[ -n "$1" ]]
      then
        ICON="$1"
        shift
      fi
      ;;
    -t|--expire-time)
      shift
      if [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]
      then
        EXPIRE_TIME="$1"
        # Convert from milliseconds
        EXPIRE_TIME="$(( EXPIRE_TIME / 1000 ))"
        NOTIFICATION_ID="$RANDOM"
        EXTRA_ARGS+=(-i "$NOTIFICATION_ID")
        shift
      else
        echo "Invalid expire-time: $1" >&2
        exit 2
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

if [[ -n $ICON ]]
then
  # NOTE While --icon seems to be what we want, given it's the same name, but
  # this flag is merely to set the material design notification icon:
  # https://fonts.google.com/icons?selected=Material+Icons:account_circle:&icon.size=24&icon.color=%23e3e3e3)
  EXTRA_ARGS+=(--image-path "$ICON")
fi

termux-notification \
  "${EXTRA_ARGS[@]}" \
  --group "$APP_NAME" \
  --vibrate "$VIBRATION_PATTERN" \
  --priority "$URGENCY" \
  -t "$TITLE" \
  -c "$CONTENT"

if [[ "$EXPIRE_TIME" ]]
then
  (sleep "$EXPIRE_TIME"; termux-notification-remove "$NOTIFICATION_ID")&
fi

# vim: set ft=bash et ts=2 sw=2 :
