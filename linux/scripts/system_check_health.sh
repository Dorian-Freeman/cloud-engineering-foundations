#!/bin/bash
# File: system_check_health.sh
# Purpose: Check basic system health metrics

set -euo pipefail
echo "=== System Health Check ==="
echo "Date: $(date)"
echo ""

echo ""
echo "--- Host Info ---"
hostname
whoami
pwd

echo "--- CPU & Memory ---"
echo "Load average: $(uptime | awk '{print $NF}')"
echo "Memory usage:"
free -h | grep Mem

echo ""
echo "--- Disk Usage ---"
df -h | grep -v tmpfs

echo ""
echo "--- Top 5 Processes by CPU ---"
ps aux --sort=-%cpu | head -6

echo ""
echo "--- Listening Services ---"
ss -tulpn | grep LISTEN

echo ""
echo "--- Service Alert Check ---"

SERVICE="ssh"
SERVICE_STATUS=$(systemctl is-active "$SERVICE")

if [ "$SERVICE_STATUS" = "active" ]; then
        echo "$SERVICE is running"
else
        echo "WARNING: $SERVICE is not running"
fi

echo ""
echo "--- Disk Alert Check ---"

DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

echo "Root disk usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 80 ]; then
        echo "WARNING: Disk usage is above 80%"
else
        echo "Disk usage is OK"
fi
