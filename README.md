Here lie a few scripts that are useful for termux users.

# Installation

## zplugin

```bash
zplugin ice wait lucid pick"/dev/null" has"termux-info" \
  atclone'./install.sh' atpull"%atclone"
zplugin light pschmitt/termux.sh
```

The above config requires `$HOME/bin` to be in your `$PATH`. Adapt at will.

# Ansible

This repo holds wrappers for ansible. It uses an alpine proot image with
ansible on board. Somehow this gets around the
[sem_open issue on Android 🤷])(https://github.com/termux/termux-packages/issues/1815).

## Setup

Run `install.sh --full` on your termux host.
If you don't want or need the symlinks just run the `ansible-install.sh` script.

## Install ansible from pip

To install the latest ansible version you can use the following: 
`ansible-install --pip`.
The same flag applies for the install script: `install.sh --full --pip`.

### Install a specific version of ansible

By default, the latest pip version will be installed when using the `--pip` flag.
To install another one use: `ansible-install.sh --pip VERSION`.
As in: `ansible-install.sh --pip 2.9.1`.
This also applies to the global installer: `install.sh --full --pip 2.9.1`.

## Customize the symlink location

By default all the symlinks will be created in the `$HOME/bin` directory.
To set the destination path you need to set `$DEST` like so:
`DEST=$PREFIX/bin ./install.sh --full --pip`
