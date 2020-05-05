#!/usr/bin/env bash

# https://github.com/termux/termux-packages/issues/1193

termux-wake-lock

# Disable wifi power saving
su -c "iw wlan0 set power_save off"

# Disable wifi power saving every 30 seconds
# su -c "while true; do iw wlan0 set power_save on; iw wlan0 set power_save off; sleep 30; done"

# Ping primary DNS server
get_ipv4_dns() {
  getprop | grep net.dns | \
    awk -v RS='([0-9]+\\.){3}[0-9]+' '/dns/ RT{print RT; exit}'
}
ping -c 3 -i 0.5 "$(get_ipv4_dns)" >/dev/null
