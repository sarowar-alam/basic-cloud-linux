# Lab 08 — Bash Scripting Basics

## Task 1 — Your First Script

```bash
cat > ~/hello.sh << 'EOF'
#!/bin/bash
echo "Hello, $(whoami)! Today is $(date +%A)."
EOF

chmod +x ~/hello.sh
./hello.sh
# Expected: Hello, ubuntu! Today is <current day name>.
```

---

## Task 2 — Variables and Arguments

```bash
cat > ~/greet.sh << 'EOF'
#!/bin/bash
NAME="${1:-World}"
echo "Hello, $NAME!"
echo "Script was called with $# argument(s)."
EOF

chmod +x ~/greet.sh
./greet.sh
# Expected: Hello, World!  /  Script was called with 0 argument(s).
./greet.sh DevOps
# Expected: Hello, DevOps!  /  Script was called with 1 argument(s).
```

---

## Task 3 — Conditionals

```bash
cat > ~/disk-check.sh << 'EOF'
#!/bin/bash
DISK_USE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

if [ "$DISK_USE" -gt 80 ]; then
  echo "CRITICAL: Disk usage at ${DISK_USE}%"
elif [ "$DISK_USE" -gt 60 ]; then
  echo "WARNING: Disk usage at ${DISK_USE}%"
else
  echo "OK: Disk usage at ${DISK_USE}%"
fi
EOF

chmod +x ~/disk-check.sh
./disk-check.sh
```

---

## Task 4 — Loops

```bash
cat > ~/service-loop.sh << 'EOF'
#!/bin/bash
for svc in nginx ssh cron; do
  if systemctl is-active "$svc" &>/dev/null; then
    echo "OK: $svc is running"
  else
    echo "ERROR: $svc is NOT running"
  fi
done
EOF

chmod +x ~/service-loop.sh
./service-loop.sh
```

---

## Task 5 — Functions

```bash
cat > ~/functions-demo.sh << 'EOF'
#!/bin/bash

check_service() {
  local name="$1"
  if systemctl is-active "$name" &>/dev/null; then
    echo "OK: $name is running"
    return 0
  else
    echo "ERROR: $name is NOT running"
    return 1
  fi
}

FAILED=0
for svc in nginx ssh cron; do
  check_service "$svc" || FAILED=$((FAILED + 1))
done

echo ""
echo "$FAILED service(s) failed."
exit "$FAILED"
EOF

chmod +x ~/functions-demo.sh
./functions-demo.sh
echo "Script exit code: $?"
```

---

## Task 6 — Build the Full Health Check Script

```bash
cat > ~/server-health-check.sh << 'EOF'
#!/bin/bash
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
if [ "$ISSUES" -eq 0 ]; then
  echo "All checks passed."
else
  echo "$ISSUES issue(s) found."
fi
exit "$ISSUES"
EOF

chmod +x ~/server-health-check.sh
./server-health-check.sh
echo "Exit code: $?"
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Forgetting `chmod +x` | `bash: ./script.sh: Permission denied` — either `chmod +x` or run `bash script.sh` |
| Spaces around `=` in assignment | `NAME = "test"` fails — must be `NAME="test"` (no spaces) |
| Unquoted variables with spaces | `[ $NAME == "test" ]` breaks if `$NAME` is empty/has spaces — always quote: `[ "$NAME" == "test" ]` |
| Using `=` instead of `-eq` for numbers | `[ "$COUNT" = 5 ]` works but is string comparison; prefer `-eq` for numeric intent |
| Missing shebang | Script runs with the wrong shell if executed directly; always start with `#!/bin/bash` |


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
