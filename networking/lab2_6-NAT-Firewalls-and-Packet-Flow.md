# Lab 2.6 — NAT, Firewalls, and Packet Flow

## Goal

Understand how packets move between private and public networks, how NAT changes addresses, how firewalls control traffic, and how requests reach a listening service.

Core mental model:

```text
Routing = Where should the packet go?
NAT = Which address should represent the packet?
Firewall = Is the packet allowed through?
Listener = Is a service waiting on the port?
Authentication = Is the user allowed into the application?
```


## Private vs Public IP Addresses

### Private IP

Used inside an internal network and not directly routable across the public internet.

Common private ranges:

```text
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
```

### Public IP

Used to represent a device or network on the public internet.

Mental model:

```text
Private IP = apartment number
Public IP = building street address
```


## NAT — Network Address Translation

NAT rewrites source or destination address information as traffic moves between networks.

It allows private hosts to communicate using publicly routable addresses.

```text
Private host
→ NAT device
→ public internet
```

NAT also tracks the translation so return traffic reaches the correct private host.


## SNAT

SNAT changes the packet’s **source address**.

Common use:

```text
Outbound internet traffic from a private host
```

Example:

```text
Before SNAT:
10.0.2.50:51000
→ 8.8.8.8:443

After SNAT:
203.0.113.10:61000
→ 8.8.8.8:443
```

The destination sees the public address instead of the private address.


## DNAT

DNAT changes the packet’s **destination address**.

Common use:

```text
Inbound forwarding from a public address to a private server
```

Example:

```text
Before DNAT:
166.199.5.97:11290
→ 203.0.113.10:22

After DNAT:
166.199.5.97:11290
→ 10.0.2.50:22
```

Mental model:

```text
Public front door
→ translated to
private server behind it
```


## Routing vs NAT vs Firewall vs Listener

### Routing

```text
Where should the packet go?
```

Command:

```bash
ip route
```

### NAT

```text
Which address should represent the packet?
```

### Firewall

```text
Is the packet allowed through?
```

### Listener

```text
Is an application waiting on the destination port?
```

Important:

```text
A firewall does not create a listener.
A listener does not bypass a firewall.
NAT does not decide permission.
Routing does not authenticate users.
```


## Stateful Firewalls

A stateful firewall remembers active connections.

Example:

```text
Client starts outbound HTTPS connection.
Firewall records the connection.
Returning traffic is allowed because it belongs to that established session.
```

This connects to:

```text
SYN
SYN-ACK
ACK
ESTAB
ephemeral ports
return traffic
```


## Cloud Firewall vs OS Firewall

### Cloud Firewall / Security Group

Enforced by the cloud provider before traffic reaches the operating system.

Controls:

```text
source IP
protocol
destination port
inbound rules
outbound rules
```

### OS Firewall

Runs inside the server.

Examples:

```text
UFW
iptables
nftables
```

### IAM Is Different

```text
IAM
→ identity and resource permissions

Security group
→ network traffic rules
```

Analogy:

```text
Cloud firewall = gate outside the property
OS firewall = security desk inside the building
Listener = worker behind a specific door
IAM = employee badge and job permissions
```


## ALLOW, REJECT, and DROP

### ALLOW

```text
Traffic is permitted.
```

### REJECT

```text
Traffic is denied and the sender receives an immediate response.
```

Typical symptom:

```text
Connection refused
```

### DROP

```text
Traffic is silently discarded.
```

Typical symptom:

```text
Connection timed out
```

Lock-in:

```text
Silent DROP = timeout
No listener or active REJECT = refused
Bad credentials = authentication failure
```


## Listener vs Firewall

### Listener Exists, Firewall Blocks

```text
Service works locally.
Outside users fail.
```

Typical symptom:

```text
Timeout
```

### Firewall Allows, No Listener Exists

```text
Traffic reaches the server.
Nothing accepts the connection.
```

Typical symptom:

```text
Connection refused
```

Successful access requires both:

```text
Firewall permits traffic
+
Service listens on the target port
```


## Commands Used

```bash
ufw status verbose
iptables -L -n -v
iptables -t nat -L -n -v
ip route
ss -tulpn
```

Safe rule:

```text
Observe before modifying.
Do not change SSH firewall rules without a recovery path.
```


## Linode Inspection Results

### UFW

Command:

```bash
ufw status verbose
```

Observed:

```text
Status: inactive
```

Meaning:

```text
UFW was not enforcing rules.
```

Important:

```text
UFW inactive does not mean no firewall exists.
The Linode cloud firewall may still filter traffic.
```


### iptables Filter Table

Command:

```bash
iptables -L -n -v
```

Observed:

```text
INPUT   ACCEPT
FORWARD ACCEPT
OUTPUT  ACCEPT
```

No custom blocking rules were present.

Meaning:

```text
The operating system firewall was permissive.
```


### iptables NAT Table

Command:

```bash
iptables -t nat -L -n -v
```

Observed:

```text
No local NAT rules
```

Meaning:

```text
This server was not performing local iptables-based NAT.
```

NAT may still exist upstream through cloud infrastructure or a gateway.


### Routing

Command:

```bash
ip route
```

Observed:

```text
default via 172.238.40.1 dev eth0
172.238.40.0/24 dev eth0 src 172.238.40.232
```

Meaning:

```text
Server IP: 172.238.40.232
Local subnet: 172.238.40.0/24
Default gateway: 172.238.40.1
Exit interface: eth0
```


### Listening Services

Command:

```bash
ss -tulpn
```

Observed:

```text
Port 53
→ local DNS resolver

Port 22
→ SSH

No listeners on 80 or 443
```

Meaning:

```text
SSH is available.
Local DNS is available.
No HTTP or HTTPS service is listening.
```


## Current SSH Packet Path

```text
Laptop
→ internet
→ Linode cloud firewall
→ eth0
→ OS firewall
→ TCP port 22
→ sshd
```

Evidence:

```text
Route exists
OS firewall allows traffic
Port 22 listener exists
SSH application responds
```

For HTTPS:

```text
Route exists
OS firewall allows traffic
No port 443 listener exists
```

Even if every firewall allowed 443, HTTPS would still fail because no service is waiting on that port.


## SSH Failure Patterns

### Cloud Firewall Drops Port 22

```text
Result: timeout
```

Reason:

```text
The packet is discarded before reaching the server.
```

### Missing Default Route

```text
Result: timeout or broken return path
```

Reason:

```text
The server cannot send replies outside the local subnet.
```

### OS Firewall Drops Port 22

```text
Result: timeout
```

Reason:

```text
The packet reaches Ubuntu but is discarded before reaching sshd.
```

### Nothing Listens on Port 22

```text
Result: connection refused
```

TCP behavior:

```text
SYN
→ RST
```

### SSH Rejects Credentials

```text
Result: authentication denied
```

Meaning:

```text
Routing worked.
Firewall path worked.
Port 22 was listening.
TCP connected.
SSH rejected the username, password, or key.
```


## Full NAT SSH Scenario

Scenario:

```text
Laptop public IP: 166.199.5.97
Client port: 11290
Public NAT IP: 203.0.113.10
Private server IP: 10.0.2.50
SSH port: 22
```

### Inbound Request

Laptop sends:

```text
166.199.5.97:11290
→ 203.0.113.10:22
```

DNAT changes the destination:

```text
203.0.113.10:22
→ 10.0.2.50:22
```

Result:

```text
166.199.5.97:11290
→ 10.0.2.50:22
```

### TCP Connection

The OS firewall allows port 22, and `sshd` is listening.

TCP performs:

```text
SYN
→ SYN-ACK
→ ACK
```

Result:

```text
ESTAB
```

Then SSH authentication begins.

Correct order:

```text
DNAT
→ OS firewall
→ listener
→ TCP handshake
→ SSH authentication
```

### Return Path

The private server replies:

```text
10.0.2.50:22
→ 166.199.5.97:11290
```

NAT rewrites the source so the laptop sees:

```text
203.0.113.10:22
→ 166.199.5.97:11290
```

The laptop sees the reply from the same public IP it originally contacted.


## Cloud Engineering Connection

These concepts map directly to:

```text
Public IPs
Elastic IPs
Internet Gateways
NAT Gateways
Security Groups
Network ACLs
Public subnets
Private subnets
Route tables
Load balancers
```

Private subnet example:

```text
Private EC2 instance
→ route table
→ NAT Gateway
→ Internet Gateway
→ internet
```

Important:

```text
A NAT Gateway allows private instances to initiate outbound traffic.
It does not automatically allow inbound internet connections to those instances.
```


## Key Takeaways

```text
Routing = path
NAT = address translation
Firewall = permission
Listener = service availability
Authentication = application access
```

```text
DNAT changes the destination.
SNAT changes the source.
```

```text
DROP usually causes timeout.
REJECT or no listener usually causes refusal.
Bad credentials cause authentication failure.
```

```text
Cloud firewall and OS firewall are separate layers.
```

```text
Security groups control network traffic.
IAM controls identities and cloud-resource permissions.
```

```text
TCP must connect before SSH authentication begins.
```


## Core Mental Model

```text
The route determines where the packet travels.
NAT determines which address represents it.
The firewall determines whether it may pass.
The listener determines whether a service accepts it.
The application determines whether authentication succeeds.
The return path must work for the conversation to continue.
```

```text
Observe before modifying.
Trace the packet one checkpoint at a time.
Use the symptom as evidence.
```
