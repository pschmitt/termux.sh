#!/data/data/com.termux/files/usr/bin/bash -e

# This is loosely based on
# https://github.com/Hax4us/TermuxAlpine/blob/master/TermuxAlpine.sh#L137-L155

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

exec proot \
  --link2symlink \
  --root-id \
  --kill-on-exit \
  --sysvipc \
  --rootfs="${PREFIX}/var/lib/proot-distro/installed-rootfs/${PROOT_ALIAS}" \
  --bind=/dev \
  --bind=/proc \
  --bind=/sys \
  --bind="${TMPDIR}/dev-shm:/dev/shm" \
  --bind="${TMPDIR}/.ansible:/home/.ansible" \
  --bind="${HOME}" \
  --bind="${HOME}:/home" \
  --bind="${HOME}/.ssh:/root/.ssh" \
  --bind="${PWD}:${PWD}" \
  --cwd="$PWD" \
  /usr/bin/env \
    HOME="$HOME" \
    PREFIX=/usr \
    SHELL=/bin/sh \
    TERM="$TERM" \
    LANG="$LANG" \
    XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}" \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
  /bin/sh -c "${CMD[@]}"
