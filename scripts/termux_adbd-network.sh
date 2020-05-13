#!/usr/bin/env bash

usage() {
  echo "Usage: $(basename "$0") start|stop|restart"
}

set_adbd_port() {
  su -c "setprop service.adb.tcp.port ${1}; stop adbd; start adbd"
}

enable_nw_adb() {
  set_adbd_port "${ADBD_PORT:-5555}"
}

disable_nw_adb() {
  set_adbd_port -1
}

case "$1" in
  help|--help|-h)
    usage
    exit 0
    ;;
  start|enable)
    enable_nw_adb
    ;;
  stop|disable)
    disable_nw_adb
    ;;
  restart)
    disable_nw_adb
    enable_nw_adb
    ;;
  *)
    usage
    exit 2
    ;;
esac
