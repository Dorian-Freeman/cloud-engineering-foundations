# Lab 1.4 — Networking Tools: Linux Side

## Environment

Platform: Linode Ubuntu instance  
Shell User: root  
Hostname: localhost


## Goals

- Learn Linux networking diagnostic tools
- Understand network interfaces and IP addresses
- Read the Linux routing table
- Test connectivity by IP and hostname
- Practice DNS troubleshooting
- Test web connectivity and ports
- Trace network paths
- Inspect locally listening services


## Network Interfaces — `ip addr show`

Command:

```bash
ip addr show
```

Purpose:

Display network interfaces and assigned IP addresses.

Observed Interfaces:

```text
lo
eth0
```

Understanding:

```text
lo   = loopback interface / local machine talking to itself
eth0 = primary network interface
```

Observed IPs:

```text
lo:   127.0.0.1/8
eth0: 172.238.52.183/24
```

Understanding:

```text
127.0.0.1 = localhost / this machine
eth0 IP   = server network address
```

Mental Model:

```text
ip addr show = Who am I on the network?
```


## Loopback Address

Observed:

```text
127.0.0.1
```

Understanding:

The loopback address points back to the local machine.

If a service listens only on:

```text
127.0.0.1
```

then only the local server can access it.


## Broadcast Address

Observed:

```text
172.238.52.255
```

Understanding:

In a `/24` network:

```text
172.238.52.0   = network address
172.238.52.255 = broadcast address
```

Broadcast means traffic can be addressed to every device on that subnet.


## Routing Table — `ip route show`

Command:

```bash
ip route show
```

Observed:

```text
default via 172.238.52.1 dev eth0 proto static
172.238.52.0/24 dev eth0 proto kernel scope link src 172.238.52.183
```


## Default Route

Observed:

```text
default via 172.238.52.1 dev eth0
```

Understanding:

```text
default = fallback route
via     = gateway / next hop
dev     = interface used
```

Translation:

If Linux does not know where to send a packet, send it to:

```text
172.238.52.1
```

through:

```text
eth0
```

Mental Model:

```text
default route = machine GPS fallback route
```



## Local Subnet Route

Observed:

```text
172.238.52.0/24 dev eth0
```

Understanding:

Traffic for the local subnet:

```text
172.238.52.0/24
```

can be sent directly through:

```text
eth0
```

without needing the default gateway.



## Routing Decision Example

Destination:

```text
8.8.8.8
```

Process:

```text
Machine checks routing table
↓
Is 8.8.8.8 inside 172.238.52.0/24?
↓
No
↓
Use default route
↓
Send to gateway 172.238.52.1
↓
Use interface eth0
```

Destination:

```text
172.238.52.50
```

Process:

```text
Machine checks routing table
↓
Is 172.238.52.50 inside 172.238.52.0/24?
↓
Yes
↓
Send directly over eth0
```


## Connectivity Testing — `ping`

### Ping by IP

Command:

```bash
ping -c 4 8.8.8.8
```

Purpose:

Test whether the server can reach another machine by IP address.

Observed:

```text
4 packets transmitted
4 received
0% packet loss
```

Understanding:

Network connectivity by IP worked.


### Ping by Hostname

Command:

```bash
ping -c 4 google.com
```

Purpose:

Test DNS resolution and network connectivity.

Understanding:

This command requires:

```text
DNS resolution
+
network connectivity
```

Observed:

Google resolved to an IPv6 address and responded successfully.


## DNS vs Connectivity Logic

If:

```text
ping 8.8.8.8 works
ping google.com fails
```

then the first suspicion is:

```text
DNS problem
```

Why?

Because IP connectivity works, but hostname resolution may be failing.


## DNS Lookup — `nslookup`

Command:

```bash
nslookup google.com
```

Purpose:

Perform a DNS lookup for a hostname.

Observed:

```text
Server: 127.0.0.53
Address: 127.0.0.53#53
```

Understanding:

The system asked its local DNS resolver.

Observed Result:

```text
google.com returned multiple IPv4 and IPv6 addresses
```

Understanding:

Large services like Google return multiple IP addresses for:

```text
load balancing
redundancy
availability
regional routing
```

Mental Model:

```text
nslookup = quick DNS answer
```


## DNS Lookup — `dig`

Command:

```bash
dig google.com
```

Purpose:

Perform a detailed DNS lookup.

Observed Sections:

```text
HEADER
QUESTION SECTION
ANSWER SECTION
SERVER
Query time
```

Important Observations:

```text
status: NOERROR
```

Meaning:

DNS lookup succeeded.

```text
QUESTION SECTION
google.com. IN A
```

Meaning:

Asked for IPv4 address records for google.com.

```text
ANSWER SECTION
google.com. IN A <IPv4 address>
```

Meaning:

DNS returned IPv4 addresses.

Mental Model:

```text
dig = full DNS diagnostic report
```


## Short DNS Answer — `dig +short`

Command:

```bash
dig google.com +short
```

Observed:

```text
142.250.73.78
```

Understanding:

`+short` removes the full diagnostic report and returns only the DNS answer.

Mental Model:

```text
dig google.com        = full DNS report
dig google.com +short = answer only
```


## HTTP/HTTPS Testing — `curl`

Command:

```bash
curl -v https://google.com
```

Purpose:

Make an HTTPS request and show detailed connection information.

Flag Breakdown:

```text
-v = verbose
```

Observed:

```text
Connected to google.com (...) port 443
```

Understanding:

```text
DNS resolved
Network route worked
Port 443 was reachable
HTTPS service responded
```

Observed:

```text
ALPN: curl offers h2,http/1.1
HTTP/2
```

Understanding:

Curl offered HTTP/2 and HTTP/1.1, and Google accepted HTTP/2.

Observed:

```text
HTTP/2 301
location: https://www.google.com/
```

Understanding:

Google responded with a redirect from:

```text
https://google.com
```

to:

```text
https://www.google.com/
```

Mental Model:

```text
ping = can I reach the host?
curl = can I talk to the web service?
curl -v = show the full conversation
```


## Port Reachability — `nc`

Command:

```bash
nc -zv google.com 443
```

Purpose:

Test whether a specific port is reachable.

Flag Breakdown:

```text
-z = zero-I/O mode / check only
-v = verbose
```

Observed:

```text
succeeded
```

Understanding:

Port 443 on google.com was reachable.

Mental Model:

```text
nc = is the port open/reachable?
```


## Download Test — `wget`

Command:

```bash
wget -O /dev/null http://google.com
```

Purpose:

Test whether the server can download web content without saving the file.

Understanding:

```text
wget = download tool
-O = output location
/dev/null = Linux black hole / discard output
```

Observed:

```text
301 Moved Permanently
Location: http://www.google.com/
200 OK
Saving to: /dev/null
/dev/null saved
```

Understanding:

```text
DNS worked
HTTP connection worked
Google redirected to www.google.com
Final request succeeded with 200 OK
Downloaded content was discarded
```

Mental Model:

```text
wget -O /dev/null = download test without saving junk
```


## Trace Network Path — `traceroute`

Command:

```bash
traceroute google.com
```

Purpose:

Show the network path packets take to reach a destination.

If missing:

```bash
apt install traceroute -y
```

Observed:

```text
numbered hops
some * entries
eventually reached Google endpoint
```

Understanding:

Each numbered line is a hop between the server and destination.

`*` means that hop did not reply to traceroute probes.

Important:

```text
* does not always mean traffic failed
```

Some routers/firewalls do not respond to traceroute but still forward traffic.

Mental Model:

```text
ping = can I reach it?
traceroute = what path did I take?
```


## Local Listening Ports — `ss -tulpn`

Command:

```bash
ss -tulpn
```

Purpose:

Show locally listening network services and the processes that own them.

Flag Breakdown:

```text
t = TCP
u = UDP
l = listening
p = processes
n = numeric ports
```

Observed Listening Ports:

```text
53 = DNS
22 = SSH
```

Observed Processes:

```text
systemd-resolved
sshd
```

Understanding:

```text
systemd-resolved = local DNS resolver
sshd             = SSH daemon
```

Observed:

```text
0.0.0.0:22
[::]:22
```

Meaning:

```text
0.0.0.0:22 = SSH listening on all IPv4 interfaces
[::]:22    = SSH listening on IPv6
```

Mental Model:

```text
ss -tulpn = what services are listening locally?
```


## Troubleshooting Toolkit Summary

```text
ip addr show
→ What interfaces and IPs does this machine have?

ip route show
→ Where does traffic go?

ping 8.8.8.8
→ Can I reach by IP?

ping google.com
→ Can DNS resolve and can I reach the host?

nslookup google.com
→ Quick DNS lookup

dig google.com
→ Detailed DNS diagnostic report

dig google.com +short
→ DNS answer only

curl -v https://google.com
→ Can I talk to the HTTPS web service?

nc -zv google.com 443
→ Is port 443 reachable?

wget -O /dev/null http://google.com
→ Can I download web content?

traceroute google.com
→ What path do packets take?

ss -tulpn
→ What ports/services are listening locally?
```


## Cloud Engineering Connection

These tools are used when debugging cloud network problems such as:

```text
EC2 instance cannot reach the internet
server cannot resolve DNS
application cannot reach an API
port is blocked
route table is incorrect
service is not listening
firewall/security group issue
high latency
network path issue
```

Cloud troubleshooting questions:

```text
Is DNS working?
Is the route correct?
Is the port reachable?
Is the service listening?
Can the machine reach the endpoint?
Can the application layer communicate?
```


## Key Troubleshooting Flow

Example:

```text
Application cannot reach external API
```

Troubleshooting path:

```text
1. Check IP/interface
   ip addr show

2. Check route/default gateway
   ip route show

3. Test raw connectivity
   ping 8.8.8.8

4. Test DNS
   nslookup domain.com
   dig domain.com

5. Test port
   nc -zv domain.com 443

6. Test web request
   curl -v https://domain.com

7. Check local listeners
   ss -tulpn
```


## Reflection

Biggest Concepts Learned:

- Interfaces and IP addresses
- Loopback vs network interface
- Routing table logic
- Default gateway
- Same subnet vs different subnet routing
- DNS resolution
- IPv4 and IPv6 responses
- HTTP/HTTPS testing
- Port reachability
- Download testing
- Tracing network paths
- Local listening services

Key Learning Pattern:

```text
Predict
→ Run Command
→ Observe Output
→ Explain
→ Document
```