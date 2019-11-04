#!/usr/bin/env bash

install_alpine() {
  local tmpdir="${TMPDIR:-/tmp}"
  cd "$tmpdir"
  curl -LO \
    https://raw.githubusercontent.com/Hax4us/TermuxAlpine/master/TermuxAlpine.sh
  # Try new install
  if ! echo -e "\n" | bash TermuxAlpine.sh
  then
    # reinstall
    yes | bash TermuxAlpine.sh
  fi
}

_alpine_exec() {
  # Exec commands inside alpine proot
  LD_PRELOAD=
  proot --link2symlink -0 \
    -r ${PREFIX}/share/TermuxAlpine/ \
    -b /dev/ -b /sys/ -b /proc/ -b /sdcard -b /storage -b $HOME \
    -w /home /usr/bin/env HOME=/root PREFIX=/usr SHELL=/bin/sh TERM="$TERM" \
      LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/sh -c "$@"
}

install_ansible() {
  # Install requirements
  _alpine_exec "apk add --no-cache ansible openssh"
}

setup_host() {
  pkg install -y openssh
  setup_auth
  start_sshd
}

setup_auth() {
  local privkey="${HOME}/.ssh/id_ed25519_ansible"
  local pubkey="${privkey}.pub"
  local authorized_keys="${HOME}/.ssh/authorized_keys"
  mkdir -p "${HOME}/.ssh"
  if [[ ! -e "$privkey" ]]
  then
    ssh-keygen -t ed25519 -q -N "" -f "$privkey"
  fi
  if ! grep -q -f "$pubkey" "$authorized_keys"
  then
    cat "$pubkey" >> "$authorized_keys"
  fi
}

start_sshd() {
  sshd
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  set -euxo
  setup_host
  install_alpine
  install_ansible
fi
