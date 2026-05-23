# Lab 1 — Filesystem Exploration

## Environment

Platform: Linode Ubuntu instance  
Shell user: root  
Hostname: localhost  
Goal: Explore the Linux filesystem, understand directories, permissions, and document findings in GitHub.

---

## GitHub Setup

Created repository:

```text
linux-filesystem-labs
```

Created markdown file:

```text
lab1-filesystem-notes.md
```

Workflow practiced:

```text
Create file → Commit → Push → Verify on GitHub
```

I also practiced editing directly on GitHub and committing changes through the web interface.

---

## Command 1 — pwd

```bash
pwd
```

Output:

```bash
/
```

Meaning:

`pwd` means **print working directory**.

The `/` output means I was standing at the **root directory**, which is the top of the Linux filesystem.

Important distinction:

```text
/      = root directory, top of filesystem
/root  = root user's home directory
```

---

## Command 2 — cd /root

```bash
cd /root
pwd
```

Output:

```bash
/root
```

Meaning:

`cd` means **change directory**.

I moved from the root directory `/` into `/root`, which is the **root user's home directory**.

---

## Command 3 — cd / and ls

```bash
cd /
ls
```

Observed directories:

```text
bin
home
media
run
sys
etc
var
root
proc
usr
tmp
```

Understanding:

These are major Linux filesystem directories.

Linux is organized like a tree, starting from `/`.

---

## Command 4 — ls /etc | head -20

```bash
ls /etc | head -20
```

Observed files:

```text
adduser.conf
adjtime
bash.bashrc
```

My interpretations:

- `adduser.conf` = configuration related to adding users
- `adjtime` = system time adjustment information
- `bash.bashrc` = Bash shell configuration

Understanding:

`/etc` contains **system configuration files**.

This helped me learn to infer file purpose from names.

---

## Command 5 — ls /home

```bash
ls /home
```

At first, the command appeared to return nothing.

Understanding:

If Linux returns straight back to the prompt with no output, it usually means the directory is empty or there is nothing visible to list.

---

## Command 6 — ls -la /home

```bash
ls -la /home
```

Observed:

```text
total 8
drwxr-xr-x ...
drwxr-xr-x ...
```

Understanding:

`ls -la` means:

```text
ls = list files
-l  = long/detailed format
-a  = show all files, including hidden entries
```

Permission breakdown:

```text
drwxr-xr-x
```

Means:

```text
d   = directory
rwx = owner can read, write, execute/access
r-x = group can read and access, but not write
r-x = others can read and access, but not write
```

---

## Linux Permission Line Breakdown

Example line:

```bash
drwxr-xr-x 2 root root 4096 May 4 16:44
```

Meaning:

```text
drwxr-xr-x = file type and permissions
2          = link count
root       = owner
root       = group
4096       = size in bytes
May 4 16:44 = last modified time
```

Plain English:

This is a directory owned by the root user and root group. The owner has full control. Others can read/access but cannot modify it.

---

## Command 7 — ls -la /

```bash
ls -la /
```

Observed important directories:

```text
/home
/root
/etc
/proc
/bin
/usr
/var
/tmp
```

Important observation:

```bash
drwx------ 4 root root 4096 ... root
```

Meaning:

`/root` is locked down.

Permission breakdown:

```text
d = directory
rwx = root owner has full access
--- = group has no permissions
--- = others have no permissions
```

Understanding:

Regular users cannot casually mess with `/root` because it is the root/admin user's private home directory.

---

## /home vs /root

`/home` is like an apartment building hallway.

Multiple normal users may have home directories(apartments) inside it:

```text
/home/user1
/home/user2
/home/user3
```

`/root` is like the security control room.

Only root/admin should have access.

---

## Command 8 — whoami

```bash
whoami
```

Output:

```bash
root
```

Meaning:

`whoami` tells me which user is currently running the shell.

I was logged in as root.

---

## Prompt Breakdown

Prompt:

```bash
root@localhost:/#
```

Meaning:

```text
root      = current user
localhost = hostname
/         = current directory
#         = root/admin shell indicator
```

Important:

Regular users usually see:

```bash
$
```

Root/admin users usually see:

```bash
#
```

The `#` means I have elevated/root privileges and need to be careful.

---

## Command 9 — uname -a

```bash
uname -a
```

Output included:

```bash
Linux localhost 6.8.0-111-generic ... x86_64 GNU/Linux
```

Meaning:

`uname -a` shows system/kernel information.

Breakdown:

```text
Linux     = kernel/system type
localhost = hostname
6.8.0-111 = kernel version
x86_64    = 64-bit architecture
GNU/Linux = operating system family
```

---

## Command 10 — cat /proc/meminfo

```bash
cat /proc/meminfo
```

Understanding:

This shows memory/RAM information from the `/proc` virtual filesystem.

Important fields:

```text
MemTotal     = total RAM
MemFree      = unused RAM
MemAvailable = realistically available RAM
```

Better command for readability:

```bash
cat /proc/meminfo | head -10
```

---

## Key Concepts Learned

### Root directory vs root user home

```text
/     = top of Linux filesystem
/root = root user's private home directory
```

### /etc

Contains system configuration files.

### /home

Contains normal user home directories.

### /proc

Virtual filesystem that exposes process, CPU, memory, and kernel information.

### Permissions

Linux permissions follow:

```text
owner | group | others
```

Example:

```text
rwx | r-x | r-x
```

### Root prompt

```text
# = root/admin shell
$ = normal user shell
```

---

## Cloud Engineering Connection

Linux permissions connect directly to cloud concepts.

AWS IAM feels like Linux permissions scaled to cloud infrastructure.

Understanding:

```text
users
groups
ownership
permissions
least privilege
```

will help with:

```text
AWS IAM
EC2 administration
SSH access
server hardening
automation
cloud security
```

---

## Reflection

This lab started as simple filesystem exploration, but it became a deeper lesson in how Linux systems are structured.

I practiced:

- Running commands
- Predicting outputs
- Reading command results
- Understanding permissions
- Documenting findings
- Using GitHub for version control

The biggest takeaway:

I should not just run commands blindly.

I should follow this process:

```text
Command → Output → Interpretation → Documentation
```