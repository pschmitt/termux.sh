#!/usr/bin/env bash

cd "$(readlink -f "$(dirname "$0")")" || exit 9

DEST="${DEST:-${HOME}/bin}"

mkdir -p "$DEST"

# "Fake" commands
for file in termux_notify-send.sh termux_xsel.sh
do
  ln -sf "$(realpath "$file")" \
    "${DEST}/$(sed -nr 's/^termux_(.+).sh$/\1/p' <<< "$file")"
done

# Ansible
if [[ "$1" == "--full" ]]
then
  ./ansible-install.sh "$2"
fi

ANSIBLE_COMMANDS=(
  ansible
  ansible-config
  ansible-console
  ansible-galaxy
  ansible-playbook
  ansible-test
  ansible-connection
  ansible-doc
  ansible-inventory
  ansible-pull
  ansible-vault
)

for cmd in "${ANSIBLE_COMMANDS[@]}"
do
  ln -sf "$(realpath ansible-wrapper.sh)" \
    "${DEST}/${cmd}"
done

# Symlink ansible-install.sh
ln -sf "$(realpath ansible-install.sh)" \
  "${DEST}/ansible-install.sh"
