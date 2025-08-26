#!/usr/bin/env bash
# server-stats.sh
# Author: Abdelilah LAMHAMDI
# Description: Basic server performance stats (CPU, memory, disk, top processes) + extras
# Usage: chmod +x server-stats.sh && ./server-stats.sh

set -euo pipefail
export LC_ALL=C

hr() { printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '-'; }
title() { printf "\n%s\n" "$1"; hr; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# ---------- CPU (total %) ----------
cpu_total_usage() {
  # Read needed fields from /proc/stat twice and compute usage %
  # Fields: user nice system idle iowait irq softirq steal
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  idle1=$((idle + iowait))
  nonidle1=$((user + nice + system + irq + softirq + steal))
  total1=$((idle1 + nonidle1))
  sleep 1
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  idle2=$((idle + iowait))
  nonidle2=$((user + nice + system + irq + softirq + steal))
  total2=$((idle2 + nonidle2))
  totald=$((total2 - total1))
  idled=$((idle2 - idle1))
  if [ "$totald" -gt 0 ]; then
    awk -v totald="$totald" -v idled="$idled" 'BEGIN {printf "%.2f", (totald - idled) * 100 / totald}'
  else
    printf "0.00"
  fi
}

# ---------- Memory (Used/Free/%) ----------
mem_stats() {
  # Prefer /proc/meminfo (portable)
  total_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
  avail_kb=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
  used_kb=$((total_kb - avail_kb))
  pct=$(awk -v u="$used_kb" -v t="$total_kb" 'BEGIN {printf "%.2f", (u*100)/t}')

  humanize() {
    # arg: KiB integer
    awk -v k="$1" 'BEGIN {
      v=k*1024; split("B KB MB GB TB PB",u," "); i=1;
      while (v>=1024 && i<6){v/=1024;i++}
      printf "%.2f %s", v, u[i]
    }'
  }

  printf "%s used / %s total (%s%%)\n" "$(humanize "$used_kb")" "$(humanize "$total_kb")" "$pct"
}

# ---------- Disk (aggregate Used/Free/%) ----------
disk_stats() {
  if has_cmd df; then
    df -P -B1 | awk '
      NR>1 && $1 !~ /^(tmpfs|devtmpfs|squashfs|overlay|ramfs)$/ {
        total+=$2; used+=$3
      }
      END {
        if (total>0) {
          pct=used*100/total
          hum = function(x){
            split("B KB MB GB TB PB",u," "); i=1;
            while (x>=1024 && i<6){x/=1024;i++}
            return sprintf("%.2f %s", x, u[i])
          }
          printf "%s used / %s total (%.2f%%)\n", hum(used), hum(total), pct
        } else {
          print "N/A"
        }
      }'
  else
    printf "df not found\n"
  fi
}

# ---------- Top processes ----------
top_cpu() {
  if has_cmd ps; then
    printf "PID   COMMAND               %%CPU   %%MEM\n"
    # Skip header, print top 5
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | awk 'NR==1{next} NR<=6 {printf "%-5s %-20s %5s %6s\n",$1,$2,$3,$4}'
  else
    printf "ps not found\n"
  fi
}

top_mem() {
  if has_cmd ps; then
    printf "PID   COMMAND               %%MEM   %%CPU\n"
    ps -eo pid,comm,%mem,%cpu --sort=-%mem | awk 'NR==1{next} NR<=6 {printf "%-5s %-20s %5s %6s\n",$1,$2,$3,$4}'
  else
    printf "ps not found\n"
  fi
}

# ---------- Stretch: OS, kernel, uptime, load, users, failed logins ----------
os_info() {
  if [ -r /etc/os-release ]; then
    pretty=$(awk -F= '/^PRETTY_NAME=/{gsub(/"/,"",$2);print $2}' /etc/os-release)
    printf "%s (kernel %s)\n" "${pretty:-Unknown}" "$(uname -r)"
  else
    printf "%s\n" "$(uname -srm)"
  fi
}

uptime_human() {
  if has_cmd uptime && uptime -p >/dev/null 2>&1; then
    # Run once, strip leading "up "
    up=$(uptime -p 2>/dev/null || true)
    printf "%s\n" "${up#up }"
  elif [ -r /proc/uptime ]; then
    awk '{printf "%.2f hours\n", $1/3600}' /proc/uptime
  else
    printf "N/A\n"
  fi
}

load_avg() {
  if [ -r /proc/loadavg ]; then
    awk '{printf "%s (1m)  %s (5m)  %s (15m)\n",$1,$2,$3}' /proc/loadavg
  else
    printf "N/A\n"
  fi
}

logged_in_users() {
  if has_cmd who; then
    count=$(who | wc -l | tr -d ' ')
    printf "%s user(s) logged in\n" "$count"
  else
    printf "N/A\n"
  fi
}

failed_logins() {
  if has_cmd lastb && [ -r /var/log/btmp ]; then
    printf "Recent failed logins (last 5):\n"
    # lastb may exit non-zero if empty; ignore with || true
    lastb -n 5 2>/dev/null || true
  else
    printf "Failed login info: N/A (no lastb or no access to /var/log/btmp)\n"
  fi
}

# ---------- Print Report ----------
title "SERVER STATS - $(hostname) - $(date '+%Y-%m-%d %H:%M:%S %Z')"

title "Total CPU Usage"
printf "%s%%\n" "$(cpu_total_usage)"

title "Total Memory Usage"
mem_stats

title "Total Disk Usage"
disk_stats

title "Top 5 Processes by CPU"
top_cpu

title "Top 5 Processes by Memory"
top_mem

title "Extra Info"
printf "OS: "; os_info
printf "Uptime: "; uptime_human
printf "Load Average: "; load_avg
printf "Users: "; logged_in_users
failed_logins

