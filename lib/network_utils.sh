#!/usr/bin/env bash

check_network_connectivity() {
  local target="${PING_TARGET:-8.8.8.8}"
  if ping -c 2 -W 2 "$target" >/dev/null 2>&1; then
    echo "Connectivity to $target: OK"
  else
    echo "Connectivity to $target: FAILED"
    return 1
  fi
}

monitor_network_interfaces() {
  if command -v ip >/dev/null 2>&1; then
    ip -br addr
  else
    ifconfig -a || true
  fi
}

check_open_ports() {
  if command -v ss >/dev/null 2>&1; then
    ss -tulpen
  else
    netstat -tulpen || true
  fi
}

monitor_network_traffic() {
  if command -v ss >/dev/null 2>&1; then
    ss -s
  else
    awk 'NR>2{print $1, $2, $10, $12}' /proc/net/dev
  fi
}


