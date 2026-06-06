# Lab 2.1 — Web Server Troubleshooting Path

## Environment

Focus Area: Networking + Linux troubleshooting
Scenario: Web server is running, but users cannot reach the website
Primary Services: nginx / web server
Common Ports:

```text
80  = HTTP
443 = HTTPS
```


## Goals

* Build a structured troubleshooting path for unreachable websites
* Connect Week 1 Linux skills to Week 2 networking troubleshooting
* Practice separating DNS, network, port, firewall, service, and application issues
* Understand why `localhost` working does not prove public access works
* Build a repeatable cloud troubleshooting checklist


## Scenario

A user reports:

```text
Our web server is running, but users cannot reach the website.
```

The goal is not to guess. The goal is to isolate where the connection path is breaking.

Troubleshooting path:

```text
DNS
→ IP reachability
→ routing
→ port 80/443
→ firewall
→ web service
→ app binding
→ logs
```


## Key Concept

```text
Works on localhost
does not mean
works from the internet
```

A web app can work locally on the server but still fail for outside users because of:

```text
firewall rules
cloud firewall/security groups
wrong public IP
DNS pointing to wrong IP
service bound only to 127.0.0.1
service not listening on public interface
port 80/443 not open
```


## Warmup Review

### 1. What does connection refused mean?

Meaning:

```text
The server is reachable,
but nothing is accepting connections on the target port.
```

Example:

```text
SSH connection refused = port 22 is not accepting connections
Web connection refused = port 80/443 is not accepting connections
```


### 2. How do you check if port 80 is listening?

Command:

```bash
ss -tulpn | grep ':80'
```

For both HTTP and HTTPS:

```bash
ss -tulpn | grep -E ':80|:443'
```

Understanding:

```text
ss -tulpn = show listening TCP/UDP ports and owning processes
grep = filter output
-E = extended regex
':80|:443' = match port 80 OR port 443
```


### 3. How do you check if nginx is running?

Command:

```bash
systemctl status nginx
```

Alternative process check:

```bash
ps aux | grep nginx
```

Understanding:

```text
systemctl status nginx = check service health/state
ps aux | grep nginx = check if nginx processes exist
```


### 4. How do you check nginx logs?

Command:

```bash
journalctl -u nginx -n 50
```

Live follow:

```bash
journalctl -u nginx -f
```

Understanding:

```text
journalctl = view systemd logs
-u nginx = filter for nginx service
-n 50 = show last 50 log lines
-f = follow logs live
```


### 5. DNS vs IP Test

If this works:

```bash
curl http://SERVER_IP
```

but this fails:

```bash
curl http://example.com
```

Likely problem:

```text
DNS problem
```

Reason:

```text
The server is reachable by IP,
but the domain name is not resolving correctly.
```


## Outside-Machine Troubleshooting

These commands are run from a laptop or another external machine.

### DNS Check

Command:

```bash
dig example.com
```

Purpose:

```text
Does the domain resolve?
Does it point to the correct IP?
```

If `dig` returns the wrong IP:

```text
Problem area = DNS/name resolution
```


### HTTP Check

Command:

```bash
curl -v http://example.com
```

Purpose:

```text
Test HTTP response
Show connection details
Reveal redirects/errors/status codes
```

HTTPS check:

```bash
curl -v https://example.com
```


### Port Reachability

Command:

```bash
nc -zv example.com 80
```

HTTPS port:

```bash
nc -zv example.com 443
```

Understanding:

```text
nc -zv = test whether a port is reachable/open
```

If port check fails:

```text
Problem may be firewall, service listener, or network path
```


### Download Test

Command:

```bash
wget -O /dev/null http://example.com
```

Understanding:

```text
wget = download tool
-O /dev/null = throw downloaded output away
```

Purpose:

```text
Test whether the web server responds and content can be downloaded
```


## Server-Side Troubleshooting

These commands are run after SSHing into the web server.

### Check Web Service Status

Command:

```bash
systemctl status nginx
```

If status shows:

```text
failed
```

Problem area:

```text
nginx service failure
```

Next checks:

```bash
journalctl -u nginx -n 50
nginx -t
systemctl restart nginx
```


### Check Listening Ports

Command:

```bash
ss -tulpn | grep -E ':80|:443'
```

Expected healthy result:

```text
nginx or another web service listening on :80 and/or :443
```

If this command shows nothing:

```text
Nothing is listening on port 80 or 443 locally.
```

Likely causes:

```text
nginx is not running
nginx is not configured to listen on 80/443
app is listening on a different port
service failed to start
```

Important distinction:

```text
Firewall does not create local listeners.
ss checks whether a service is listening locally.
```


### Check Firewall

Command:

```bash
ufw status
```

Purpose:

```text
Check whether Ubuntu firewall rules allow or deny traffic
```

Possible web allowances:

```text
80/tcp
443/tcp
```

Later tools:

```bash
iptables -L
```

Cloud side checks:

```text
security groups
cloud firewall rules
network ACLs
```


### Check Logs

Command:

```bash
journalctl -u nginx -n 50
```

Purpose:

```text
Find service errors, startup failures, permission issues, config problems, or port conflicts.
```


## Localhost vs Public Access

### Local Test

Command:

```bash
curl http://localhost
```

This tests:

```text
Can the server reach its own web service locally?
```

If this works, the app/web server is alive locally.


### Public Test

Command from laptop:

```bash
curl http://SERVER_PUBLIC_IP
```

This tests:

```text
Can outside users reach the web service through the public network path?
```


## Important Scenario

If this works on the server:

```bash
curl http://localhost
```

but this fails from a laptop:

```bash
curl http://SERVER_PUBLIC_IP
```

then the likely problem is:

```text
External access path problem
```

Possible causes:

```text
firewall blocking traffic
cloud security group blocking port 80
service bound only to 127.0.0.1
service not listening on public interface
wrong public IP
routing issue
```

Mental model:

```text
localhost works = app works internally
public IP fails = outside network path is broken
```


## Symptom Interpretation

### Symptom 1

```bash
dig example.com
```

returns the wrong IP.

Problem area:

```text
DNS/name resolution
```


### Symptom 2

```bash
curl http://SERVER_PUBLIC_IP
```

returns:

```text
Connection refused
```

Problem area:

```text
Server reachable, but nothing is accepting connections on the target port.
```

Likely causes:

```text
web service stopped
nothing listening on port 80
wrong port
service failed
```


### Symptom 3

```bash
curl http://localhost
```

works on the server, but:

```bash
curl http://SERVER_PUBLIC_IP
```

times out from laptop.

Problem area:

```text
external access path
```

Likely causes:

```text
firewall dropping traffic
cloud firewall/security group blocking
routing/public IP issue
service bound internally only
```


### Symptom 4

```bash
ss -tulpn | grep -E ':80|:443'
```

shows nothing.

Problem area:

```text
No local web listener exists on port 80 or 443.
```

Likely causes:

```text
nginx not running
nginx not configured for 80/443
application using different port
service failed to bind
```


### Symptom 5

```bash
systemctl status nginx
```

shows:

```text
failed
```

Problem area:

```text
nginx service failure
```

Troubleshooting flow:

```bash
systemctl status nginx
journalctl -u nginx -n 50
nginx -t
systemctl restart nginx
ss -tulpn | grep -E ':80|:443'
```


## Full Troubleshooting Ladder

```text
1. DNS
   Is the domain resolving?
   Does it point to the correct IP?

2. IP Reachability
   Can the server IP be reached?

3. Port Reachability
   Can users reach port 80 or 443?

4. Firewall
   Is traffic allowed through OS firewall and cloud firewall?

5. Service
   Is nginx/apache running?

6. Listener
   Is the service listening on 80/443?

7. Binding
   Is the app listening on public interface or only localhost?

8. Application Response
   Does curl return HTTP status codes or errors?

9. Logs
   What does journalctl/nginx logs say?
```


## Command Toolkit

Outside checks:

```bash
dig example.com
curl -v http://example.com
curl -v https://example.com
nc -zv example.com 80
nc -zv example.com 443
wget -O /dev/null http://example.com
```

Server-side checks:

```bash
systemctl status nginx
ss -tulpn | grep -E ':80|:443'
journalctl -u nginx -n 50
journalctl -u nginx -f
ufw status
curl http://localhost
curl http://SERVER_PUBLIC_IP
```

Config check:

```bash
nginx -t
```

Restart service:

```bash
systemctl restart nginx
```


## Cloud Engineering Connection

This lab connects directly to cloud support and cloud engineering work.

Cloud engineers troubleshoot web access issues involving:

```text
DNS records
public IPs
security groups
firewalls
load balancers
nginx/apache services
application ports
routing tables
logs
```

The key skill is isolating where the request fails.

Example request path:

```text
User browser
→ DNS
→ public IP
→ cloud firewall/security group
→ server OS firewall
→ port 80/443
→ nginx/web service
→ application
→ logs
```


## Core Mental Model

Do not ask:

```text
Is the website working?
```

Ask:

```text
Working from where?
To what IP?
On what port?
Through what firewall?
Bound to which interface?
What do the logs say?
```


## Reflection

Biggest concepts learned:

```text
localhost working does not prove public access works
connection refused means nothing is accepting connections on target port
timeouts often suggest firewall/drop/external path issues
ss checks local listeners, not firewall rules
DNS must point to the correct IP
service health, port listeners, firewall, and logs must all be checked
```

Troubleshooting pattern:

```text
Observe
→ Test DNS
→ Test connectivity
→ Test port
→ Check firewall
→ Check service
→ Check listener
→ Check logs
→ Fix
→ Verify
```

Most important takeaway:

```text
Do not guess.
Test the path layer by layer.
```
