Here lie a few scripts that are useful for termux users.

# Installation

## zplugin

```bash
if command -v termux-info > /dev/null
  zplugin ice wait lucid pick"/dev/null" \
    atclone'ln -sf $(realpath termux-fullscreen.sh) ~/bin/termux-fullscreen;
            ln -sf $(realpath termux_notify-send) ~/bin/notify-send;
            ln -sf $(realpath termux_xsel) ~/bin/xsel;
            ln -sf $(realpath ansible.sh) ~/bin/ansible;
            ln -sf $(realpath ansible-playbook.sh) ~/bin/ansible-playbook' \
    atpull"%atclone"
  zplugin light pschmitt/termux.sh
fi
```

The above config requires `$HOME/bin` to be in your `$PATH`. Adapt at will.

# Ansible

This repo holds wrappers for ansible. It uses an alpine proot image with
ansible on board. Somehow this gets around the sem_open issue on Android 🤷

## Setup

Run the `ansible-install.sh` script on your termux host.
