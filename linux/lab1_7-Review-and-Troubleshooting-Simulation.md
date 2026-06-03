# Lab 1.7 — Review and Troubleshooting Simulation

## Environment

Platform: Linode Ubuntu instance
Shell User: root
Server IP: `172.232.162.42`
Primary Service Tested: SSH
SSH Port: `22`
Access Methods Used:

```text
Normal SSH session
Linode LISH/Web Console
```


## Goals

* Review key Linux, permissions, networking, and troubleshooting concepts
* Practice thinking through a broken SSH scenario
* Establish a healthy baseline before breaking anything
* Safely simulate SSH failure
* Diagnose why SSH stopped accepting connections
* Understand `ssh.service` vs `ssh.socket`
* Restore SSH access
* Verify recovery with service status, listening ports, SSH login, and logs
* Document the full incident-style workflow


## Review Quiz

### 1. What does `chmod 644 file.txt` mean?

Answer:

```text
Owner  = read/write
Group  = read only
Others = read only
```

Permission breakdown:

```text
6 = read + write
4 = read
4 = read
```

So:

```text
chmod 644 = owner can modify the file, everyone else can only read it
```


### 2. What command shows which process is listening on port 80?

Base command:

```bash
ss -tulpn
```

More targeted command:

```bash
ss -tulpn | grep ':80'
```

Understanding:

```text
ss -tulpn = show TCP/UDP listening ports and owning processes
grep ':80' = filter for port 80
```


### 3. What is the difference between `kill -15` and `kill -9`?

```bash
kill -15 <PID>
```

Meaning:

```text
Polite shutdown request
Ask the process to terminate gracefully
```

```bash
kill -9 <PID>
```

Meaning:

```text
Force kill
Terminate immediately
```

Mental model:

```text
Try kill -15 first.
Use kill -9 only when the process refuses to stop.
```


### 4. If `ping google.com` fails but `ping 8.8.8.8` works, what is the likely problem?

Answer:

```text
DNS problem
```

Reason:

```text
ping 8.8.8.8 works = IP connectivity works
ping google.com fails = hostname resolution likely failed
```


### 5. What does `tail -f /var/log/syslog` do?

Command:

```bash
tail -f /var/log/syslog
```

Meaning:

```text
Live-follow the system log
```

Use case:

```text
Debugging active system events
Watching logs while restarting services
Monitoring errors as they happen
```

Mental model:

```text
tail -f = watch the log in real time
```


## Troubleshooting Scenario

Scenario:

```text
Trying to SSH into the Linode server returns:
Connection refused
```

Important interpretation:

```text
Connection refused usually means the server is reachable,
but nothing is accepting connections on that target port.
```

For SSH, that means port `22` may not be listening.

Possible causes:

```text
ssh.service is stopped
ssh.socket is stopped
SSH is not listening on port 22
Firewall is rejecting port 22
SSH configuration is broken
```


## Safety Rule

Before intentionally breaking SSH, a backup access method must be available.

Backup method used:

```text
Linode LISH/Web Console
```

Reason:

```text
If SSH breaks, LISH still allows access to the server console.
```

Important rule:

```text
Do not intentionally break SSH unless you have a recovery path.
```


## Healthy Baseline

Before breaking anything, the system was checked in its healthy state.

### Check SSH Service

Command:

```bash
systemctl status ssh
```

Healthy result:

```text
ssh.service active/running
```

Meaning:

```text
SSH service is running
```


### Check Port 22

Command:

```bash
ss -tulpn | grep ':22'
```

Healthy result showed:

```text
0.0.0.0:22
[::]:22
```

Meaning:

```text
SSH is listening on IPv4 and IPv6
```


### Check SSH Logs

Command:

```bash
journalctl -u ssh -n 10
```

Observed healthy log activity included:

```text
Accepted password for root
pam_unix(sshd:session): session opened for user root
```

Meaning:

```text
SSH login worked
A root session opened successfully
```


## Important Discovery: `ssh.service` vs `ssh.socket`

When trying to stop SSH with:

```bash
systemctl stop ssh
```

the system warned:

```text
Stopping 'ssh.service', but its triggering units are still active:
ssh.socket
```

Understanding:

```text
ssh.service = actual SSH daemon/service
ssh.socket  = systemd socket listening on port 22
```

Mental model:

```text
ssh.socket = front desk still answering the door
ssh.service = worker that handles the SSH session
```

If `ssh.socket` stays active, it can trigger SSH service again when a connection comes in.


## Checking the SSH Socket

Command:

```bash
systemctl status ssh.socket
```

Observed:

```text
ssh.socket active/running
Listen: 0.0.0.0:22
Listen: [::]:22
Triggers: ssh.service
```

Meaning:

```text
The socket was still listening on port 22
The socket can trigger ssh.service
```

This explained why stopping only `ssh.service` did not fully remove port 22.


## Controlled Break Simulation

To create a real SSH failure, both the socket and service were stopped from the LISH console.

Commands:

```bash
systemctl stop ssh.socket
systemctl stop ssh
ss -tulpn | grep ':22'
```

Observed result:

```text
No output
```

Understanding:

```text
No output from grep means no line matched ':22'
No match means nothing is listening on port 22
```

Important lesson:

```text
No output does not always mean the command failed.
Sometimes no output is the expected diagnostic result.
```

In this case:

```text
No output = SSH is no longer listening on port 22
```


## Broken SSH Symptom

From a normal SSH attempt, the connection failed with:

```text
ssh: connect to host 172.232.162.42 port 22: Connection refused
```

Meaning:

```text
The server was reachable,
but port 22 was not accepting connections.
```

Root cause:

```text
ssh.socket and ssh.service were stopped,
so nothing was listening on port 22.
```


## Recovery Steps

From the Linode LISH console, SSH access was restored.

Commands:

```bash
systemctl start ssh.socket
systemctl start ssh
ss -tulpn | grep ':22'
systemctl status ssh
```

Expected/observed result:

```text
Port 22 appeared again
ssh.service returned to active/running
```

Listening port result included:

```text
0.0.0.0:22
[::]:22
```

Meaning:

```text
SSH is listening again on IPv4 and IPv6
```


## Verifying SSH Recovery

After restarting the socket and service, SSH was tested again.

Command:

```bash
ssh root@172.232.162.42
```

Observed:

```text
SSH connected successfully
Password login worked
Ubuntu login banner appeared
Root shell restored
```

Meaning:

```text
Remote SSH access was restored
```


## Host Key Prompt

During reconnect, SSH asked:

```text
The authenticity of host '172.232.162.42' can't be established.
Are you sure you want to continue connecting?
```

First response:

```text
N
```

Result:

```text
Host key verification failed
```

Second response:

```text
yes
```

Result:

```text
Host key was accepted and added to known_hosts
```

Understanding:

```text
Typing yes trusts the server host key and stores it locally
```


## Verifying with Logs

Command:

```bash
journalctl -u ssh -n 20
```

Important successful log lines:

```text
Accepted password for root from 172.232.162.42
pam_unix(sshd:session): session opened for user root
```

Meaning:

```text
SSH accepted the login
A session opened successfully
Remote access was restored
```


## SSH Log Noise

Other log lines showed failed or aborted connection attempts, such as:

```text
Disconnected from authenticating user root
Connection closed by ...
kex_exchange_identification: read: Connection reset by peer
```

Understanding:

```text
Public SSH servers often receive random login attempts from the internet
```

Security note:

```text
Public SSH on port 22 attracts noise and bots
```

Future hardening topics:

```text
SSH keys
Disable root password login
Create non-root sudo user
Firewall allowlist
Fail2ban
Restrict SSH exposure
```


## Final Troubleshooting Flow

The full incident flow:

```text
Healthy baseline
→ Stop ssh.socket and ssh.service
→ Confirm port 22 disappeared
→ Observe SSH connection refused
→ Restart ssh.socket and ssh.service
→ Confirm port 22 returned
→ SSH login successful
→ Logs confirmed session opened
```


## Key Commands Practiced

```bash
systemctl status ssh
systemctl status ssh.socket
systemctl stop ssh
systemctl stop ssh.socket
systemctl start ssh.socket
systemctl start ssh
ss -tulpn | grep ':22'
journalctl -u ssh -n 10
journalctl -u ssh -n 20
ssh root@172.232.162.42
```


## Troubleshooting Mental Model

For SSH connection problems:

```text
Can I reach the server?
Is port 22 listening?
Is ssh.service running?
Is ssh.socket active?
What do the logs say?
Is the firewall allowing port 22?
Can I recover through console access?
```

For `Connection refused`:

```text
Server may be reachable,
but nothing is listening on the target port.
```

For no output from:

```bash
ss -tulpn | grep ':22'
```

Meaning:

```text
No service is listening on port 22
```


## Cloud Engineering Connection

This lab connects directly to cloud engineering and cloud support work.

Cloud engineers often troubleshoot:

```text
SSH failures
service outages
firewall issues
port/listener problems
bad configuration changes
remote access failures
```

A real troubleshooting process follows:

```text
observe
test
narrow down
fix
verify
document
```

This lab practiced exactly that workflow.


## Important Lessons

* Always establish a healthy baseline before making changes
* `Connection refused` usually means nothing is listening on the target port
* `ssh.service` and `ssh.socket` are related but not the same
* `ssh.socket` can keep port 22 listening and trigger `ssh.service`
* Stopping only `ssh.service` may not fully stop SSH access
* To remove port 22 completely, both `ssh.socket` and `ssh.service` may need to be stopped
* No output from `grep ':22'` can be a useful result
* LISH/Web Console is a safe recovery path
* Logs confirm what happened during break/fix/reconnect
* Public SSH attracts random internet connection attempts
* Recovery is not complete until verified by a successful SSH login


## Reflection

Biggest concepts learned:

```text
SSH baseline checking
systemd service vs socket behavior
port listener diagnosis
connection refused meaning
safe break/fix workflow
journalctl log review
SSH recovery verification
```

Core troubleshooting loop:

```text
Baseline
→ Break
→ Observe
→ Diagnose
→ Fix
→ Verify
→ Document
```

Most important takeaway:

```text
Do not guess.
Check the service.
Check the port.
Check the logs.
Verify the fix.
```

This lab turned SSH troubleshooting from theory into hands-on incident response.