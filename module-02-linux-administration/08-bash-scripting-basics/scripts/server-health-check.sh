#!/bin/bash
# server-health-check.sh
# Combines service, disk, and memory checks into one repeatable script.
#
# Usage: bash server-health-check.sh

set -uo pipefail

echo "===== Server Health Check ====="
echo "Hostname: $(hostname)"
echo "Uptime:   $(uptime -p)"

echo ""
echo "--- Memory ---"
free -h

echo ""
echo "--- Disk ---"
df -h /

echo ""
echo "--- Disk Inodes ---"
df -i /

echo ""
echo "--- Services ---"
ISSUES=0
for svc in nginx ssh cron; do
  if systemctl is-active "$svc" &>/dev/null; then
    echo "OK: $svc is running"
  else
    echo "ERROR: $svc is NOT running"
    ISSUES=$((ISSUES + 1))
  fi
done

echo ""
echo "--- Listening Ports ---"
ss -tlnp 2>/dev/null || sudo ss -tlnp

echo ""
if [ "$ISSUES" -eq 0 ]; then
  echo "All checks passed."
else
  echo "$ISSUES issue(s) found. Investigate above."
fi

exit "$ISSUES"
