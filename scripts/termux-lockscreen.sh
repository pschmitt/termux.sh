#!/usr/bin/env bash

usage() {
  echo "Usage: $(basename "$0") lock | unlock [PIN] | state"
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

screen_is_on() {
  termux-display state | grep -q on
}

screen_is_off() {
  ! screen_is_on
}

is_locked() {
  su -c "dumpsys window" | \
    sed -nr 's/.*mDreamingLockscreen=(true|false).*/\1/p' | \
    grep -q true
}

unlock() {
  if ! is_locked
  then
    return
  fi
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
    state)
      if is_locked
      then
        echo locked
      else
        echo unlocked
      fi
      ;;
    *)
      usage
      exit 2
      ;;
  esac
fi
