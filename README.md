Here lie a few scripts that are useful for termux users.

# Installation

## zinit

```bash
zinit has"termux-info" \
    wait lucid light-mode \
    as"null" \
    atclone'DEST="${ZPFX}/bin" ./install.sh' \
    atpull"%atclone" \
    run-atpull \
    atdelete'for f in ${ZPFX}/bin/*
             do
               if readlink -f "$f" | \
                 grep -qE "$ZINIT[PLUGINS_DIR]/pschmitt.*termux.sh"
               then
                 rm -fv "$f"
               fi
             done' \
  for pschmitt/termux.sh
```

The above config requires `$ZPFX/bin` to be in your `$PATH`, which should be the 
case by default. Adapt at will.

# Ansible

This repo holds wrappers for ansible. It uses an alpine proot image with
ansible on board. Somehow this gets around the
[sem_open issue on Android 🤷](https://github.com/termux/termux-packages/issues/1815).

## Setup

Run `install.sh --full` on your termux host.
If you don't want or need the symlinks just run the `ansible-install.sh` script.

## Install ansible from pip

To install the latest ansible version you can use the following: 

```bash
ansible-install --pip latest
```

The same flag applies for the install script: 

```bash
install.sh --full --pip latest
```

### Install a specific version of ansible

By default, the latest pip version will be installed when using `--pip latest`.
To install another one use:

```bash
ansible-install.sh --pip VERSION
```

As in: 

```bash
ansible-install.sh --pip 2.9.1
```

This also applies to the global installer:

```bash
install.sh --full --pip 2.9.1
```

## Add custom packages

To install custom packages inside the alpine proot you can do this as follows:

```bash
install.sh --full --pip 2.9.1 "git vim yadm"
ansible-install.sh --pip 2.9.1 "git vim yadm"
```

NOTE: This needs to be the last argument.

## Customize the symlink location

By default all the symlinks will be created in the `$HOME/bin` directory.
To set the destination path you need to set `$DEST` like so:
`DEST=$PREFIX/bin ./install.sh --full --pip`
