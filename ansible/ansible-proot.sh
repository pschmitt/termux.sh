#!/data/data/com.termux/files/usr/bin/bash -e

# This is loosely based on
# https://github.com/Hax4us/TermuxAlpine/blob/master/TermuxAlpine.sh#L137-L155

# thnx to @j16180339887 for DNS picker
addresolvconf () {
  local android
  android="$(getprop ro.build.version.release)"
  if [[ ${android%%.*} -lt 8 ]]
  then
    if command -v getprop
    then
      getprop | sed -n -e 's/^\[net\.dns.\]: \[\(.*\)\]/\1/p' | \
        sed '/^\s*$/d' | \
        sed 's/^/nameserver /' > "${PREFIX}/share/TermuxAlpine/etc/resolv.conf"
    fi
  fi
}
addresolvconf

# Create temp dirs
mkdir -p "$TMPDIR/dev-shm" "$TMPDIR/.ansible"

# Run
unset LD_PRELOAD

PROOT_ALIAS="${PROOT_ALIAS:-ansible}"

CMD=("$@")

if [[ -z "${CMD[*]}" ]]
then
  CMD=(ash)
fi

exec proot --link2symlink -0 \
  --kill-on-exit \
  -r "${PREFIX}/var/lib/proot-distro/installed-rootfs/${PROOT_ALIAS}/" \
  -b /dev/ \
  -b /proc/ \
  -b /sys/ \
  -b "$TMPDIR/dev-shm:/dev/shm" \
  -b "$TMPDIR/.ansible:/home/.ansible" \
  -b "$HOME" \
  -b "$HOME/.config/gnupg:/home/.config/gnupg" \
  -b "$HOME/.ssh/id_ed25519_ansible:/home/.ssh/id_ed25519_ansible" \
  -b "$PWD:/ansible" \
  -w /ansible \
  /usr/bin/env \
    HOME=/home \
    PREFIX=/usr \
    SHELL=/bin/sh \
    TERM="$TERM" \
    LANG="$LANG" \
    XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}" \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
  /bin/sh -c "${CMD[@]}"
