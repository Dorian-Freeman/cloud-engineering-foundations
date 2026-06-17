# Lab 2.5 — TCP, UDP, Ports, and Connection Behavior

## Goal

The goal of this lab is to understand how Layer 4 delivers traffic to the correct service and how TCP/UDP behavior helps diagnose connection failures.

Core mental model:

```text
IP address = building address
Port = specific door
Service = worker behind the door
TCP/UDP = rules for how communication happens
```


## TCP vs UDP

### TCP

TCP is connection-oriented.

Characteristics:

```text
Uses a handshake
Maintains a connection
Provides ordered delivery
Retransmits missing data
Tracks connection state
```

Common uses:

```text
SSH
HTTP
HTTPS
```

### UDP

UDP is connectionless.

Characteristics:

```text
No TCP-style handshake
Does not maintain an established session
Lower overhead
No built-in guarantee of delivery or order
```

Common uses:

```text
DNS queries
Voice/video traffic
Streaming
```

Important:

```text
UNCONN does not mean a UDP socket is broken.
It is a normal state because UDP does not maintain a TCP-style connection.
```


## Common Service Ports

```text
22  = SSH
53  = DNS
80  = HTTP
443 = HTTPS
```

A single server IP can support many services because each service listens on a different port.


## Listening Ports

A listening port means a service is waiting for incoming traffic on that port.

Example:

```text
0.0.0.0:22
```

Meaning:

```text
SSH is listening on port 22 across all IPv4 interfaces.
```

Example:

```text
[::]:22
```

Meaning:

```text
SSH is listening on port 22 across IPv6 interfaces.
```

Command:

```bash
ss -tulpn
```

Purpose:

```text
Show TCP and UDP listening sockets and the processes that own them.
```


## Socket States

### LISTEN

```text
A service is waiting for incoming TCP connections.
```

Example:

```text
LISTEN 0.0.0.0:22
```

### ESTAB

```text
An active TCP connection exists between two endpoints.
```

Observed SSH example:

```text
ESTAB 172.238.40.232:22 166.199.5.97:11290
```

Interpretation:

```text
172.238.40.232:22
= server using fixed SSH port 22

166.199.5.97:11290
= client using temporary port 11290
```

### TIME-WAIT

```text
The TCP conversation has ended, but Linux temporarily keeps the socket record.
```

Purpose:

```text
Prevent delayed packets from an old connection from interfering with a new connection.
```

### UNCONN

```text
Normal UDP socket state.
```

Observed DNS example:

```text
UNCONN 127.0.0.53:53
```

Meaning:

```text
The local DNS resolver is using UDP port 53 without maintaining a TCP-style connection.
```


## Well-Known vs Ephemeral Ports

Server services usually listen on fixed, well-known ports.

Example:

```text
SSH server = port 22
HTTPS server = port 443
```

Clients usually select temporary high-numbered ports called ephemeral ports.

Example:

```text
Client: 166.199.5.97:11290
Server: 172.238.40.232:22
```

Connection direction:

```text
client ephemeral port → server well-known port
```


## TCP Three-Way Handshake

TCP establishes a connection using:

```text
1. SYN
Client asks to begin a connection.

2. SYN-ACK
Server confirms it received the request and is ready.

3. ACK
Client confirms the server's response.
```

Plain-English model:

```text
Client: Can we talk?
Server: Yes, I hear you.
Client: Confirmed. Connection established.
```

Successful handshake:

```text
SYN → SYN-ACK → ACK
```

Result:

```text
ESTAB
```


## Connection Refused

Pattern:

```text
SYN → RST
```

Meaning:

```text
The host responded, but the connection was rejected.
```

Likely causes:

```text
Nothing listening on the port
Service stopped
Wrong port
Firewall actively rejecting
```

Best server-side checks:

```bash
ss -tulpn | grep ':443'
systemctl status nginx
journalctl -u nginx -n 50
```


## Connection Timed Out

Pattern:

```text
SYN → no useful response
```

Meaning:

```text
The connection attempt received no response before the timeout.
```

Likely causes:

```text
OS firewall silently dropping traffic
Cloud firewall/security group blocking
Routing problem
Wrong public IP
Return-path problem
Destination not responding
```

Useful checks:

From laptop:

```bash
traceroute SERVER_PUBLIC_IP
nc -zv SERVER_PUBLIC_IP 443
```

From server:

```bash
ufw status
ss -tulpn | grep ':443'
```

Also inspect cloud firewall or security group rules.


## Testing Port 443

Command:

```bash
nc -zv google.com 443
```

Observed:

```text
Connection succeeded
```

Meaning:

```text
DNS resolved the hostname.
Layer 3 reached the destination.
TCP port 443 was reachable.
```

After the connection closed:

```bash
ss -tan | grep ':443'
```

showed:

```text
TIME-WAIT
```

Meaning:

```text
The TCP session ended and entered its temporary cleanup state.
```


## HTTPS Request Flow

Command:

```bash
curl -v https://google.com
```

Observed flow:

```text
DNS resolution
Connection to port 443
TLS handshake
Certificate verification
HTTP/2 request
HTTP/2 301 response
```

Observed response:

```text
HTTP/2 301
location: https://www.google.com/
```

Meaning:

```text
Google permanently redirected the request from google.com to www.google.com.
```

Successful path:

```text
DNS
→ IP routing
→ TCP port 443
→ TLS secure session
→ HTTP request
→ HTTP response
```


## Layer 4 vs Layer 7

If:

```bash
nc -zv SERVER_PUBLIC_IP 443
```

succeeds, then Layer 4 worked.

If the following returns:

```text
HTTP/1.1 500 Internal Server Error
```

then the failure is at Layer 7.

Reason:

```text
The network path and TCP port worked well enough for the application to return an HTTP response.
```

Next checks:

```bash
journalctl -u nginx -n 50
tail -n 50 /var/log/nginx/error.log
```


## Troubleshooting Scenarios

### Scenario 1 — Listener Exists, External Connection Times Out

Server output:

```text
LISTEN 0 511 0.0.0.0:443
```

Laptop test:

```bash
nc -zv SERVER_PUBLIC_IP 443
```

Result:

```text
Connection timed out
```

Interpretation:

```text
A service is listening locally on port 443.
The external Layer 4 connection is being blocked or lost.
```

Next checks:

```bash
ufw status
traceroute SERVER_PUBLIC_IP
```

Also inspect:

```text
Cloud firewall
Security group
Routing
Return path
Correct public IP
```


### Scenario 2 — No Listener on Port 443

Command:

```bash
ss -tulpn | grep ':443'
```

Result:

```text
No output
```

Interpretation:

```text
Nothing is listening locally on HTTPS port 443.
```

Next checks:

```bash
systemctl status nginx
journalctl -u nginx -n 50
nginx -t
```

A firewall check is secondary because firewall rules do not create local listeners.


### Scenario 3 — TCP Works, Application Fails

Command:

```bash
nc -zv SERVER_PUBLIC_IP 443
```

Result:

```text
Succeeded
```

Then:

```bash
curl -v https://SERVER_PUBLIC_IP
```

returns:

```text
HTTP/1.1 500 Internal Server Error
```

Interpretation:

```text
Layer 4 worked.
Layer 7 failed.
```

Next checks:

```bash
journalctl -u nginx -n 50
tail -n 50 /var/log/nginx/error.log
```


### Scenario 4 — UDP DNS Socket

Observed:

```text
UNCONN 127.0.0.53:53
```

Interpretation:

```text
This is not a failure.
It is a normal UDP socket state.
Port 53 represents the local DNS resolver.
```


### Scenario 5 — Active SSH Session

Observed:

```text
ESTAB 172.238.40.232:22 166.199.5.97:11290
```

Interpretation:

```text
An active TCP SSH conversation exists.
The server is listening through fixed port 22.
The client initiated the connection from ephemeral port 11290.
```


## Cloud Engineering Connection

These concepts map directly to:

```text
Security group inbound rules
Network ACLs
Cloud firewalls
Load balancer listeners
Target group ports
Container port mappings
Service exposure
Reverse proxies
```

Example security rules:

```text
22/tcp from administrator-public-ip/32
80/tcp from 0.0.0.0/0
443/tcp from 0.0.0.0/0
```

Meaning:

```text
SSH allowed only from one trusted IP
HTTP allowed publicly
HTTPS allowed publicly
```


## Key Takeaways

```text
TCP is connection-oriented.
UDP is connectionless.
```

```text
LISTEN = service waiting for TCP connections.
ESTAB = active TCP conversation.
TIME-WAIT = closed TCP connection in cleanup.
UNCONN = normal UDP socket state.
```

```text
Connection refused:
The host responded, but the port did not accept the connection.
```

```text
Connection timed out:
Traffic may be dropped, blocked, misrouted, or unable to return.
```

```text
Client ephemeral port → server well-known port
```

```text
Once an HTTP response code is returned, Layer 4 worked far enough to reach Layer 7.
```


## Core Mental Model

```text
The IP gets traffic to the server.
The port directs traffic to the service.
TCP or UDP controls how communication happens.
Socket states show whether the service is waiting, active, or closing.
Connection behavior provides evidence about where communication failed.
```

```text
Do not guess.
Observe the state.
Check the listener.
Test the port.
Inspect the firewall.
Read the logs.
Verify the result.
```
