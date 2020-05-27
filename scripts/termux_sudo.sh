#!/data/data/com.termux/files/usr/bin/bash

#set COLORED=1 to turn on colored error messages
#set COLORED=0 to turn off colored error messages
COLORED=${COLORED:-1}

#red=1 green=2 yellow=3
color() {
  if [[ "$COLORED" == "1" ]]
  then
    echo "$(tput setaf "$1")${*:2}$(tput sgr0)"
  else
    echo "${*:2}"
  fi
}

usage() {
  color 3 "Usage:"
  echo "sudo su [-]"
  echo "  $(color 2 Drop to root shell)"
  echo "sudo <command> [<args>]"
  echo "  $(color 2 Run command as root with optional arguments)"
  exit 0
}

unset LS_COLORS

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
PRE="$(dirname "$PREFIX")"

SYSBIN=/system/bin
SYSXBIN=/system/xbin
BB="$SYSXBIN/busybox"

ROOT_HOME="${HOME:-${PRE}/home}/.suroot"
BINPRE="$PREFIX/bin"
LDLP_EXPORT="export LD_LIBRARY_PATH=$PREFIX/lib"
CMDLINE="PATH=$PATH:$SYSXBIN:$SYSBIN;$LDLP_EXPORT;HOME=$ROOT_HOME;export TERM=$TERM;cd $PWD"

if [[ -x /magisk/.core/bin/su ]]
then
  SU=/magisk/.core/bin/su
elif [[ -x /sbin/su ]]
then
  SU=/sbin/su
elif [[ -x "$SYSXBIN/su" ]]
then
  SU="$SYSXBIN/su"
elif [[ -x /su/bin/su ]]
then
  SU=/su/bin/su
else
  echo "$(color 1 su) executable not found"
  echo "$(color 1 sudo) requires $(color 1 su)"
  exit
fi

if [[ ! -d "$ROOT_HOME" ]]
then
  if [[ -x "$BB" ]] && [[ $("$BB" --list | grep -w mount) == "mount" ]]
  then
    MOUNTEX="$BB mount"
  elif [[ -x $SYSBIN/mount ]]
  then
    MOUNTEX="$SYSBIN/mount"
  else
    echo "Cannot find $(color 1 mount) executable"
    color 2 "Unable to setup sudo"
    exit
  fi
  MOUNT_RW="$MOUNTEX -o rw,remount,rw /system"
  MOUNT_RO="$MOUNTEX -o ro,remount,ro /system"
  if [[ -x "/sbin/magisk" ]]
  then
    unset LD_LIBRARY_PATH
    "$SU" -c "$CMDLINE;$MOUNT_RW"
    "$SU" -c "$CMDLINE;mkdir $ROOT_HOME"
    "$SU" -c "$CMDLINE;chmod 700 $ROOT_HOME"
    BASHRC="'PS1=\"# \"\nexport TERM=$TERM\n$LDLP_EXPORT\nexport PATH=$PATH:$SYSXBIN:$SYSBIN'"
    "$SU" -c "$CMDLINE;echo -e $BASHRC > $ROOT_HOME/.bashrc"
    "$SU" -c "$CMDLINE;chmod 700 $ROOT_HOME/.bashrc"
    "$SU" -c "$CMDLINE;$MOUNT_RO"
  else
    "$SU" -c "$MOUNT_RW"
    "$SU" -c "mkdir $ROOT_HOME"
    "$SU" -c "chmod 700 $ROOT_HOME"
    BASHRC="'PS1=\"# \"\nexport TERM=$TERM\n$LDLP_EXPORT\nexport PATH=$PATH:$SYSXBIN:$SYSBIN'"
    "$SU" -c "echo -e $BASHRC > $ROOT_HOME/.bashrc"
    "$SU" -c "chmod 700 $ROOT_HOME/.bashrc"
    "$SU" -c "$MOUNT_RO"
  fi
fi

# Skip --
if [[ "$1" == "--" ]]
then
  shift
fi

ARGS=("$@")

if [[ -z "$*" ]]
then
  usage
elif [[ "$1" == "su" ]]
then
  CMDLINE="$CMDLINE;$BINPRE/bash"
elif [[ -x "$BINPRE/$1" ]]
then
  CMDLINE="$CMDLINE;$BINPRE/${ARGS[@]}"
else
  CMDLINE="$CMDLINE;${ARGS[@]}"
fi

EXTRA_ARGS=()
if "$SU" --help | grep -q -e --preserve-environment
then
  EXTRA_ARGS+=(--preserve-environment)
fi

if [[ -x "/sbin/magisk" ]]
then
  unset LD_LIBRARY_PATH
fi

"$SU" "${EXTRA_ARGS[@]}" -c "$CMDLINE"
RC="$?"

# Reset echo
stty sane &>/dev/null

exit "$RC"
