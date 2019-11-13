#!/usr/bin/env bash

cd "$(readlink -f "$(dirname "$0")")" || exit 9

# "Fake" commands
for file in termux_notify-send.sh termux_xsel.sh
do
  ln -sf $(realpath $file) \
    ~/bin/$(sed -nr 's/^termux_(.+).sh$/\1/p' <<< "$file")
done

# Ansible
if [[ "$1" == "--full" ]]
then
  ./ansible-install.sh "$2"
fi

ANSIBLE_COMMANDS=(
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

for cmd in ${ANSIBLE_COMMANDS[@]}
do
  ln -sf "$(realpath ansible-wrapper.sh)" \
    "${HOME}/bin/${cmd}"
done
