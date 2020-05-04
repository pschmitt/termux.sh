#!/usr/bin/env bash

usage() {
  echo "Usage: $(basename "$0") fullscreen|disable"
}

enable_fullscreen() {
  sudo settings put global policy_control immersive.full=com.termux
}

disable_fullscreen() {
  sudo settings put global policy_control immersive.off=com.termux
}

enable_fullscreen_navbar() {
  sudo settings put global policy_control immersive.status=com.termux
}

case "$1" in
  fullscreen|full|f)
    enable_fullscreen
    ;;
  disable|d)
    disable_fullscreen
    ;;
  fullscreen-navbar|fn)
    enable_fullscreen_navbar
    ;;
  *)
    usage
    ;;
esac

# vim: set ft=sh et ts=2 sw=2 :
