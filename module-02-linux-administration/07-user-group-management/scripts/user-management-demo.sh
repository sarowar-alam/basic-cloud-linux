#!/bin/bash
# user-management-demo.sh
# Demonstrates useradd/usermod/groupadd/sudoers workflow, then cleans up after itself.
#
# Usage: sudo bash user-management-demo.sh

set -e

DEMO_USER="demoacct"
DEMO_GROUP="demogroup"

echo "========================================"
echo " User & Group Management Demo"
echo "========================================"

if [ "$EUID" -ne 0 ]; then
  echo "Run this script with sudo."
  exit 1
fi

# Start clean in case a previous run was interrupted
userdel -r "$DEMO_USER" &>/dev/null || true
groupdel "$DEMO_GROUP" &>/dev/null || true
rm -f "/etc/sudoers.d/$DEMO_USER"

echo ""
echo "--- Creating group and user ---"
groupadd "$DEMO_GROUP"
useradd -m -s /bin/bash -g "$DEMO_GROUP" "$DEMO_USER"
echo "id $DEMO_USER:"
id "$DEMO_USER"

echo ""
echo "--- Adding to sudo group ---"
usermod -aG sudo "$DEMO_USER"
echo "groups $DEMO_USER:"
groups "$DEMO_USER"

echo ""
echo "--- Granting least-privilege sudo (systemctl status only, no password) ---"
echo "$DEMO_USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl status nginx" > "/etc/sudoers.d/$DEMO_USER"
chmod 440 "/etc/sudoers.d/$DEMO_USER"
visudo -cf "/etc/sudoers.d/$DEMO_USER"

echo ""
echo "--- /etc/passwd entry ---"
grep "^$DEMO_USER:" /etc/passwd

echo ""
echo "--- Cleanup ---"
rm -f "/etc/sudoers.d/$DEMO_USER"
userdel -r "$DEMO_USER"
groupdel "$DEMO_GROUP"
echo "Demo user, group, and sudoers rule removed."

echo ""
echo "========================================"
echo " Done!"
echo "========================================"
