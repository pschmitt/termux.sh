#!/usr/bin/env bash

"$(dirname "$(realpath "$0")")"/ansible-proot.sh \
  "ansible-playbook $*"
