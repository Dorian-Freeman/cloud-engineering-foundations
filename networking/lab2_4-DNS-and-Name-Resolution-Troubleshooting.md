# Lab 2.4 — DNS and Name Resolution Troubleshooting

## Goal

The goal of this lab is to understand DNS as part of network troubleshooting.

Core question:

```text
Can this machine turn a name into an IP address?
```

Mental model:

```text
Domain name = human-friendly name
IP address = machine-friendly destination
DNS = translator / phonebook
```

Before a machine can connect to a domain like:

```text
google.com
```

it needs DNS to answer:

```text
What IP address does google.com point to?
```


## Commands Used

```bash
dig google.com
nslookup google.com
cat /etc/resolv.conf
resolvectl status
ping -c 4 8.8.8.8
ping -c 4 google.com
curl -v https://google.com
nc -zv <host> <port>
traceroute <host>
```


## DNS Basics

DNS translates domain names into IP addresses.

Example:

```text
google.com → 74.125.142.102
```

This lets users type names instead of memorizing IP addresses.

Key idea:

```text
DNS happens before the machine can route traffic to the destination.
```


## DNS vs IP Connectivity

Important troubleshooting pattern:

```bash
ping -c 4 8.8.8.8
```

works, but:

```bash
ping -c 4 google.com
```

fails.

Meaning:

```text
Internet by IP works.
DNS name resolution is failing.
```

This is not mainly a gateway problem, port problem, or web server problem.

It is a DNS problem.


## Layer Difference

### Layer 3 / IP

Question:

```text
Can I reach the destination by IP address?
```

Checks:

```bash
ip a
ip route
ping -c 4 8.8.8.8
traceroute 8.8.8.8
```


### Layer 7 / DNS

Question:

```text
Can I translate the name into the destination IP?
```

Checks:

```bash
dig google.com
nslookup google.com
cat /etc/resolv.conf
resolvectl status
```

Analogy:

```text
IP/routing = Can I drive to the address?
DNS = Can I look up the address from the business name?
```


## Running `dig`

Command:

```bash
dig google.com
```

Purpose:

```text
Checks whether a domain name resolves to DNS records.
```

Important parts of output:

```text
status
ANSWER section
record type
IP addresses returned
query time
DNS server used
```

In this lab, `dig google.com` returned:

```text
status: NOERROR
ANSWER: 6
```

Meaning:

```text
DNS query succeeded.
google.com exists.
The DNS resolver returned answers.
```

The answer section returned multiple IPv4 addresses:

```text
74.125.142.102
74.125.142.101
74.125.142.139
74.125.142.138
74.125.142.113
74.125.142.100
```

These are A records.


## Running `nslookup`

Command:

```bash
nslookup google.com
```

Purpose:

```text
Checks DNS resolution in a simpler format.
```

In this lab, `nslookup` showed:

```text
Server: 127.0.0.53
Address: 127.0.0.53#53
```

Meaning:

```text
The system is asking the local DNS stub resolver first.
```

It also returned IPv4 and IPv6 addresses.

Mental model:

```text
A record = IPv4 address
AAAA record = IPv6 address
```


## `/etc/resolv.conf`

Command:

```bash
cat /etc/resolv.conf
```

Purpose:

```text
Shows what resolver the system is configured to use.
```

In this lab, `/etc/resolv.conf` showed that the file is managed by `systemd-resolved` and points to:

```text
127.0.0.53
```

Meaning:

```text
Apps on the server ask the local DNS stub resolver.
```

Important note:

```text
127.0.0.53 is not the real internet DNS server.
It is a local resolver running on the machine.
```

Mental model:

```text
App → 127.0.0.53 local stub resolver → upstream DNS server → DNS answer
```


## `systemd-resolved` and `resolvectl`

Command:

```bash
resolvectl status
```

Purpose:

```text
Shows DNS resolver status and upstream DNS servers.
```

In this lab, the system used:

```text
resolv.conf mode: stub
```

Meaning:

```text
The system uses a local stub resolver at 127.0.0.53.
```

The actual upstream DNS servers for `eth0` were:

```text
172.232.160.17
172.232.160.19
172.232.160.21
```

DNS domain:

```text
members.linode.com
```

Full DNS path:

```text
App → 127.0.0.53 → Linode DNS servers → DNS answer
```


## DNS Health Check From This Lab

Commands showed:

```text
dig google.com → works
nslookup google.com → works
/etc/resolv.conf → points to local stub resolver
resolvectl status → shows Linode upstream DNS servers
```

Diagnosis:

```text
DNS resolution is healthy.
Resolver configuration is healthy.
Upstream DNS servers are present.
```



## DNS Record Types

### A Record

```text
A record = domain name → IPv4 address
```

Example:

```text
app.example.com → 203.0.113.10
```

Use case:

```text
Point a domain directly to a server IPv4 address.
```


### AAAA Record

```text
AAAA record = domain name → IPv6 address
```

Example:

```text
app.example.com → 2606:4700:4700::1111
```

Use case:

```text
Point a domain to an IPv6 address.
```


### CNAME Record

```text
CNAME record = alias name → another domain name
```

Example:

```text
www.example.com → example.com
```

Cloud example:

```text
app.example.com → my-load-balancer.amazonaws.com
```

Use case:

```text
Point one DNS name to another DNS name instead of directly to an IP.
```


## DNS Failure Patterns

### IP Works, Domain Fails

Example:

```bash
ping -c 4 8.8.8.8
```

works, but:

```bash
ping -c 4 google.com
```

fails.

Problem area:

```text
DNS resolution issue
```

Meaning:

```text
The network path works by IP.
The machine cannot resolve the domain name.
```

Commands to check:

```bash
dig google.com
nslookup google.com
cat /etc/resolv.conf
resolvectl status
```


### NXDOMAIN

Example:

```bash
dig fakewebsite123doesnotexist.com
```

returns:

```text
status: NXDOMAIN
```

Meaning:

```text
The domain name does not exist in DNS.
```

Possible causes:

```text
typo
domain not registered
record does not exist
bad hostname
```


### Wrong IP Returned

Example:

```text
api.example.com → old server IP
```

Problem area:

```text
DNS record/configuration problem
```

Meaning:

```text
DNS is responding, but it is pointing to the wrong destination.
```

If the domain points directly to an old IPv4 address:

```text
Wrong A record
```

If the domain points to an old hostname:

```text
Wrong CNAME record
```


### DNS Works, Curl Times Out

Example:

```bash
dig app.example.com
```

returns an IP, but:

```bash
curl -v https://app.example.com
```

returns:

```text
Connection timed out
```

Meaning:

```text
DNS worked.
The failure happened after DNS.
```

Move to:

```text
network/path bucket
port/firewall bucket
server-side checks
```

Possible causes:

```text
firewall blocking
cloud security group blocking
routing issue
wrong public IP
port blocked
server unreachable
```


## Command Buckets

### DNS Bucket

Use when the problem is:

```text
Can the name become an IP?
```

Commands:

```bash
dig
nslookup
cat /etc/resolv.conf
resolvectl status
ping -c 4 8.8.8.8
ping -c 4 google.com
```


### Network / Path Bucket

Use when the problem is:

```text
Can I reach the IP or host?
```

Commands:

```bash
ping
traceroute
curl -v
nc -zv
```


### Port / Service Bucket

Use when the problem is:

```text
Can I reach the port?
Is something listening?
```

Commands:

```bash
nc -zv <host> <port>
ss -tulpn
ss -tulpn | grep -E ':80|:443'
```


### Server-Side Bucket

Use when the problem is:

```text
Is the service running, listening, allowing, and logging?
```

Commands:

```bash
ss -tulpn
ufw status
systemctl status nginx
journalctl -u nginx -n 50
nginx -t
curl http://localhost
```


## Laptop vs Server DNS Troubleshooting

Scenario:

```text
Laptop resolves the domain fine, but the server cannot resolve any domains.
```

Likely problem:

```text
Server DNS resolver configuration or upstream DNS access.
```

Server-side DNS checks:

```bash
cat /etc/resolv.conf
resolvectl status
dig google.com
nslookup google.com
ping -c 4 8.8.8.8
ping -c 4 google.com
```

Do not start with web-server commands like:

```bash
ss -tulpn
systemctl status nginx
ufw status
```

Those are useful for web service troubleshooting, but not first-choice DNS resolver checks.


## Scenario Practice

### Scenario 1

A user says:

```text
app.example.com is down
```

From laptop:

```bash
dig app.example.com
```

returns:

```text
app.example.com. 300 IN A 203.0.113.10
```

Then:

```bash
curl -v https://app.example.com
```

returns:

```text
Connection timed out
```

Questions:

```text
Did DNS resolve? Yes.
What record type came back? A record.
Is this mainly DNS? No.
What bucket is next? Network/path or port/firewall.
```

Laptop-side checks:

```bash
nc -zv app.example.com 443
traceroute app.example.com
```

Server-side checks:

```bash
ss -tulpn | grep -E ':80|:443'
ufw status
```


### Scenario 2

A domain resolves, but users reach the wrong server.

Example:

```text
api.example.com → old server IP
```

Diagnosis:

```text
DNS record/configuration problem.
```

Possible fix area:

```text
Update the A record or CNAME record to point to the correct destination.
```


## Cloud Engineering Connection

DNS troubleshooting connects directly to cloud work.

Examples:

```text
Route 53 hosted zones
public DNS records
private DNS records
load balancer DNS names
EC2 public DNS
domain pointing to wrong server
CNAME aliases
TTL delays
DNS propagation
```

Cloud example:

```text
app.mysite.com
→ CNAME to AWS load balancer DNS name
→ load balancer resolves to IPs
→ traffic goes to healthy backend servers
```

If DNS points to the wrong destination, users may reach:

```text
old EC2 instance
wrong load balancer
wrong environment
staging instead of production
dead server
```


## Key Takeaways

```text
DNS translates names into IP addresses.
```

```text
A record = name to IPv4.
```

```text
AAAA record = name to IPv6.
```

```text
CNAME record = name to another name.
```

```text
IP works but domain fails = DNS issue.
```

```text
NXDOMAIN = domain does not exist in DNS.
```

```text
Wrong IP returned = DNS record/configuration problem.
```

```text
Name resolves but curl times out = DNS worked, move to network/path/firewall troubleshooting.
```

```text
127.0.0.53 is a local DNS stub resolver managed by systemd-resolved.
```

```text
resolvectl status shows the upstream DNS servers behind the local resolver.
```


## Core Mental Model

```text
Do not guess.
Observe, test, narrow down, fix, verify, document.
```

```text
DNS bucket:
Can the name become an IP?
```

```text
Network/path bucket:
Can I reach the IP or host?
```

```text
Port/service bucket:
Can I reach the port?
```

```text
Application bucket:
Did the app respond correctly?
```

```text
If DNS works, move forward in the request path.
If DNS fails, inspect the resolver and records.
```
