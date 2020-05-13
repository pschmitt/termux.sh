#!/usr/bin/env bash

cd "$(readlink -f "$(dirname "$0")")" || exit 9

# adb connect
{
  adb kill-server
  adbd-network restart

  # Wait 5 seconds max for the ADB port
  timeout "${MAX_WAIT_TIME:-5}" bash -c -- \
    'while ! nc -w 1 -z localhost 5555; do sleep 1; done'
  adb connect localhost
} &>/dev/null

adb -s localhost "$@"
