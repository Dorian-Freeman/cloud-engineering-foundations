# Lab 2.7 — Routing and End-to-End Packet Flow

## Goal

Understand how packets move from one network to another using IP addressing, default gateways, router interfaces, ARP, MAC addresses, and routing decisions.

Core question:

```text
How does a packet move from one network to another?
```

Core mental model:

```text
IP address = final end-to-end destination
MAC address = next local delivery step
Default gateway = router that carries traffic outside the local subnet
Route table = map that tells the router where to send traffic next
```


## Topology

Packet Tracer topology:

```text
PC-A
  |
Switch-A
  |
Router
  |
Switch-B
  |
PC-B
```

Devices used:

```text
2 PCs
2 switches
1 router
```

Actual Packet Tracer device names:

```text
PC0 = PC-A
PC1 = PC-B
Switch0 = Switch-A
Switch1 = Switch-B
Router0 = Router
```


## Addressing Plan

### PC-A

```text
IP Address: 192.168.10.10
Subnet Mask: 255.255.255.0
Default Gateway: 192.168.10.1
```

### Router G0/0

```text
IP Address: 192.168.10.1
Subnet Mask: 255.255.255.0
Network: 192.168.10.0/24
```

### Router G0/1

```text
IP Address: 192.168.20.1
Subnet Mask: 255.255.255.0
Network: 192.168.20.0/24
```

### PC-B

```text
IP Address: 192.168.20.10
Subnet Mask: 255.255.255.0
Default Gateway: 192.168.20.1
```


## Router Configuration

Entered privileged mode and configuration mode:

```text
enable
configure terminal
```

Configured the left router interface:

```text
interface gigabitEthernet 0/0
ip address 192.168.10.1 255.255.255.0
no shutdown
exit
```

Configured the right router interface:

```text
interface gigabitEthernet 0/1
ip address 192.168.20.1 255.255.255.0
no shutdown
exit
```

Verified interfaces:

```text
end
show ip interface brief
```

Expected result:

```text
GigabitEthernet0/0    192.168.10.1    up    up
GigabitEthernet0/1    192.168.20.1    up    up
```

Important note:

```text
Router interfaces are shutdown by default in Cisco IOS.
The no shutdown command turns an interface on.
```


## Packet Tracer Basics Learned

Packet Tracer is a visual network sandbox.

```text
Devices = PCs, switches, routers, servers
Cables = network links
Config tabs = where IP addresses are set
CLI = where Cisco devices are configured
Simulation Mode = slow-motion packet view
```

Important commands:

```text
enable
→ enter privileged/admin mode

configure terminal
→ enter global configuration mode

interface gigabitEthernet 0/0
→ select router interface

ip address <IP> <mask>
→ assign IP address to interface

no shutdown
→ turn interface on

show ip interface brief
→ verify interface status
```


## Initial Connectivity Tests

### PC-A to Its Gateway

Command from PC-A:

```text
ping 192.168.10.1
```

Result:

```text
4 sent, 4 received, 0% loss
```

Meaning:

```text
PC-A can reach its default gateway.
The 192.168.10.0/24 side is working.
```


### PC-A to PC-B

Command from PC-A:

```text
ping 192.168.20.10
```

Observed first attempt:

```text
First packet timed out.
Remaining packets succeeded.
```

Meaning:

```text
The first timeout was likely caused by ARP learning.
After MAC addresses were learned, the ping succeeded.
```

Second attempt:

```text
4 sent, 4 received, 0% loss
```

Meaning:

```text
Routing from PC-A to PC-B works.
```


### PC-B to Its Gateway

Command from PC-B:

```text
ping 192.168.20.1
```

Result:

```text
4 sent, 4 received, 0% loss
```

Meaning:

```text
PC-B can reach its default gateway.
The 192.168.20.0/24 side is working.
```


### PC-B to PC-A

Command from PC-B:

```text
ping 192.168.10.10
```

Result:

```text
4 sent, 4 received, 0% loss
```

Meaning:

```text
Return path works.
Routing is successful in both directions.
```


## Routing Logic

A host decides whether traffic is local or remote by comparing the destination IP to its own IP and subnet mask.

Example:

```text
PC-A: 192.168.10.10/24
Destination: 192.168.10.1
```

Decision:

```text
Local
```

Reason:

```text
Both are in 192.168.10.0/24.
```

Example:

```text
PC-A: 192.168.10.10/24
Destination: 192.168.20.10
```

Decision:

```text
Remote
```

Reason:

```text
192.168.20.10 is outside 192.168.10.0/24.
```

Remote traffic is sent to the default gateway.


## Simulation Mode Packet Flow

In Simulation Mode, the ping from PC-A to PC-B followed this path:

```text
PC-A
→ Switch-A
→ Router
→ Switch-B
→ PC-B
```

The reply followed the return path:

```text
PC-B
→ Switch-B
→ Router
→ Switch-A
→ PC-A
```

This proved both forward and return paths were working.


## IP Addresses vs MAC Addresses

Major lesson:

```text
IP addresses stay end-to-end.
MAC addresses change hop-by-hop.
```

When PC-A pings PC-B:

```text
Source IP: 192.168.10.10
Destination IP: 192.168.20.10
```

These IP addresses stay the same across the routed path.

But the Ethernet frame changes at each routed hop.


## Router PDU Inspection

In Simulation Mode, the router PDU showed:

### Inbound to Router

Layer 3:

```text
Source IP: 192.168.10.10
Destination IP: 192.168.20.10
```

Layer 2:

```text
Source MAC: PC-A side
Destination MAC: Router G0/0
```

Meaning:

```text
PC-A knew PC-B was remote, so it sent the frame to its default gateway.
```

The destination IP was still PC-B, but the destination MAC was the router.


### Outbound from Router

Layer 3:

```text
Source IP: 192.168.10.10
Destination IP: 192.168.20.10
```

Layer 2:

```text
Source MAC: Router G0/1
Destination MAC: PC-B
```

Meaning:

```text
The router rebuilt the Ethernet frame for the 192.168.20.0/24 network.
```

The router did not change the source or destination IP addresses. It changed the Layer 2 frame.


## Core Packet Flow Rule

```text
Routers forward based on destination IP.
Routers rebuild the Layer 2 frame for the next network.
```

Another way to say it:

```text
IP = end-to-end
MAC = hop-to-hop
ARP = learns the next-hop MAC
Router = forwards based on destination IP
```


## ARP and Default Gateway Behavior

When PC-A sends traffic to remote PC-B, PC-A does not ARP for PC-B’s MAC address.

Instead, PC-A ARPs for the router/default gateway MAC address.

Why?

```text
PC-B is outside PC-A’s local subnet.
```

So PC-A sends the frame to:

```text
Router G0/0
```

while keeping the final destination IP as:

```text
192.168.20.10
```

Important distinction:

```text
Destination IP = final destination
Destination MAC = next local delivery step
```


## Break/Fix Drill 1 — Wrong Default Gateway on PC-A

Original PC-A configuration:

```text
IP: 192.168.10.10
Mask: 255.255.255.0
Gateway: 192.168.10.1
```

Changed PC-A gateway to:

```text
192.168.10.254
```

Expected behavior:

```text
Local traffic should still work.
Remote traffic should fail.
```

### Test 1 — PC-A to Local Gateway

Command:

```text
ping 192.168.10.1
```

Result:

```text
0% loss
```

Meaning:

```text
Local traffic still worked because PC-A did not need the default gateway to reach a local address.
```

### Test 2 — PC-A to PC-B

Command:

```text
ping 192.168.20.10
```

Result:

```text
100% loss
```

Meaning:

```text
Remote traffic failed because PC-A tried to use the wrong default gateway.
```

Diagnosis:

```text
Wrong default gateway on PC-A.
```

Fix:

```text
Set PC-A default gateway back to 192.168.10.1.
```

After fixing, PC-A could ping PC-B again:

```text
0% loss
```

Key takeaway:

```text
Wrong default gateway does not break local traffic.
Wrong default gateway breaks remote traffic.
```


## Break/Fix Drill 2 — Wrong Subnet Mask on PC-A

Changed PC-A subnet mask from:

```text
255.255.255.0
```

to:

```text
255.255.0.0
```

This made PC-A think it belonged to:

```text
192.168.0.0/16
```

Expected behavior:

```text
PC-A would think 192.168.20.10 is local.
PC-A would ARP for PC-B directly.
Ping should fail because ARP does not cross routers.
```

Observed behavior:

```text
Ping still worked.
```

Reason:

```text
The Cisco router likely used Proxy ARP.
```

Proxy ARP allowed the router to answer PC-A’s ARP request on behalf of the remote network.

Lesson:

```text
Proxy ARP can hide subnet mask mistakes by answering ARP requests for remote networks.
```

Fix:

```text
Set PC-A subnet mask back to 255.255.255.0.
```


## Break/Fix Drill 3 — Router Interface Shutdown

Shut down Router G0/1, the interface facing PC-B’s network.

Router command:

```text
enable
configure terminal
interface gigabitEthernet 0/1
shutdown
end
show ip interface brief
```

Expected result:

```text
GigabitEthernet0/1 administratively down/down
```

### Prediction

PC-A to its own gateway:

```text
ping 192.168.10.1
```

Expected:

```text
Works
```

Reason:

```text
PC-A’s side of the router is still up.
```

PC-A to PC-B:

```text
ping 192.168.20.10
```

Expected:

```text
Fails
```

Reason:

```text
The router interface toward 192.168.20.0/24 is down.
```

PC-B to its own gateway:

```text
ping 192.168.20.1
```

Expected:

```text
Fails
```

Reason:

```text
PC-B’s gateway interface is down.
```


## Router Interface Shutdown Results

### PC-A to Router G0/0

Command:

```text
ping 192.168.10.1
```

Result:

```text
0% loss
```

Meaning:

```text
PC-A can still reach its local gateway interface.
```

### PC-A to PC-B

Command:

```text
ping 192.168.20.10
```

Result:

```text
Destination host unreachable.
```

Meaning:

```text
Router G0/0 received the packet, but the router could not forward it to the 192.168.20.0/24 network.
```

### PC-B to Router G0/1

Command:

```text
ping 192.168.20.1
```

Result:

```text
100% loss
```

Meaning:

```text
PC-B lost access to its gateway.
```

Diagnosis:

```text
Router G0/1 is down.
192.168.20.0/24 lost its gateway.
```


## Fixing Router G0/1

Router command:

```text
enable
configure terminal
interface gigabitEthernet 0/1
no shutdown
end
show ip interface brief
```

Expected result:

```text
GigabitEthernet0/1 up/up
```

Retested from PC-B:

```text
ping 192.168.20.1
ping 192.168.10.10
```

Result:

```text
0% loss
```

Retested from PC-A:

```text
ping 192.168.20.10
```

Observed:

```text
First packet timed out, then replies succeeded.
Second ping succeeded with 0% loss.
```

Meaning:

```text
Routing was restored.
ARP had to relearn next-hop MAC information after the interface came back up.
```


## Troubleshooting Ladder

When routing fails, check:

```text
1. Is the host IP correct?
2. Is the subnet mask correct?
3. Is the destination local or remote?
4. Is the default gateway correct?
5. Is the router interface up/up?
6. Does the router know the destination network?
7. Can the destination return traffic?
8. Did ARP need time to learn MAC addresses?
```


## Linux-to-Packet-Tracer Connection

Packet Tracer concepts map to Linux troubleshooting.

```text
Packet Tracer PC IP configuration
↔ Linux ip a

Packet Tracer default gateway
↔ Linux ip route

Packet Tracer ping
↔ Linux ping

Router show ip interface brief
↔ Linux interface status

Simulation Mode ARP behavior
↔ Linux ip neigh / arp -n

Router routing behavior
↔ Linux ip route / ip route get <destination>
```

Useful Linux command:

```bash
ip route get <destination-IP>
```

Example:

```bash
ip route get 8.8.8.8
```

Purpose:

```text
Shows the specific route Linux would choose for a destination.
```


## Cloud Engineering Connection

This lab maps directly to cloud networking.

```text
Packet Tracer LAN
→ cloud subnet

Router interface
→ subnet gateway / virtual router behavior

Default gateway
→ exit path for remote traffic

Router route
→ VPC route-table entry

Multiple networks
→ multiple cloud subnets

Broken return path
→ failed cloud communication
```

AWS examples:

```text
VPC: 10.0.0.0/16
Public subnet: 10.0.1.0/24
Private subnet: 10.0.2.0/24
Route table: 0.0.0.0/0 → Internet Gateway
Route table: 0.0.0.0/0 → NAT Gateway
```

Core cloud lesson:

```text
A subnet can have correct IP addresses but still fail if the route table, gateway path, or return path is wrong.
```


## Key Takeaways

```text
IP addresses stay end-to-end.
MAC addresses change hop-by-hop.
```

```text
Hosts use the default gateway when the destination is outside the local subnet.
```

```text
Routers forward based on destination IP.
```

```text
Routers rebuild Layer 2 frames for each network segment.
```

```text
ARP learns the MAC address for the next local delivery step.
```

```text
First ping failure can be normal because ARP is learning.
```

```text
Wrong default gateway breaks remote traffic but not local traffic.
```

```text
A down router interface breaks access to the connected network.
```

```text
Destination host unreachable from a router means the router received the packet but could not forward it to the destination.
```

```text
Return path matters as much as forward path.
```


## Core Mental Model

```text
The host checks whether the destination is local or remote.
If local, it sends directly.
If remote, it sends to the default gateway.
The router checks the destination IP.
The router forwards out the correct interface.
The router rebuilds the MAC addresses for the next hop.
The destination replies through its own gateway.
Both forward and return paths must work.
```

```text
Do not guess.
Check IP, mask, gateway, interface status, route, ARP, and return path.
```
