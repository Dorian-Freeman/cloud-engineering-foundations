# Networking

This section documents networking fundamentals, troubleshooting workflows, packet flow, DNS, routing, ports, firewalls, and network simulation labs.

The goal of this section is to build networking intuition for cloud engineering, Linux administration, and troubleshooting real infrastructure issues.


## Focus Areas

* OSI model as a troubleshooting tool
* TCP/IP fundamentals
* IP addressing and subnetting
* DNS resolution
* Routing and default gateways
* NAT and firewalls
* Port and service troubleshooting
* Web server reachability
* Packet Tracer network simulations
* Linux networking tools


## Troubleshooting Mindset

Networking troubleshooting is not guessing. It is systematically testing each part of the path.

Core question:

```text
Where does the request fail?
```

General flow:

```text
DNS
→ IP reachability
→ route
→ port
→ firewall
→ service
→ application
→ logs
```


## Common Tools

```bash
ping
ip a
ip route
ss -tulpn
curl -v
dig
nslookup
traceroute
nc -zv
journalctl
ufw status
iptables -L
```


## Labs

### Lab 2.1 — Web Server Troubleshooting Path

File:

```text
lab2_1-Web-Server-Troubleshooting-Path.md
```

Summary:

This lab builds a troubleshooting framework for the scenario:

```text
“Our web server is running, but users cannot reach the website.”
```

Key concepts:

* DNS may point to the wrong IP
* A server can work locally but fail externally
* `localhost` working does not prove public access works
* `connection refused` means nothing is accepting connections on the target port
* `ss` checks local listeners, not firewall rules
* Timeouts often suggest firewall or external path issues
* Logs confirm what the service is doing

Main troubleshooting path:

```text
DNS → public IP → port 80/443 → firewall → nginx/service → listener → app → logs
```


## Cloud Engineering Connection

Cloud engineers troubleshoot networking constantly.

Examples:

* Website is unreachable
* SSH fails
* DNS points to the wrong server
* Security group blocks traffic
* Firewall allows SSH but blocks HTTP
* App listens on localhost only
* Service is running but not bound to the public interface
* Load balancer health checks fail
* Logs show application or service errors

Understanding networking makes cloud infrastructure easier to build, secure, and debug.


## Project Direction

This section will eventually support larger projects such as:

* Secure Linux Bastion Server
* Packet Tracer company network topology
* VLAN and inter-VLAN routing lab
* DNS server configuration
* NAT and firewall simulation
* Web request packet-flow documentation


## Key Mental Model

Do not ask only:

```text
Is it working?
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

Networking becomes clearer when every problem is treated as a path to test step by step.
