#!/usr/bin/env bash

set -e -o pipefail

cd "$(readlink -f "$(dirname "$0")")" || exit 9

DEST="${DEST:-${HOME}/bin}"

mkdir -p "$DEST"

# "Fake" commands
for file in scripts/*.sh
do
  ln -sfv "$(realpath "$file")" \
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
  ln -sfv "$(realpath ansible/ansible-wrapper.sh)" \
    "${DEST}/${cmd}"
done

# Symlink ansible-install.sh and ansible-proot.sh
for cmd in ansible-install.sh ansible-proot.sh
do
  ln -sfv "$(realpath "ansible/${cmd}")" \
    "${DEST}/${cmd}"
done
