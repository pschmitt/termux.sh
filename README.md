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
ansible on board. Somehow this gets around the sem_open issue on Android 🤷

## Setup

Run `install.sh --full` on your termux host.
If you don't want or need the symlinks just run the `ansible-install.sh` script.

## Install ansible from pip

To install the latest ansible version you can use the following: 
`ansible-install --pip`.
The same flag applies for the install script: `ìnstall.sh --full --pip`.

## Customize the symlink location

By default all the symlinks will be created in the `$HOME/bin` directory.
To set the destination path you need to set `$DEST` like so:
`DEST=$PREFIX/bin ./install.sh --full --pip`
