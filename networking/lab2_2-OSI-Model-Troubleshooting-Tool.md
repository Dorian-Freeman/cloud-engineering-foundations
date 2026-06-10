# Lab 2.2 — OSI Model as a Troubleshooting Tool

## Goal

The goal of this lab is to understand the OSI model as a practical troubleshooting tool instead of just a memorization chart.

The main idea:

```text
OSI is not just theory.
OSI helps identify where a network or application request is failing.
```

Troubleshooting mindset:

```text
Symptom → Layer → Evidence → Next Command
```


## Practical OSI View

### Layer 1 — Physical

Physical connection and hardware.

Examples:

```text
cable
Wi-Fi
NIC
link light
physical network access
```

Question:

```text
Is there a physical connection?
```


### Layer 2 — Data Link

Local network communication.

Examples:

```text
MAC address
switching
local network interface
Ethernet/Wi-Fi link
```

Question:

```text
Can the machine communicate on the local network?
```


### Layer 3 — Network

IP addressing and routing.

Examples:

```text
IP address
subnet
default gateway
routing
ping
traceroute
```

Question:

```text
Can I reach the host by IP?
```

Useful commands:

```bash
ip a
ip route
ping <IP>
traceroute <host>
```


### Layer 4 — Transport

TCP and UDP ports.

Examples:

```text
TCP
UDP
port 22
port 80
port 443
connection refused
connection timeout
local listeners
```

Question:

```text
Can I reach the correct port?
```

Useful commands:

```bash
nc -zv <host> <port>
ss -tulpn
ss -tulpn | grep -E ':80|:443'
```


### Layer 5/6 — Session and Presentation

Session handling, encryption, and data formatting.

Examples:

```text
TLS
SSL
certificates
HTTPS handshake
encryption negotiation
```

Question:

```text
Can the client and server create a secure session?
```

Useful command:

```bash
openssl s_client -connect example.com:443 -servername example.com
```


### Layer 7 — Application

The actual application protocol or service.

Examples:

```text
DNS
HTTP
HTTPS
SSH
nginx
API
web app
application errors
logs
```

Question:

```text
Does the application respond correctly?
```

Useful commands:

```bash
dig example.com
nslookup example.com
curl -v http://example.com
curl -v https://example.com
journalctl -u nginx -n 50
tail -n 50 /var/log/nginx/error.log
```


## Command-to-Layer Map

```text
ip a
→ Layer 2/3
Shows network interfaces and IP addresses.

ip route
→ Layer 3
Shows routing table and default gateway.

ping <IP>
→ Layer 3
Tests IP reachability.

traceroute <host>
→ Layer 3
Shows the network path toward a destination.

nc -zv <host> <port>
→ Layer 4
Tests whether a TCP port is reachable.

ss -tulpn
→ Layer 4
Shows local listening ports and processes.

dig example.com
→ Layer 7
Tests DNS resolution.

nslookup example.com
→ Layer 7
Tests DNS resolution.

curl -v http://example.com
→ Layer 7 with Layer 3/4 clues
Tests HTTP/HTTPS behavior and shows connection details.

journalctl -u nginx -n 50
→ Layer 7 / service evidence
Shows service logs.

nginx -t
→ Layer 7 / config validation
Tests nginx configuration.
```


## Laptop vs Server-Side Testing

A major lesson from this lab is knowing where a command should be run from.

### Laptop / Local Machine Testing

Laptop commands show the outside/user perspective.

Question:

```text
Can the outside world resolve, reach, and use the site?
```

Useful commands:

```bash
dig app.example.com
nslookup app.example.com
nc -zv app.example.com 80
nc -zv app.example.com 443
curl -v http://app.example.com
curl -v https://app.example.com
traceroute app.example.com
```


### Server-Side Testing

Server-side commands show what the machine itself is doing.

Question:

```text
Is the server running, listening, allowing, and logging correctly?
```

Useful commands:

```bash
ss -tulpn | grep -E ':80|:443'
ufw status
systemctl status nginx
journalctl -u nginx -n 50
nginx -t
curl http://localhost
```

Key mental model:

```text
Test from where the problem is reported,
then verify from where the service runs.
```


## Web Request Path

When a user opens:

```text
https://example.com
```

The request follows a path:

```text
1. DNS
What IP address does the domain point to?

2. Route
How does my machine reach that IP?

3. TCP Port
Can I connect to the IP on port 443?

4. TLS
Can a secure HTTPS session be created?

5. HTTP
Can I request the webpage?

6. Server/App
Can the server or application return the correct response?

7. Logs
If something breaks, what does the server say happened?
```

Practical flow:

```text
DNS → IP → route → port → TLS → HTTP → app/logs
```


## Failure Pattern Examples

### Could Not Resolve Host

Example:

```text
Could not resolve host: example.com
```

Problem area:

```text
DNS / Layer 7
```

Meaning:

```text
The machine could not turn the domain name into an IP address.
```

Next command:

```bash
dig example.com
```


### Connection Refused

Example:

```text
connect to 203.0.113.10 port 443 failed: Connection refused
```

Problem area:

```text
Layer 4 port/listener problem
```

Meaning:

```text
The server is reachable, but nothing is accepting connections on that target port.
```

Next server-side commands:

```bash
ss -tulpn | grep -E ':80|:443'
systemctl status nginx
```


### Connection Timed Out

Example:

```text
connect to 203.0.113.10 port 443 failed: Connection timed out
```

Problem area:

```text
Layer 3/4 path or firewall problem
```

Meaning:

```text
Traffic may be getting dropped or blocked before a connection completes.
```

Possible causes:

```text
server firewall
cloud firewall
security group
routing issue
wrong public IP
```

Next checks:

```bash
ufw status
traceroute 203.0.113.10
```

Also check cloud firewall/security group rules.


### TLS Handshake Failed

Example:

```text
Connected to example.com
TLS handshake failed
```

Problem area:

```text
TLS / HTTPS configuration
```

Meaning:

```text
The client reached the server, but could not create a secure HTTPS session.
```

Possible causes:

```text
expired certificate
wrong certificate name
missing certificate
bad nginx SSL config
TLS version mismatch
SNI problem
```

Next command:

```bash
openssl s_client -connect example.com:443 -servername example.com
```

Server-side checks:

```bash
journalctl -u nginx -n 50
nginx -t
```


### 403 Forbidden

Example:

```text
HTTP/1.1 403 Forbidden
```

Problem area:

```text
Layer 7 application/web server access-control problem
```

Meaning:

```text
The server understood the request but refused access.
```

Possible causes:

```text
file permissions
nginx/apache access rule
missing authentication
blocked directory access
IP allow/deny rule
application authorization issue
```

Next checks:

```bash
journalctl -u nginx -n 50
tail -n 50 /var/log/nginx/error.log
```


### 500 Internal Server Error

Example:

```text
HTTP/1.1 500 Internal Server Error
```

Problem area:

```text
Layer 7 application/server error
```

Meaning:

```text
The request reached the server or app, but the application failed internally.
```

Next checks:

```bash
journalctl -u nginx -n 50
tail -n 50 /var/log/nginx/error.log
```


### 502 Bad Gateway

Example:

```text
HTTP/1.1 502 Bad Gateway
```

Problem area:

```text
Layer 7 proxy/upstream problem
```

Meaning:

```text
The front server, proxy, or load balancer was reached, but it could not get a good response from the backend service.
```

Mental model:

```text
Client → nginx/load balancer → backend app
```

Possible causes:

```text
backend app is down
backend app listening on wrong port
nginx proxy_pass misconfigured
load balancer target unhealthy
container crashed
upstream timeout/error
```

Next checks:

```bash
journalctl -u nginx -n 50
systemctl status nginx
ss -tulpn
```

Also check the backend application logs.


## Troubleshooting Scenarios

### Scenario 1

A user says:

```text
I cannot reach https://app.example.com
```

Known info:

```text
Domain: app.example.com
Server IP: 203.0.113.10
Expected ports: 80 and 443
```

First laptop-side checks:

```bash
dig app.example.com
nc -zv app.example.com 443
curl -v https://app.example.com
```

Purpose:

```text
Confirm DNS.
Confirm port reachability.
Confirm application response.
```


### Scenario 2

From laptop:

```bash
dig app.example.com
```

returns:

```text
app.example.com → 203.0.113.10
```

Then:

```bash
nc -zv app.example.com 443
```

returns:

```text
Connection timed out
```

Interpretation:

```text
DNS worked.
The outside world did not successfully reach port 443.
Timeout suggests firewall, routing, wrong IP, or external path problem.
```

Next server-side checks:

```bash
ss -tulpn | grep -E ':80|:443'
ufw status
```

Branching logic:

```text
ss shows nothing on :443
→ nginx/app is not listening on HTTPS
→ check systemctl status nginx
→ check nginx -t
→ check logs

ss shows nginx listening on :443, but ufw denies 443
→ server firewall problem
→ allow 443/tcp

ss shows nginx listening and ufw allows 443
→ check cloud firewall/security group
→ check load balancer/security rules
→ confirm public IP is correct
```


## Key Takeaways

```text
OSI is a troubleshooting map, not just a memorization chart.
```

```text
Layer 3 asks:
Can I reach the host?

Layer 4 asks:
Can I reach the port?

Layer 7 asks:
Does the application or protocol respond correctly?
```

```text
Laptop commands show the user/outside perspective.
Server commands show the machine/service perspective.
```

```text
Once an HTTP status code comes back, the network path usually worked far enough to reach the application layer.
```

```text
Connection refused means the host was reached, but the port is not accepting connections.
```

```text
Connection timed out usually suggests traffic is being dropped or blocked.
```

```text
A 502 Bad Gateway often means the front server or load balancer cannot communicate properly with the backend.
```


## Core Mental Model

```text
Do not guess.
Observe, test, narrow down, fix, verify, document.
```

```text
Symptom → Layer → Evidence → Next Command
```

```text
Test from where the problem is reported,
then verify from where the service runs.
```
