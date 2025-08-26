# í°§ Linux Bash Scripts Collection

A collection of **Linux Bash scripts** for system administration, automation, and DevOps labs.  
Maintained by **Abdelilah LAMHAMDI**.

---
## í³‚ Repository Structure
linux-bash-scripts/
â”‚
â”œâ”€â”€ server-stats.sh      # Collects system performance stats
â”‚
â”œâ”€â”€ README.md            # Project documentation
â””â”€â”€ LICENSE              # Open-source license (MIT by default)

## í» ï¸ Requirements

Linux (any distribution)

Standard commands: awk, ps, df, uptime, who

Optional: lastb (for failed login attempts)

## í³œ License

This project is licensed under the MIT License â€“ feel free to use, share, and improve.

## í´ Contributing

Contributions are welcome!

Fork the repo

Create a feature branch

Submit a pull request
## í³Œ Project Overview
This repository contains practical scripts that can be used on any Linux server to analyze and manage system resources.  
The goal is to provide **ready-to-use**, **well-documented**, and **portable** scripts.

---

## íº€ Scripts Available

### 1. `server-stats.sh`
í´ A script to analyze **basic server performance stats**.

**Features:**
- âœ… Total CPU usage (percentage)
- âœ… Total memory usage (used vs free, percentage)
- âœ… Total disk usage (used vs free, percentage)
- âœ… Top 5 processes by CPU usage
- âœ… Top 5 processes by memory usage  
- í¾¯ *Stretch goals*: OS version, uptime, load average, logged-in users, failed login attempts

**Usage:**
```bash
chmod +x server-stats.sh
./server-stats.sh

