#!/usr/bin/env bash

# https://github.com/termux/termux-packages/issues/1193
# https://github.com/termux/termux-packages/issues/491
# https://dontkillmyapp.com/general?app=Tasker

seppuku() {
  {
    sleep "${MAX_RUNTIME:-60}"
    echo "Committing seppuku">&2
    kill $$
  } &
}

disable_android_doze() {
  su -c "dumpsys deviceidle disable"
}

disable_wifi_power_saving() {
  su -c "iw wlan0 set power_save off"
}

disable_ipv6() {
  su -c 'echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6'
  su -c 'echo 0 > /proc/sys/net/ipv6/conf/wlan0/accept_ra'
  su -c 'echo 1 > /proc/sys/net/ipv6/conf/wlan0/disable_ipv6'
}

# Get IPv4 DNS server
get_ipv4_dns() {
  getprop | grep net.dns | \
    awk -v RS='([0-9]+\\.){3}[0-9]+' '/dns/ RT{print RT; exit}'
}

get_default_gateway() {
  local dns_server
  local route

  dns_server=$(get_ipv4_dns)
  route=$(ip route get "${dns_server}")

  # If there's no "via XXX.XXX.XXX.XXX" then the DNS server is probably the GW
  if ! grep -q via <<< "$route"
  then
    echo "$dns_server"
    return
  fi

  sed -rn "s/${dns_server} via (([0-9]{1,3}\.){3}[0-9]{1,3}).*/\1/p" \
    <<< "$route"
}

ping_default_gw() {
  ping -c 10 -i 0.25 -s 0 "$(get_default_gateway)"
}

wifi_is_connected() {
  termux-wifi-connectioninfo | jq -r .supplicant_state | grep -q "COMPLETED"
}

wifi_enable() {
  if ! wifi_is_connected
  then
    termux-wifi-enable true
    termux-display on
  fi
}

sshd_check() {
  # if ! su -c "ss -tlnp" | grep -q ":8022.*sshd"
  if ! nc localhost "${SSHD_PORT:-8022}" <<< "EXIT" 2>/dev/null | grep -q SSH
  then
    sshd
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  set -x

  seppuku

  termux-wake-lock

  disable_android_doze
  disable_wifi_power_saving
  # disable_ipv6

  wifi_enable

  ping_default_gw

  sshd_check

  # Keep screen on
  # termux-telephony-call 000
fi
