#!/usr/bin/env bash

usage() {
  echo "Usage: $(basename "$0") [--uninstall|--pip VERSION] [PKGS]"
}

get_tmpdir() {
  echo "${TMPDIR:-/tmp}"
}

uninstall_alpine() {
  local tmpdir

  tmpdir="$(get_tmpdir)"
  cd "$tmpdir"

  curl -LO \
    https://raw.githubusercontent.com/Hax4us/TermuxAlpine/master/TermuxAlpine.sh
  yes | bash TermuxAlpine.sh --uninstall || true
}

install_alpine() {
  local tmpdir

  tmpdir="$(get_tmpdir)"
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
  # proot --link2symlink -0 \
  #   -r ${PREFIX}/share/TermuxAlpine/ \
  #   -b /dev/ -b /sys/ -b /proc/ -b /sdcard -b /storage -b $HOME \
  #   -w /home /usr/bin/env HOME=/root PREFIX=/usr SHELL=/bin/sh TERM="$TERM" \
  #     LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin \
  #   /bin/sh -c "$@"
  proot --link2symlink -0 \
    -r "${PREFIX}/share/TermuxAlpine/" \
    -b /dev/ -b /sys/ -b /proc/ \
    -w / \
    /usr/bin/env \
      LD_PRELOAD= \
      HOME=/root \
      PREFIX=/usr \
      SHELL=/bin/sh \
      TERM="$TERM" \
      LANG="$LANG" \
      PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/sh -c "$@"
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
  _alpine_exec "apk add --no-cache ansible openssh bash"
  # Install extra packages
  if [[ -n "$1" ]]
  then
    _alpine_exec "apk add --no-cache $1"
  fi
}

install_ansible_pip() {
  local ansible_version="$1"
  if [[ "$ansible_version" == "latest" ]]
  then
    ansible_version="$(_get_latest_ansible_version)"
  fi
  # Install requirements
  _alpine_exec \
    "apk add --no-cache python3 openssh bash \
      py3-cffi py3-cryptography py3-markupsafe py3-jinja2 py3-yaml && \
    apk add --no-cache -t build-deps build-base python3-dev && \
    pip3 install -U ansible==\"${ansible_version}\" && \
    apk del build-deps"
  # Install extra packages
  if [[ -n "$2" ]]
  then
    _alpine_exec "apk add --no-cache $2"
  fi
}

_get_ansible_version() {
  _alpine_exec "ansible --version" | sed -rn 's/^ansible\s+([0-9.]+).*/\1/p' | head -1
}

_get_latest_ansible_version() {
  git ls-remote --tags https://github.com/ansible/ansible | \
    sed -rn 's|.*refs/tags/v?([^\^]+)(\^\{\})?|\1|p' | \
    tail -1
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

cleanup() {
  rm -rf "$(get_tmpdir)/TermuxAlpine.sh"
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

  cleanup
fi
