# Linux Foundations

This section documents my Linux, Git, Bash, and troubleshooting foundation for cloud engineering.

The goal of this section is to build hands-on comfort with Linux systems, command-line workflows, permissions, services, networking tools, automation, Git version control, and real troubleshooting scenarios.


## Focus Areas

* Linux filesystem navigation
* File and directory permissions
* Users, groups, and ownership
* Process inspection
* Service management with `systemctl`
* Log review with `journalctl`
* Linux networking tools
* Git and GitHub workflow
* Bash scripting fundamentals
* SSH troubleshooting and recovery


## Labs

### Lab 1.1 — Filesystem and Navigation

File:

```text
lab1-filesystem-notes.md
```

Summary:

Practiced navigating the Linux filesystem, understanding `/`, `/root`, `/home`, `/etc`, and using core commands such as:

```bash
pwd
ls
cd
mkdir
touch
cat
rm
```


### Lab 1.2 — Permissions and Users

File:

```text
lab1_2-Permissions-Drill.md
```

Summary:

Practiced Linux file permissions, ownership, users, groups, and service-style account concepts.

Key commands:

```bash
chmod
chown
useradd
id
ls -l
```

Key concepts:

```text
owner
group
others
read/write/execute
service accounts
permission hardening
```


### Lab 1.3 — Processes, Services, and System State

File:

```text
lab1_3-Processes-Services-SystemState.md
```

Summary:

Practiced inspecting processes, checking services, reading logs, and understanding system state.

Key commands:

```bash
ps aux
top
grep
systemctl status
systemctl restart
journalctl
```


### Lab 1.4 — Networking Tools: Linux Side

File:

```text
lab1_4-Networking-Tools-Linux-Side.md
```

Summary:

Practiced Linux networking diagnostics including IP addresses, routes, DNS, web connectivity, port checks, traceroute, and listening services.

Key commands:

```bash
ip a
ip route
ping
dig
nslookup
curl -v
wget
traceroute
ss -tulpn
```

Key concepts:

```text
IP addressing
default gateway
DNS troubleshooting
HTTP/HTTPS testing
port 443 reachability
listening services
network path tracing
```


### Lab 1.5 — Git and GitHub CLI Workflow

File:

```text
lab1_5-Git-and-GitHub-CLI-Workflow.md
```

Summary:

Practiced using Git from the command line and connecting Git CLI concepts to GitHub Desktop.

Key commands:

```bash
git status
git log --oneline
git add
git commit -m
git push origin main
git pull origin main
git diff
```

Key concepts:

```text
working directory
staging area
commit history
origin/main
push
pull
clean working tree
```


### Lab 1.6 — Bash Scripting Foundations

File:

```text
lab1_6-Bash-Scripting-Foundations.md
```

Script:

```text
scripts/system_check_health.sh
```

Summary:

Created a Bash system health check script that reports host info, CPU/load, memory, disk usage, top processes, listening services, SSH service status, and disk alert checks.

Key concepts:

```text
shebang
echo
variables
command substitution
pipes
if/else logic
chmod permissions
script debugging
```


### Lab 1.7 — Review and Troubleshooting Simulation

File:

```text
lab1_7-Review-and-Troubleshooting-Simulation.md
```

Summary:

Completed a broken SSH troubleshooting simulation by safely stopping `ssh.socket` and `ssh.service`, observing connection refusal, diagnosing port 22 behavior, restoring SSH access, and verifying recovery through service status, port checks, successful login, and logs.

Key commands:

```bash
systemctl status ssh
systemctl status ssh.socket
systemctl stop ssh.socket
systemctl stop ssh
systemctl start ssh.socket
systemctl start ssh
ss -tulpn | grep ':22'
journalctl -u ssh -n 20
ssh root@SERVER_IP
```

Key concepts:

```text
connection refused
service vs socket
port listener diagnosis
safe recovery through console access
SSH logs
incident-style troubleshooting
```


## Scripts

### System Health Check Script

Path:

```text
scripts/system_check_health.sh
```

Purpose:

A basic Bash automation script for checking Linux server health.

Checks:

```text
date/time
hostname
current user
current directory
load average
memory usage
disk usage
top CPU processes
listening services
SSH service health
disk usage alert threshold
```


## Week 1 Outcome

By the end of this section, I practiced:

```text
Linux navigation
permissions
users and ownership
processes and services
logs
network troubleshooting
Git and GitHub workflow
Bash scripting
SSH break/fix troubleshooting
technical documentation
```

This section represents my junior Linux administrator / cloud support foundation.


## Cloud Engineering Connection

Linux is the foundation for cloud engineering because many cloud workloads run on Linux servers.

These labs connect directly to cloud tasks such as:

```text
SSH access
server administration
service troubleshooting
log review
firewall and port diagnostics
automation scripting
Git-based documentation
incident response
```


## Key Mental Models

```text
Check the service.
Check the port.
Check the logs.
Verify the fix.
Document the work.
```

```text
Commands become scripts.
Scripts become tools.
Tools become repeatable cloud workflows.
```

```text
Do not guess.
Observe, test, narrow down, fix, verify, document.
```
