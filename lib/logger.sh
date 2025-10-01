#!/usr/bin/env bash

log_with_level() {
  local level="$1"
  local message="$2"
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  local log_dir="${LOG_DIR:-${SCRIPT_DIR:-$(pwd)}/logs}"
  local log_file="${log_dir}/sysmonitor.log"
  mkdir -p "${log_dir}"
  echo "[${timestamp}] [${level}] ${message}" | tee -a "${log_file}"
  if [[ "${level}" == "CRITICAL" ]]; then
    command -v logger >/dev/null 2>&1 && logger -p local0.err "SysMonitor: ${message}" || true
  fi
}

log_info() { log_with_level "INFO" "$1"; }
log_warning() { log_with_level "WARNING" "$1"; }
log_error() { log_with_level "ERROR" "$1"; }
log_critical() { log_with_level "CRITICAL" "$1"; }


