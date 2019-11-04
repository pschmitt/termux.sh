#!/data/data/com.termux/files/usr/bin/bash -e
unset LD_PRELOAD
# thnx to @j16180339887 for DNS picker
addresolvconf ()
{
  android=$(getprop ro.build.version.release)
  if [ ${android%%.*} -lt 8 ]; then
  [ $(command -v getprop) ] && getprop | sed -n -e 's/^\[net\.dns.\]: \[\(.*\)\]/\1/p' | sed '/^\s*$/d' | sed 's/^/nameserver /' > ${PREFIX}/share/TermuxAlpine/etc/resolv.conf
  fi
}
addresolvconf

# Create temp dirs
mkdir -p "$TMPDIR/dev-shm" "$TMPDIR/.ansible"

# Ensure sshd is up
if ! netstat -tlnp | grep -q "8022.*sshd"
then
  sshd
fi

# Run
exec proot --link2symlink -0 -r ${PREFIX}/share/TermuxAlpine/ \
  -b /dev/ -b "$TMPDIR/dev-shm:/dev/shm" -b /sys/ -b /proc/ \
  -b "$TMPDIR/.ansible:/home/.ansible" \
  -b "$HOME/.ssh/id_ed25519_ansible:/home/.ssh/id_ed25519_ansible" \
  -b "$PWD:/ansible" \
  -w /ansible \
  /usr/bin/env HOME=/home PREFIX=/usr SHELL=/bin/sh TERM="$TERM" LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin \
  /bin/sh -c "$@"
