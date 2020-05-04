#!/usr/bin/env bash

# https://dontkillmyapp.com/general?app=Tasker

usage() {
  echo "Usage: $(basename "$0") enable|disable|status"
}

case "$1" in
  help|--help|-h|h)
    usage
    exit 0
    ;;
  enable)
    su -c "dumpsys deviceidle disable"
    ;;
  disable)
    su -c "dumpsys deviceidle disable"
    ;;
  status)
    su -c "dumpsys deviceidle"
    ;;
  *)
    usage
    exit 2
    ;;
esac
