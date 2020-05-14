#!/usr/bin/env bash

already_connected() {
  adb devices | grep -qE "localhost|127.0.0.1"
}

adb_connect() {
  # Setup ADB over network
  adbd-network restart
  # Wait 5 seconds max for the ADB port
  timeout "${MAX_WAIT_TIME:-5}" bash -c -- \
    'while ! nc -w 1 -z localhost 5555; do sleep 1; done'
  adb connect localhost
}

# adb connect
if ! already_connected
then
  {
    adb kill-server
    adb_connect
  } >&2
fi

adb -s localhost "$@"
