# Linux Bash Scripts Collection

A collection of **Linux Bash scripts** for system administration, automation, and DevOps labs.  
Maintained by **Abdelilah LAMHAMDI**.

---
## Repository Structure
linux-bash-scripts/
│
├── server-stats.sh      # Collects system performance stats
│
├── README.md            # Project documentation
└── LICENSE              # Open-source license (MIT by default)

## Requirements

Linux (any distribution)

Standard commands: awk, ps, df, uptime, who

Optional: lastb (for failed login attempts)

## License

This project is licensed under the MIT License – feel free to use, share, and improve.

## Contributing

Contributions are welcome!

Fork the repo

Create a feature branch

Submit a pull request
## Project Overview
This repository contains practical scripts that can be used on any Linux server to analyze and manage system resources.  
The goal is to provide **ready-to-use**, **well-documented**, and **portable** scripts.

---

## Scripts Available

### 1. `server-stats.sh`
A script to analyze **basic server performance stats**.

**Features:**
- ✅ Total CPU usage (percentage)
- ✅ Total memory usage (used vs free, percentage)
- ✅ Total disk usage (used vs free, percentage)
- ✅ Top 5 processes by CPU usage
- ✅ Top 5 processes by memory usage  
- *Stretch goals*: OS version, uptime, load average, logged-in users, failed login attempts

**Usage:**
```bash
chmod +x server-stats.sh
./server-stats.sh

