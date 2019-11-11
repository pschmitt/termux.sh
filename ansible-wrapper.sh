#!/usr/bin/env bash

COMMAND="$(basename $0)"

"$(dirname "$(realpath "$0")")"/ansible-proot.sh \
  "$COMMAND $*"
