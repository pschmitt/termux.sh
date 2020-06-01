#!/usr/bin/env bash

usage() {
  echo "Usage: $(basename "$0") lock | unlock [PIN] | state"
}

enter_pin() {
  adb-self shell input text "$1"
  adb-self shell input keyevent ENTER
}

wake_screen() {
  termux-display on
}

is_locked() {
  su -c "dumpsys window" | \
    grep -q "mDreamingLockscreen=true"
}

is_lockscreen_displayed() {
  su -c "dumpsys power" | grep -q 'mHoldingDisplaySuspendBlocker=true'
}

unlock() {
  if ! is_locked
  then
    return
  fi

  wake_screen
  # menu key
  adb-self shell input keyevent 82

  if is_lockscreen_displayed && [[ -n "$1" ]]
  then
    enter_pin "$1"
  fi
}

lock() {
  termux-display off
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  case "$1" in
    help|h|-h|--help)
      usage
      exit 0
      ;;
    lock|off|disable)
      lock
      ;;
    unlock|on|enable)
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
