#!/usr/bin/env bash

cd "$(readlink -f "$(dirname "$0")")" || exit 9

DEST="${DEST:-${HOME}/bin}"

mkdir -p "$DEST"

# "Fake" commands
for file in scripts/*.sh
do
  ln -sf "$(realpath "$file")" \
    "${DEST}/$(basename "$file" | sed -r 's/termux_(.+).sh/\1/; s/.sh$//')"
done

# Ansible
if [[ "$1" == "--full" ]]
then
  shift
  ./ansible/ansible-install.sh "$@"
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
  ln -sf "$(realpath ansible/ansible-wrapper.sh)" \
    "${DEST}/${cmd}"
done

# Symlink ansible-install.sh
ln -sf "$(realpath ansible/ansible-install.sh)" \
  "${DEST}/ansible-install.sh"
