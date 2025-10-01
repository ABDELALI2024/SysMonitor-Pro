#!/usr/bin/env bash

monitor_cpu_usage() {
  local usage
  usage=$(LC_ALL=C top -bn1 | awk '/Cpu\(s\)/{print 100 - $8}' 2>/dev/null || true)
  if [[ -z "${usage}" ]]; then
    usage=$(awk -v OFS="," '/cpu /{idle=$5; total=$2+$3+$4+$5+$6+$7+$8; if (prev_total){print (1-((idle-prev_idle)/(total-prev_total)))*100}; prev_total=total; prev_idle=idle}' /proc/stat | tail -n1)
  fi
  usage=${usage%.*}
  local level="OK"
  if (( usage >= ${CPU_CRIT:-90} )); then level="CRITICAL"; elif (( usage >= ${CPU_WARN:-70} )); then level="WARNING"; fi
  echo "CPU ${usage}% (${level})"
}

monitor_memory_usage() {
  local total used percent
  read -r _ total _ < <(grep -m1 MemTotal /proc/meminfo)
  read -r _ used _ < <(grep -m1 MemAvailable /proc/meminfo)
  total=$(( total / 1024 ))
  used=$(( total - (used / 1024) ))
  percent=$(( used * 100 / total ))
  local level="OK"
  if (( percent >= ${MEM_CRIT:-90} )); then level="CRITICAL"; elif (( percent >= ${MEM_WARN:-75} )); then level="WARNING"; fi
  echo "MEM ${used}MiB/${total}MiB (${percent}%) (${level})"
}

monitor_disk_space() {
  df -hP | awk 'NR==1 || $1 ~ /^\/dev\// {printf "%s %s %s %s %s\n", $1, $6, $2, $3, $5}'
}

monitor_system_load() {
  local cores load1 load5 load15
  cores=$(getconf _NPROCESSORS_ONLN)
  read -r load1 load5 load15 _ < <(awk '{print $1, $2, $3}' /proc/loadavg)
  local warn=$(( cores * ${LOAD_WARN_FACTOR:-1} ))
  local crit=$(( cores * ${LOAD_CRIT_FACTOR:-2} ))
  local level="OK"
  local load_int=${load1%.*}
  if (( load_int >= crit )); then level="CRITICAL"; elif (( load_int >= warn )); then level="WARNING"; fi
  echo "LOAD ${load1}, ${load5}, ${load15} (cores=${cores}) (${level})"
}


