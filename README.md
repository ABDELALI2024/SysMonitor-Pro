# SysMonitor Pro

SysMonitor Pro is a modular Bash-based system monitoring toolkit for Linux servers. It collects CPU, memory, disk, process, service, and network metrics, logs them, and generates an HTML report.

## Features
- System monitoring: CPU, memory, disk, load
- Process management: top processes, zombie detection, critical process check
- Service checking: critical services status, restart, logs, config validation
- Network utilities: connectivity, interfaces, open ports, traffic summary
- Structured logging to `logs/sysmonitor.log`
- HTML reports in `reports/`

## Project Structure
```
SysMonitor-Pro/
├── main.sh
├── config/
│   ├── settings.conf
│   └── thresholds.conf
├── lib/
│   ├── logger.sh
│   ├── system_monitor.sh
│   ├── process_manager.sh
│   ├── service_checker.sh
│   └── network_utils.sh
├── reports/
└── logs/
```

## Requirements
- Linux with systemd tools (`systemctl`, `journalctl`)
- Standard utilities: `bash`, `ps`, `ss`/`netstat`, `ip`, `ping`, `df`, `free`, `uptime`, `logger`

## Usage
```bash
bash SysMonitor-Pro/main.sh
```
Outputs logs to `logs/` and generates an HTML report in `reports/`.

## Configuration
- `config/settings.conf`: directories, critical services list, ping target, process to monitor
- `config/thresholds.conf`: CPU/MEM/DISK/LOAD thresholds

## GitHub Setup (Quick)
1) Initialize locally and make first commit:
```bash
cd SysMonitor-Pro
git init
git add .
git commit -m "feat: initial SysMonitor-Pro implementation"
```
2) Create a new repo on GitHub (web UI or `gh repo create`).
3) Add remote and push:
```bash
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

## License
MIT (or your preferred license)


