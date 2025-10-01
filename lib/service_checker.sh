#!/usr/bin/env bash

check_critical_services() {
  local failed=()
  for svc in "${CRITICAL_SERVICES[@]}"; do
    if systemctl is-active --quiet "$svc"; then
      echo "$svc: active"
    else
      echo "$svc: INACTIVE"
      failed+=("$svc")
    fi
  done
  if (( ${#failed[@]} > 0 )); then
    echo "Failed services: ${failed[*]}" >&2
    return 1
  fi
}

restart_failed_service() {
  local svc="$1"
  systemctl restart "$svc"
  systemctl is-active --quiet "$svc" && echo "$svc restarted successfully" || { echo "$svc restart FAILED"; return 1; }
}

check_service_logs() {
  local svc="$1"
  journalctl -u "$svc" -n 50 --no-pager
}

validate_service_config() {
  local unit="$1"
  if command -v systemd-analyze >/dev/null 2>&1; then
    systemd-analyze verify "/etc/systemd/system/${unit}.service" 2>&1 || return 1
  else
    echo "systemd-analyze not available; skipping deep validation"
  fi
}


