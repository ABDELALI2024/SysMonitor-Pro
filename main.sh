#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

source "${SCRIPT_DIR}/lib/logger.sh"
source "${SCRIPT_DIR}/lib/system_monitor.sh"
source "${SCRIPT_DIR}/lib/process_manager.sh"
source "${SCRIPT_DIR}/lib/service_checker.sh"
source "${SCRIPT_DIR}/lib/network_utils.sh"

CONFIG_DIR="${SCRIPT_DIR}/config"
source "${CONFIG_DIR}/settings.conf"
source "${CONFIG_DIR}/thresholds.conf"

: "${LOG_DIR:?LOG_DIR must be set in settings.conf}"
: "${REPORT_DIR:?REPORT_DIR must be set in settings.conf}"

TEMP_DIR=""

validate_prerequisites() {
  local -a required_bins=("bash" "date" "awk" "sed" "grep" "tee" "df" "free" "uptime" "ps" "pgrep" "pkill" "systemctl" "journalctl" "ip" "ss" "ping" "logger" "hostname")
  local missing=0
  for bin in "${required_bins[@]}"; do
    if ! command -v "$bin" >/dev/null 2>&1; then
      echo "Missing dependency: $bin" >&2
      missing=1
    fi
  done
  [[ $missing -eq 0 ]]
}

prepare_environment() {
  mkdir -p "${LOG_DIR}" "${REPORT_DIR}"
  TEMP_DIR="$(mktemp -d)"
}

cleanup() {
  log_info "Cleaning up..."
  [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]] && rm -rf "${TEMP_DIR}"
}
trap 'rc=$?; cleanup; exit $rc' EXIT INT TERM

add_system_metrics_section() {
  local cpu mem disk load
  cpu="$(monitor_cpu_usage)"
  mem="$(monitor_memory_usage)"
  disk="$(monitor_disk_space)"
  load="$(monitor_system_load)"

  cat <<SECTION
<div class="section">
  <h2>Système</h2>
  <pre>CPU: ${cpu}
MEM: ${mem}
DISK:\n${disk}
LOAD: ${load}</pre>
</div>
SECTION
}

add_process_analysis_section() {
  local top10 zombies
  top10="$(list_top_processes)"
  zombies="$(find_zombie_processes || true)"
  cat <<SECTION
<div class="section">
  <h2>Processus</h2>
  <h3>Top consommateurs</h3>
  <pre>${top10}</pre>
  <h3>Zombies</h3>
  <pre>${zombies:-Aucun}</pre>
</div>
SECTION
}

add_service_status_section() {
  local statuses
  statuses="$(check_critical_services)"
  cat <<SECTION
<div class="section">
  <h2>Services</h2>
  <pre>${statuses}</pre>
</div>
SECTION
}

add_network_analysis_section() {
  local conn ifs ports traf
  conn="$(check_network_connectivity)"
  ifs="$(monitor_network_interfaces)"
  ports="$(check_open_ports)"
  traf="$(monitor_network_traffic)"
  cat <<SECTION
<div class="section">
  <h2>Réseau</h2>
  <h3>Connectivité</h3>
  <pre>${conn}</pre>
  <h3>Interfaces</h3>
  <pre>${ifs}</pre>
  <h3>Ports ouverts</h3>
  <pre>${ports}</pre>
  <h3>Trafic</h3>
  <pre>${traf}</pre>
</div>
SECTION
}

generate_system_report() {
  local report_file
  report_file="${REPORT_DIR}/system_report_$(date +%Y%m%d_%H%M%S).html"
  cat >"${report_file}" <<EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>SysMonitor Pro - Rapport Système</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    .header { background: #2c3e50; color: #fff; padding: 16px; }
    .section { margin: 20px 0; padding: 12px; border: 1px solid #ddd; }
    .critical { background: #e74c3c; color: #fff; }
    .warning { background: #f39c12; color: #fff; }
    .success { background: #27ae60; color: #fff; }
    pre { white-space: pre-wrap; }
  </style>
  </head>
<body>
  <div class="header">
    <h1>Rapport SysMonitor Pro</h1>
    <p>Généré le: $(date)</p>
    <p>Serveur: $(hostname)</p>
  </div>
EOF

  add_system_metrics_section >>"${report_file}"
  add_process_analysis_section >>"${report_file}"
  add_service_status_section >>"${report_file}"
  add_network_analysis_section >>"${report_file}"

  echo "</body></html>" >>"${report_file}"
  log_info "Rapport généré: ${report_file}"
}

run_system_monitoring() {
  log_info "$(monitor_cpu_usage)"
  log_info "$(monitor_memory_usage)"
  log_info $'DISK\n'"$(monitor_disk_space)"
  log_info "$(monitor_system_load)"
}

run_process_monitoring() {
  log_info $'TOP PROCS\n'"$(list_top_processes)"
  if zombies="$(find_zombie_processes)" && [[ -n "$zombies" ]]; then
    log_warning $'ZOMBIES DETECTED\n'"${zombies}"
  else
    log_info "No zombie processes detected"
  fi
}

run_service_monitoring() {
  log_info $'SERVICES\n'"$(check_critical_services)"
}

run_network_monitoring() {
  log_info $'CONNECTIVITY\n'"$(check_network_connectivity)"
  log_info $'INTERFACES\n'"$(monitor_network_interfaces)"
  log_info $'OPEN PORTS\n'"$(check_open_ports)"
}

main() {
  log_info "Starting SysMonitor Pro"
  validate_prerequisites || { log_error "Missing prerequisites"; exit 1; }
  prepare_environment

  run_system_monitoring
  run_process_monitoring
  run_service_monitoring
  run_network_monitoring

  generate_system_report
  log_info "Monitoring completed successfully"
}

main "$@"


