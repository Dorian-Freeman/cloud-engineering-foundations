# Lab 2.3 — IP Addressing, Subnets, and Default Gateways

## Goal

The goal of this lab is to understand Layer 3 networking basics: IP addresses, subnets, default gateways, routing decisions, and basic connectivity troubleshooting.

Core question:

```text
Can I reach the host by IP?
```

Main mental model:

```text
IP address = house address
Subnet = neighborhood
Default gateway = exit out of the neighborhood
Internet = outside world
Route table = traffic decision logic
```


## Commands Used

```bash
ip a
ip route
ping -c 4 <destination>
traceroute <destination>
```


## Reading `ip a`

Command:

```bash
ip a
```

Purpose:

```text
Shows network interfaces, IP addresses, interface state, and CIDR/subnet information.
```

Important things to identify:

```text
Interface name
IP address
CIDR/subnet size
Broadcast address
Loopback address
```

Example from this lab:

```text
Interface name: eth0
Server IPv4 address: 172.238.40.232
CIDR/subnet size: /24
Broadcast address: 172.238.40.255
Loopback: 127.0.0.1/8
```

Meaning:

```text
eth0 is the main network interface.
172.238.40.232 is the server's IP address.
172.238.40.232/24 means the server belongs to the 172.238.40.0/24 subnet.
127.0.0.1 is loopback/localhost.
```


## Reading `ip route`

Command:

```bash
ip route
```

Purpose:

```text
Shows where traffic goes and what gateway/interface is used.
```

Example from this lab:

```text
default via 172.238.40.1 dev eth0
172.238.40.0/24 dev eth0 proto kernel scope link src 172.238.40.232
```

Meaning:

```text
Default gateway: 172.238.40.1
Default route interface: eth0
Local network route: 172.238.40.0/24 dev eth0
```

The default route means:

```text
When the server needs to reach something outside its local subnet,
send traffic to 172.238.40.1 through eth0.
```


## Subnet: `/24`

Server IP:

```text
172.238.40.232/24
```

Breakdown:

```text
172.238.40.232 = server IP address
/24 = subnet size
```

For a typical `/24`:

```text
Network address:   172.238.40.0
Usable hosts:      172.238.40.1 - 172.238.40.254
Broadcast address: 172.238.40.255
```

The server:

```text
172.238.40.232
```

belongs to:

```text
172.238.40.0/24
```

because it fits inside the usable host range.


## Local vs Outside Traffic

The server asks:

```text
Is the destination inside my local subnet?
```

If yes:

```text
Send directly on the local interface.
```

If no:

```text
Send to the default gateway.
```

Example server:

```text
IP: 172.238.40.232/24
Subnet: 172.238.40.0/24
Default gateway: 172.238.40.1
```

Local destination:

```text
172.238.40.99
```

Reason:

```text
It is inside 172.238.40.0/24.
```

Outside destination:

```text
172.238.41.99
```

Reason:

```text
The third octet changed from 40 to 41, so it is outside the /24 subnet.
```

Outside destination:

```text
8.8.8.8
```

Reason:

```text
It is not part of 172.238.40.0/24.
```

Outside traffic uses:

```text
Default gateway: 172.238.40.1
```


## Default Gateway

The default gateway is the exit path out of the local subnet.

Example:

```text
default via 172.238.40.1 dev eth0
```

Meaning:

```text
Send non-local traffic to 172.238.40.1 through eth0.
```

Key idea:

```text
The default gateway must usually be reachable inside the local subnet first.
```

Example:

```text
Server IP: 10.0.2.50/24
Default gateway: 10.0.2.1
```

The gateway is local because:

```text
10.0.2.1 belongs to 10.0.2.0/24.
```

## Connectivity Tests

### Test 1 — Gateway

Command:

```bash
ping -c 4 172.238.40.1
```

Purpose:

```text
Tests whether the server can ping its default gateway.
```

Result in this lab:

```text
100% packet loss
```

Important lesson:

```text
A failed ping to the gateway does not always mean routing is broken.
Some cloud infrastructure devices ignore or block ICMP ping.
```


### Test 2 — Internet by IP

Command:

```bash
ping -c 4 8.8.8.8
```

Purpose:

```text
Tests whether the server can reach the internet by IP address.
```

Result in this lab:

```text
0% packet loss
```

Meaning:

```text
Layer 3 routing works.
The server can reach the internet by IP.
```


### Test 3 — Internet by DNS Name

Command:

```bash
ping -c 4 google.com
```

Purpose:

```text
Tests whether the server can resolve DNS names and reach the internet.
```

Result in this lab:

```text
0% packet loss
```

Meaning:

```text
DNS works.
The server can resolve names and reach them.
```


### Test 4 — Route Path

Command:

```bash
traceroute 8.8.8.8
```

Purpose:

```text
Shows the network path toward the destination.
```

Result:

```text
The trace reached dns.google / 8.8.8.8.
```

Meaning:

```text
The route to the internet works.
```

Important lesson:

```text
A hop showing * * * does not automatically mean failure.
It may mean that router does not reply to traceroute probes.
If the trace continues and reaches the destination, the route still works.
```


## CIDR Comparison: `/16`, `/24`, `/32`

### `/16`

Example:

```text
10.0.0.0/16
```

Range idea:

```text
10.0.___.___
```

Inside:

```text
10.0.5.20
10.0.99.100
```

Outside:

```text
10.1.5.20
192.168.1.10
```

Mental model:

```text
/16 = big network
```


### `/24`

Example:

```text
10.0.2.0/24
```

Range idea:

```text
10.0.2.___
```

Inside:

```text
10.0.2.50
10.0.2.255
```

Outside:

```text
10.0.3.50
```

Important nuance:

```text
10.0.2.255 belongs to the 10.0.2.0/24 subnet,
but it is usually the broadcast address and not assignable to a regular host.
```

Typical `/24`:

```text
Network address:    10.0.2.0
Usable hosts:       10.0.2.1 - 10.0.2.254
Broadcast address:  10.0.2.255
```

Mental model:

```text
/24 = normal subnet
```


### `/32`

Example:

```text
10.0.2.50/32
```

Meaning:

```text
One exact IP address only.
```

Mental model:

```text
/32 = single host
```

Common cloud/security use:

```text
Allow SSH from one exact IP address.
```

Example:

```text
73.45.22.10/32
```

Meaning:

```text
Only 73.45.22.10 is allowed.
```


## Routing Decision Examples

Example server:

```text
IP: 10.0.2.50/24
Default gateway: 10.0.2.1
```

### Destination: `10.0.2.88`

Decision:

```text
Local/direct
```

Reason:

```text
Same subnet: 10.0.2.0/24
```


### Destination: `10.0.3.88`

Decision:

```text
Default gateway
```

Reason:

```text
Different subnet.
```


### Destination: `8.8.8.8`

Decision:

```text
Default gateway
```

Reason:

```text
Outside the local network.
```


### Destination: `10.0.2.1`

Decision:

```text
Local/direct
```

Reason:

```text
The default gateway IP is inside the local subnet.
```


## Missing Default Gateway Scenario

Example:

```text
IP: 10.0.2.50/24
Default gateway: missing
```

Can reach:

```text
10.0.2.88
```

Why:

```text
Same local subnet.
```

Cannot reach:

```text
8.8.8.8
```

Why:

```text
Outside the local subnet, and no default gateway exists.
```

Command to confirm:

```bash
ip route
```

If this line is missing:

```text
default via 10.0.2.1 dev eth0
```

then there is no default route.

Problem area:

```text
Layer 3 routing
```


## Troubleshooting Patterns

### No IP Address on Interface

Example:

```text
Server has no IP address on eth0.
```

Problem area:

```text
Layer 2/3 interface or IP configuration issue
```

Possible causes:

```text
interface is down
DHCP failed
static IP misconfigured
cloud network adapter issue
```

Commands:

```bash
ip a
ip link
```


### IP Exists but No Default Route

Example:

```text
Server has IP 10.0.2.50/24 but no default route.
```

Can reach:

```text
local/direct traffic
```

Cannot reach:

```text
outside networks
```

Reason:

```text
The server has no exit path out of its local subnet.
```

Command:

```bash
ip route
```

Problem area:

```text
Layer 3 routing
```


### Can Ping IP but Not Domain

Example:

```text
Server can ping 8.8.8.8 but cannot ping google.com.
```

Problem area:

```text
DNS / Layer 7
```

Reason:

```text
Internet by IP works, but name resolution fails.
```

Commands:

```bash
dig google.com
nslookup google.com
cat /etc/resolv.conf
```


### Can Reach Host but Not Port

Example:

```text
Server can ping SERVER_IP but nc -zv SERVER_IP 443 fails.
```

Problem area:

```text
Layer 4 port/firewall/listener issue
```

Possible causes:

```text
nothing listening on 443
firewall blocks 443
nginx not configured for HTTPS
wrong port
cloud firewall/security group
```

Commands:

```bash
ss -tulpn | grep ':443'
ufw status
systemctl status nginx
```


### Localhost Works but Public IP Fails

Example:

```text
Server can curl http://localhost,
but laptop cannot curl http://SERVER_PUBLIC_IP.
```

Problem area:

```text
External path, firewall, binding, or public IP issue
```

Meaning:

```text
The service works locally, but outside access is broken.
```

Possible causes:

```text
service only bound to 127.0.0.1
server firewall blocking
cloud firewall/security group blocking
wrong public IP
no listener on public interface
routing/external path issue
```

Server-side checks:

```bash
ss -tulpn | grep -E ':80|:443'
ufw status
curl http://localhost
```

Laptop-side checks:

```bash
curl -v http://SERVER_PUBLIC_IP
nc -zv SERVER_PUBLIC_IP 80
```


## AWS / Cloud Engineering Connection

These concepts map directly to AWS networking.

Example AWS structure:

```text
VPC CIDR:        10.0.0.0/16
Public subnet:   10.0.1.0/24
Private subnet:  10.0.2.0/24
Security rule:   my-public-ip/32
```

Same concepts:

```text
VPC = big network
Subnet = smaller neighborhood
Instance IP = host address
Route table = traffic decision rules
Default route = where non-local traffic goes
Gateway = exit path
```

Example route table default route:

```text
0.0.0.0/0 → Internet Gateway
```

Meaning:

```text
Send all traffic that does not match a more specific route to the Internet Gateway.
```


## Key Takeaways

```text
IP address = who am I?
```

```text
Subnet = who is local to me?
```

```text
Default gateway = where do I send outside traffic?
```

```text
Route table = how do I decide where traffic goes?
```

```text
Local subnet = send directly.
Outside subnet = send to gateway.
```

```text
No IP address = interface/IP configuration issue.
```

```text
No default gateway = Layer 3 routing issue.
```

```text
Can ping IP but not domain = DNS issue.
```

```text
Can reach host but not port = Layer 4 issue.
```

```text
Localhost works but public IP fails = external path, firewall, binding, or public IP issue.
```


## Core Mental Model

```text
Do not guess.
Observe, test, narrow down, fix, verify, document.
```

```text
Is the destination local?
If yes, send direct.
If no, send to default gateway.
```

```text
Layer 3 is about IP addressing, subnet membership, routing, and reachability.
```
