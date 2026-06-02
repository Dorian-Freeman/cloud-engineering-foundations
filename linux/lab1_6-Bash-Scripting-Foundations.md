# Lab 1.6 — Bash Scripting Foundations

## Environment

Platform: Linode Ubuntu instance  
Shell User: root  
Working Directory: `/root/labs/lab1-6`  
Script Location in GitHub: `linux/scripts/system_check_health.sh`


## Goals

- Understand basic Bash scripting structure
- Create a reusable system health check script
- Practice file permissions for scripts
- Run and debug a Bash script
- Use variables
- Use command substitution
- Use pipes and filters
- Add basic alert logic with `if/else`
- Document and commit the script to GitHub


## Why Bash Matters

Bash scripting allows Linux commands to be packaged into repeatable automation.

Instead of manually running commands one by one, a script allows an engineer to:

```text
write commands once
run one file
collect system information
check service status
detect problems
document repeatable troubleshooting
```

Cloud engineers use scripts for tasks such as:

```text
system checks
server setup
log collection
service checks
disk alerts
automation workflows
deployment helpers
troubleshooting reports
```


## Creating the Lab Directory

Commands:

```bash
cd /root
mkdir -p labs/lab1-6
cd labs/lab1-6
pwd
```

Observed:

```text
/root/labs/lab1-6
```

Understanding:

```text
mkdir -p = create parent folders if needed
cd       = change directory
pwd      = print current working directory
```


## Creating the Script File

Command:

```bash
nano system_check_health.sh
```

Understanding:

`nano` is a terminal text editor.

Mental Model:

```text
nano = terminal Notepad
```

The script was created as:

```text
system_check_health.sh
```



## Script Header

The script begins with:

```bash
#!/bin/bash
```

Understanding:

```text
#!/bin/bash = use the Bash interpreter to run this script
```

This line is called the **shebang**.

Mental Model:

```text
This file should be executed with Bash.
```


## Comments

Example:

```bash
# File: system_check_health.sh
# Purpose: Check basic system health metrics
```

Understanding:

Lines beginning with `#` are comments.

They are ignored by Bash and used to explain the script.


## Safe Bash Settings

Line used:

```bash
set -euo pipefail
```

Understanding:

```text
-e = stop script if a command fails
-u = error on undefined variables
-o pipefail = detect failures inside pipelines
```

Mental Model:

```text
Fail early instead of silently continuing with broken logic.
```


## Printing Text — `echo`

Example:

```bash
echo "=== System Health Check ==="
```

Understanding:

```text
echo = print text to the terminal
```

This was used to create readable sections in the script.


## Command Substitution — `$()`

Example:

```bash
echo "Date: $(date)"
```

Understanding:

```text
$(date) = run the date command and insert its output here
```

Mental Model:

```text
$(command) = run this command first, then place the result here
```


## Host Info Section

Script section:

```bash
echo ""
echo "--- Host Info ---"
hostname
whoami
pwd
```

Purpose:

Show basic information about the machine and current shell context.

Commands:

```text
hostname = show machine name
whoami   = show current user
pwd      = show current working directory
```

Observed output:

```text
localhost
root
/root/labs/lab1-6
```


## CPU and Memory Section

Script section:

```bash
echo "--- CPU & Memory ---"
echo "Load average: $(uptime | awk '{print $NF}')"
echo "Memory usage:"
free -h | grep Mem
```

Understanding:

```text
uptime = shows how long the system has been running and load average
awk '{print $NF}' = prints the last field
free -h = shows memory usage in human-readable format
grep Mem = filters output to the memory line
```

Mental Model:

```text
Show the current system load and memory usage.
```


## Disk Usage Section

Script section:

```bash
echo "--- Disk Usage ---"
df -h | grep -v tmpfs
```

Understanding:

```text
df -h = show filesystem disk usage in human-readable format
grep -v tmpfs = exclude lines containing tmpfs
```

Observed root disk usage:

```text
/dev/sda 25G 2.4G 21G 11% /
```

Mental Model:

```text
How full is my server disk?
```


## Top Processes Section

Script section:

```bash
echo "--- Top 5 Processes by CPU ---"
ps aux --sort=-%cpu | head -6
```

Understanding:

```text
ps aux = snapshot of running processes
--sort=-%cpu = sort by CPU usage highest first
head -6 = show first 6 lines
```

Why `head -6`?

```text
Line 1 is the header
Lines 2-6 are the top 5 processes
```

Mental Model:

```text
Which processes are using the most CPU right now?
```


## Listening Services Section

Script section:

```bash
echo "--- Listening Services ---"
ss -tulpn | grep LISTEN
```

Understanding:

```text
ss -tulpn = show TCP/UDP listening ports and owning processes
grep LISTEN = filter for listening services
```

Observed services included:

```text
22 = SSH
53 = DNS resolver
```

Mental Model:

```text
What services are waiting for network connections?
```


## File Permissions Before Execution

Initial permission:

```text
-rw-r--r--
```

Understanding:

```text
-   = regular file
rw- = owner can read/write
r-- = group can read
r-- = others can read
```

Problem:

```text
No execute permission existed yet.
```

That means the script could not be run directly as a program.


## Adding Execute Permission

Command:

```bash
chmod +x system_check_health.sh
```

Result:

```text
-rwxr-xr-x
```

Understanding:

```text
x = execute permission
```

This allowed the script to be run with:

```bash
./system_check_health.sh
```


## Tightening Permissions

For better security, permissions were changed to:

```bash
chmod 744 system_check_health.sh
```

Result:

```text
-rwxr--r--
```

Understanding:

```text
owner = read/write/execute
group = read only
others = read only
```

Reason:

```text
Only the owner should execute the script.
Group and others can read but not run it.
```


## Running the Script

Command:

```bash
./system_check_health.sh
```

The script successfully printed:

```text
System date/time
Host info
CPU/load average
Memory usage
Disk usage
Top CPU processes
Listening services
SSH status
Disk alert check
Service alert check
```


## SSH Service Status Check

First version:

```bash
echo "--- SSH Service Status ---"
systemctl is-active ssh
```

Observed:

```text
active
```

Understanding:

```text
systemctl is-active ssh = check whether SSH service is currently active
```


## Service Alert Check

Improved version:

```bash
echo ""
echo "--- Service Alert Check ---"

SERVICE="ssh"
SERVICE_STATUS=$(systemctl is-active "$SERVICE")

if [ "$SERVICE_STATUS" = "active" ]; then
    echo "$SERVICE is running"
else
    echo "WARNING: $SERVICE is not running"
fi
```

Understanding:

```text
SERVICE = variable storing the service name
SERVICE_STATUS = output of systemctl is-active ssh
```

The `if/else` logic checks whether the service is active.

Observed:

```text
ssh is running
```

Mental Model:

```text
If SSH is active, report OK.
Otherwise, print a warning.
```


## Disk Alert Check

Script section:

```bash
echo ""
echo "--- Disk Alert Check ---"

DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

echo "Root disk usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 80 ]; then
    echo "WARNING: Disk usage is above 80%"
else
    echo "Disk usage is OK"
fi
```

Understanding:

```text
df / = check root filesystem usage
tail -1 = select the disk line, not the header
awk '{print $5}' = select the Use% column
sed 's/%//' = remove the percent sign
```

Example:

```text
11% becomes 11
```

This is needed because Bash cannot compare `11%` as an integer.


## Debugging Error

Initial error:

```text
integer expression expected
```

Cause:

```text
The variable still contained the % symbol.
```

Example problem:

```text
11%
```

Bash expected a number like:

```text
11
```

Fix:

```bash
sed 's/%//'
```

Final clean output:

```text
Root disk usage: 11%
Disk usage is OK
```


## If/Else Logic

Example:

```bash
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "WARNING: Disk usage is above 80%"
else
    echo "Disk usage is OK"
fi
```

Understanding:

```text
if = start condition
then = what to do if condition is true
else = what to do if condition is false
fi = end if block
```

Comparison:

```text
-gt = greater than
```

Mental Model:

```text
If disk usage is greater than 80, warn me.
Otherwise, tell me disk usage is OK.
```


## Variables

Examples:

```bash
SERVICE="ssh"
SERVICE_STATUS=$(systemctl is-active "$SERVICE")
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
```

Understanding:

Variables store values for reuse.

Mental Model:

```text
variable = named container for a value
```


## Pipes Used

Examples:

```bash
free -h | grep Mem
df -h | grep -v tmpfs
ps aux --sort=-%cpu | head -6
ss -tulpn | grep LISTEN
df / | tail -1 | awk '{print $5}' | sed 's/%//'
```

Understanding:

```text
| = take output from the command on the left and send it into the command on the right
```

Mental Model:

```text
command output flows through filters step by step
```


## Final Script Capabilities

The script checks:

```text
Date/time
Hostname
Current user
Current directory
Load average
Memory usage
Disk usage
Top CPU processes
Listening network services
SSH service health
Root disk warning threshold
```


## Final Script Location

The script was added to GitHub at:

```text
linux/scripts/system_check_health.sh
```

The lab documentation was added at:

```text
linux/lab1_6-Bash-Scripting-Foundations.md
```


## GitHub Commit Plan

Files to commit:

```text
linux/scripts/system_check_health.sh
linux/lab1_6-Bash-Scripting-Foundations.md
```

Suggested commit message:

```text
Add Lab 1.6 Bash scripting foundations
```


## Cloud Engineering Connection

This lab connects directly to cloud engineering because Bash scripts are used to automate Linux server work.

Examples:

```text
health checks
disk monitoring
service checks
log collection
server setup
deployment tasks
security checks
troubleshooting reports
```

A cloud engineer may use a script like this to quickly inspect a VM, EC2 instance, or Linux server.


## Key Commands Practiced

```bash
nano system_check_health.sh
chmod +x system_check_health.sh
chmod 744 system_check_health.sh
ls -l
./system_check_health.sh
cat system_check_health.sh
hostname
whoami
pwd
uptime
free -h
df -h
ps aux
ss -tulpn
systemctl is-active ssh
```


## Important Lessons

- Bash scripts automate repeatable Linux commands
- `#!/bin/bash` tells Linux to run the file with Bash
- `echo` prints text
- `$()` runs a command and inserts the result
- `chmod +x` makes a script executable
- `chmod 744` lets only the owner execute the script
- Pipes send command output into other commands
- Variables store reusable values
- `if/else` allows scripts to make decisions
- Debugging Bash often means checking variable output
- Removing `%` was required before comparing disk usage as a number


## Reflection

Biggest Concepts Learned:

```text
Bash script structure
file execution permissions
command substitution
variables
pipes
filters
if/else logic
integer comparison
basic alert checks
script debugging
```

Key Learning Pattern:

```text
Write script
→ Run script
→ Observe output
→ Find error
→ Fix logic
→ Run again
→ Improve script
→ Document
→ Commit
```

Automation Mental Model:

```text
Commands become scripts.
Scripts become tools.
Tools become repeatable cloud workflows.
```