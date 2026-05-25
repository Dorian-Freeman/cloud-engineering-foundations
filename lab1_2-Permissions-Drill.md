# Lab 1.2 — File Operations, Permissions & Ownership

## Environment

Platform: Linode Ubuntu instance  
Shell user: root  
Hostname: localhost


## Goals

- Practice file operations
- Learn Linux permissions
- Understand ownership
- Understand service accounts
- Connect Linux permissions to cloud security concepts


## Workspace Setup

Commands:

```bash
cd /root
mkdir -p labs/lab1-2
cd labs/lab1-2
pwd
```

Output:

```bash
/root/labs/lab1-2
```

Understanding:

- `cd` = change directory
- `mkdir -p` = create nested directories
- `pwd` = print working directory


## File Creation

Command:

```bash
touch file.txt
ls -la
```

Understanding:

`touch` creates an empty file.

Observed:

```text
-rw-r--r--
```

Breakdown:

```text
- = regular file
rw- = owner permissions
r-- = group permissions
r-- = others permissions
```


## Ownership Observation

Observed:

```text
root root
```

Understanding:

```text
owner = root
group = root
```

Because the root user was running the shell.


## Numeric chmod

Command:

```bash
chmod 600 file.txt
ls -la
```

Understanding:

```text
600
```

Breakdown:

```text
6 = 4(read) + 2(write)
0 = no permissions
0 = no permissions
```

Meaning:

```text
owner = rw-
group = ---
others = ---
```

Result:

```text
-rw-------
```

Understanding:

Only the owner can read/write the file.


## File Writing & Reading

Command:

```bash
echo "hello linux" > file.txt
cat file.txt
```

Output:

```text
hello linux
```

Understanding:

```text
echo = generate text output
> = redirect/overwrite file contents
cat = display file contents
```


## Redirect Operators

### Overwrite

Command:

```bash
echo "AWS" > file.txt
```

Meaning:

Replace file contents.


### Append

Command:

```bash
echo "Cloud" >> file.txt
```

Meaning:

Add to existing contents without deleting previous text.

Key Difference:

```text
>  = overwrite
>> = append
```


## File Removal

Command:

```bash
rm notes.txt
```

Understanding:

`rm` removes/deletes the file itself.

If running:

```bash
cat notes.txt
```

after deletion, Linux returns:

```text
No such file or directory
```


## Symbolic chmod

Example Commands:

```bash
chmod u+x script.sh
chmod g+w file.txt
```

Understanding:

```text
u = owner/user
g = group
o = others
a = all
```

Examples:

```text
u+x = add execute permission to owner
g+w = add write permission to group
```


## Application Directory Scenario

Command:

```bash
mkdir -p /opt/myapp
ls -ld /opt/myapp
```

Understanding:

Created an application directory.

Observed:

```text
drwxr-xr-x
```

Meaning:

```text
directory
owner = rwx
group = r-x
others = r-x
```

Owner:

```text
root root
```


## Application Config File

Command:

```bash
echo "DB_PASSWORD=supersecret" > /opt/myapp/config.env
cat /opt/myapp/config.env
```

Output:

```text
DB_PASSWORD=supersecret
```

Understanding:

Created a configuration/environment file containing application settings.


## Service Account Creation

Command:

```bash
useradd -r -s /bin/false appuser
id appuser
```

Observed:

```text
uid=999(appuser)
gid=988(appuser)
groups=988(appuser)
```

Understanding:

```text
useradd = create user
-r = system account
-s = shell assignment
/bin/false = no interactive login shell
```

Purpose:

`appuser` represents an application/service identity rather than a human administrator account.


## Ownership Transfer

Command:

```bash
chown appuser:appuser /opt/myapp/config.env
ls -la /opt/myapp
```

Understanding:

```text
chown = change ownership
owner:group
```

Changed:

```text
root root
```

to:

```text
appuser appuser
```

Meaning:

The application identity now owns the application config file.


## Secret File Security

Command:

```bash
chmod 600 /opt/myapp/config.env
ls -la /opt/myapp
cat /opt/myapp/config.env
```

Final State:

```text
-rw-------  appuser appuser
```

Meaning:

```text
owner = read/write
group = no access
others = no access
```

Understanding:

Sensitive application secrets should use restrictive permissions.


## Cloud Connection

Linux permissions strongly connect to cloud security concepts.

Concepts practiced:

```text
users
groups
ownership
least privilege
permissions
service identities
```

Cloud parallels:

```text
AWS IAM
EC2 administration
application/service accounts
secret management
cloud security
```


## Reflection

Biggest Concepts Learned:

- File vs directory permissions
- Numeric chmod
- Symbolic chmod
- Ownership vs permissions
- Service accounts
- Least privilege security thinking

Key Process:

```text
Predict
→ Run Command
→ Observe Output
→ Interpret
→ Document
```
