#!/usr/bin/env bash

usage() {
  echo "Usage: $(basename "$0") on|off|state"
}

display_is_on() {
  su -c "dumpsys display" | \
    sed -nr 's/.*mScreenState=([ONF]+).*/\1/p' | \
    grep -q ON
}

press_power_button() {
  adb-self shell input keyevent POWER
}

turn_on_display() {
  if ! display_is_on
  then
    press_power_button
  fi
}

turn_off_display() {
  if display_is_on
  then
    press_power_button
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  case "$1" in
    help|h|-h|--help)
      usage
      exit 0
      ;;
    state)
      if display_is_on
      then
        echo on
      else
        echo off
      fi
      ;;
    on|enable|turn-on)
      turn_on_display
      ;;
    off|disable|turn-off)
      turn_off_display
      ;;
    *)
      usage
      exit 2
      ;;
  esac
fi
