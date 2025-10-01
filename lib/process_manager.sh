#!/usr/bin/env bash

list_top_processes() {
  ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 11
}

find_zombie_processes() {
  ps -eo pid,stat,comm | awk '$2 ~ /Z/ {print}'
}

monitor_specific_process() {
  local target="${PROCESS_TO_MONITOR:-}"
  [[ -z "${target}" ]] && { echo "No specific process configured"; return 0; }
  if pgrep -f -- "${target}" >/dev/null 2>&1; then
    echo "Process '${target}' is running"
  else
    echo "Process '${target}' is NOT running"
    return 1
  fi
}

kill_problematic_process() {
  local pattern="$1"
  local signal="${2:-TERM}"
  if pgrep -f -- "${pattern}" >/dev/null 2>&1; then
    pkill -$signal -f -- "${pattern}" || return 1
    echo "Sent SIG${signal} to processes matching '${pattern}'"
  else
    echo "No processes matching '${pattern}'"
  fi
}


