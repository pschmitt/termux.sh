#!/usr/bin/env bash

usage() {
  echo "Usage: $(basename "$0") [--uninstall|--pip VERSION] [PKGS]"
}

get_tmpdir() {
  echo "${TMPDIR:-/tmp}"
}

uninstall_alpine() {
  proot-distro remove ansible || true
}

install_alpine() {
  proot-distro install --override-alias ansible alpine
  _alpine_exec "echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories"
}

_alpine_exec() {
  proot-distro login --termux-home ansible -- ash -c "$@"
}

install_ansible() {
  case "$1" in
    pip|--pip|--latest|latest)
      shift
      install_ansible_pip "$@"
      ;;
    *)
      install_ansible_pkg "$@"
      ;;
  esac
}

install_ansible_pkg() {
  _alpine_exec "apk add --no-cache ansible bash gnupg py3-setuptools openssh sops"

  # Install dnspython from pypi rather than the.repo, as of 2023-05-22 the
  # dig lookup doens't work with the repo version
  _alpine_exec "apk add --no-cache py3-pip"
  _alpine_exec "pip3 install dnspython"
  # Install extra packages
  if [[ -n "$1" ]]
  then
    _alpine_exec "apk add --no-cache $1"
  fi
}

install_ansible_pip() {
  local ansible_version="$1"
  local ansible_spec="ansible"

  if [[ -n "$ansible_version" && "$ansible_version" != "latest" ]]
  then
    ansible_spec="ansible==${ansible_version}"
  fi
  # Install requirements
  _alpine_exec \
    "apk add --no-cache python3 openssh bash \
      py3-pip py3-setuptools py3-cffi py3-cryptography py3-markupsafe py3-jinja2 py3-yaml gnupg sops && \
    apk add --no-cache -t build-deps build-base python3-dev && \
    pip3 install -U \"${ansible_spec}\" dnspython && \
    apk del build-deps"
  # Install extra packages
  if [[ -n "$2" ]]
  then
    _alpine_exec "apk add --no-cache $2"
  fi
}

_get_ansible_version() {
  local v
  v=$(_alpine_exec "ansible --version" 2>/dev/null)
  sed -rn 's/^ansible\s+\[core\s+([0-9.]+).*/\1/p' <<< "$v" | head -1
}

show_ansible_version() {
  echo "Installed Ansible $(_get_ansible_version)"
}

check_install() {
  local version
  version="$(_get_ansible_version)"
  # Disable check to avoid doing the work twice
  # shellcheck disable=2181
  if [[ "$?" -ne 0 ]]
  then
    return 1
  fi
  [[ -n "$version" ]]
}

setup_host() {
  pkg install -y openssh proot-distro
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

  set -exo

  case "$1" in
    help|h|--help|-h)
      usage
      exit 0
      ;;
    uninstall|--uninstall|--rm|--delete|--del)
      uninstall_alpine
      ;;
    noreinstall|nr|--noreinstall|-n|--nr)
      NOREINSTALL=1
      shift
      ;&
    *)
      if [[ "$NOREINSTALL" == "1" ]]
      then
        if check_install
        then
          exit 0
        fi
      fi
      uninstall_alpine
      setup_host
      uninstall_alpine
      install_alpine
      install_ansible "$@"
      show_ansible_version
      ;;
  esac
fi
