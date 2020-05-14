#!/usr/bin/env bash

usage() {
  echo "Usage: $(basename "$0") lock|unlock [PIN]"
}

__swipe_up() {
  adb-self shell input swipe 200 900 200 300
}

__enter_pin() {
  adb-self shell input text "$1"
  adb-self shell input keyevent ENTER
}

wake_screen() {
  termux-display on
}

screen_is_off() {
  termux-display state | grep -q off
}

unlock() {
  wake_screen
  __swipe_up

  if [[ -n "$1" ]]
  then
    __enter_pin "$1"
  fi
}

lock() {
  screen_is_off || adb-self shell input keyevent POWER
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  case "$1" in
    help|h|-h|--help)
      usage
      exit 0
      ;;
    lock)
      lock
      ;;
    unlock)
      shift
      unlock "$@"
      ;;
    *)
      usage
      exit 2
      ;;
  esac


fi
