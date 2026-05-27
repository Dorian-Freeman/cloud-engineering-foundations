# Lab 1.3 — Processes, Services & System State

## Environment

Platform: Linode Ubuntu instance  
Shell User: root  
Hostname: localhost


## Goals

- Understand Linux processes
- Learn live system monitoring
- Learn network/service visibility
- Understand system services
- Practice Linux troubleshooting workflow


## Processes

### Process Concept

Understanding:

A process is:

```text
A running instance of a program
```

Examples:

```text
bash shell
ssh service
nginx
top
```


## Process Snapshot — ps aux

Command:

```bash
ps aux
```

Purpose:

Display a snapshot of running system processes.

Observed Columns:

```text
USER
PID
%CPU
%MEM
COMMAND
```

Understanding:

```text
USER = owner of process
PID = Process ID
%CPU = processor usage
%MEM = memory usage
COMMAND = program/executable running
```

Mental Model:

```text
ps aux = Linux process photograph / snapshot
```


## Pipes & Filtering

Command:

```bash
ps aux | grep bash
```

Understanding:

### Pipe

```text
| = pipe
```

Meaning:

Pass output from one command into another command.

### grep

```text
grep = search/filter text
```

Meaning:

Filter results for matching text.

Translation:

```text
Show all processes
↓
filter only bash-related lines
```

Observed:

```text
-bash
grep --color=auto bash
```

Interesting Behavior:

`grep` found itself because the command itself contains the word:

```text
bash
```


## Live System Monitoring — top

Command:

```bash
top
```

Purpose:

Real-time live process monitoring.

Observed:

```text
running tasks
sleeping tasks
CPU usage
memory usage
live updating interface
```

Mental Model:

```text
ps aux = snapshot

top = live dashboard
```

Use Cases:

```text
high CPU troubleshooting
memory investigation
resource monitoring
performance debugging
```


## Network Visibility — ss -tulpn

Command:

```bash
ss -tulpn
```

Purpose:

Display active network sockets and listening services.

Flag Breakdown:

```text
t = TCP
u = UDP
l = listening
p = processes
n = numeric ports
```

Observed:

```text
SSH port 22
UDP 53
systemd-resolved
sshd
```

Understanding:

Show:

```text
ports
services
network listeners
owning processes
```


## TCP vs UDP Concepts

### TCP

Mental Model:

```text
connection-oriented
handshake
reliable communication
stateful session
```

Example:

```text
SSH
```

Use Case:

Interactive Linux server login sessions.


### UDP

Mental Model:

```text
connectionless
quick request/response
lightweight communication
```

Example:

```text
DNS queries
UDP 53
```

Observed State:

```text
UNCONN
```

Meaning:

Connectionless / no established session.


## Linux Services — systemctl

Command:

```bash
systemctl status ssh
```

Purpose:

Check current service state/health.

Observed:

```text
Active: running
Main PID: 830 (sshd)
logs/messages
```

Understanding:

```text
systemctl = system/service manager control
```

Used for:

```text
status
start
stop
restart
```

Mental Model:

Manage Linux services.


## Service Control Concepts

### Start Service

Command:

```bash
systemctl start nginx
```

Purpose:

Start nginx service.


### Stop Service

Command:

```bash
systemctl stop ssh
```

Concept:

Stop SSH service.

Cloud/Sysadmin Warning:

Stopping SSH remotely can terminate remote access.


### Restart Service

Command:

```bash
systemctl restart ssh
```

Concept:

Restart service.

Potentially risky on remote systems.


## Logs — journalctl

Command:

```bash
journalctl -u ssh -n 10
```

Flag Breakdown:

```text
-u ssh = filter SSH service logs
-n 10 = show last 10 log entries
```

Purpose:

Display recent service logs.

Use Cases:

```text
authentication investigation
service failures
startup problems
debugging
```

Mental Model:

Logs tell the system story.


## Linux Troubleshooting Workflow

Scenario:

```text
Website down
Suspect nginx
```

Workflow:

### Check Service Health

```bash
systemctl status nginx
```

Question:

```text
Is nginx running?
```


### Start Service if Needed

```bash
systemctl start nginx
```

Question:

```text
Can the service be started?
```


### Verify Service Status

```bash
systemctl status nginx
```

Question:

```text
Did the service successfully start?
```


### Verify Network Listening State

Command:

```bash
ss -tulpn
```

Question:

```text
Is nginx listening on 80/443?
```


### Investigate Logs

Command:

```bash
journalctl -u nginx
```

Question:

```text
What do the logs reveal?
```


## Cloud / Sysadmin Connection

Concepts Practiced:

```text
process monitoring
service management
network troubleshooting
system health checks
logging
resource visibility
```

Cloud Connections:

```text
Linux administration
Cloud troubleshooting
EC2 management
production debugging
service monitoring
network diagnostics
```


## Reflection

Biggest Concepts Learned:

- Process monitoring
- Snapshot vs live monitoring
- Pipes and filtering
- TCP vs UDP thinking
- Network listening visibility
- Service management
- Logging workflow
- Troubleshooting mindset

Key Learning Pattern:

```text
Predict
→ Run Command
→ Observe Output
→ Explain
→ Document
```