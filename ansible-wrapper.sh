#!/usr/bin/env bash

COMMAND="$(basename "$0")"

# Ensure sshd is up
if ! pgrep -af "$(command -v sshd)" >/dev/null
then
  sshd
fi

"$(dirname "$(realpath "$0")")"/ansible-proot.sh \
  "$COMMAND $*"
