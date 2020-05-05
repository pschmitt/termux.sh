#!/usr/bin/env bash

set -x

# https://github.com/termux/termux-packages/issues/1193
# https://github.com/termux/termux-packages/issues/491
# https://dontkillmyapp.com/general?app=Tasker

termux-wake-lock

# Disable android doze
su -c "dumpsys deviceidle disable"

# Disable wifi power saving
su -c "iw wlan0 set power_save off"

# Disable wifi power saving every 30 seconds
# su -c "while true; do iw wlan0 set power_save on; iw wlan0 set power_save off; sleep 30; done"

# Ping primary DNS server
get_ipv4_dns() {
  getprop | grep net.dns | \
    awk -v RS='([0-9]+\\.){3}[0-9]+' '/dns/ RT{print RT; exit}'
}
ping -c 10 -i 0.25 -s 0 "$(get_ipv4_dns)"

# termux-telephony-call 000
