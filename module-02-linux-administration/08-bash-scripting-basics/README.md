# 08 — Bash Scripting Basics

## Why This Matters

Every command you've run by hand so far — checking disk space, reading logs, restarting services — is a candidate for automation. Bash scripting turns a manual runbook into something you (or a cron job, or a CI/CD pipeline) can execute reliably and repeatably.

---

## Anatomy of a Script

```bash
#!/bin/bash
# Shebang: tells the OS which interpreter runs this file

echo "Hello, DevOps"
```

```bash
chmod +x script.sh    # Make it executable
./script.sh           # Run it
bash script.sh        # Or run it explicitly with bash, without chmod
```

`set` options worth using in every script:
```bash
set -e   # Exit immediately if any command fails
set -u   # Treat unset variables as an error
set -o pipefail   # A pipeline fails if any command in it fails, not just the last one
```

---

## Variables

```bash
SERVER_NAME="web01"
PORT=8080

echo "Server: $SERVER_NAME on port $PORT"
echo "Server: ${SERVER_NAME}"    # Braces avoid ambiguity next to other text

# Command substitution — capture a command's output into a variable
NOW=$(date +%Y-%m-%d)
DISK_USE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

# Read-only / environment
readonly MAX_RETRIES=3
export APP_ENV=production   # Visible to child processes
```

---

## Exit Codes

Every command returns an exit code: `0` = success, anything else = failure. Scripts should check and propagate them.

```bash
systemctl is-active nginx
echo "Exit code: $?"       # $? holds the exit code of the last command

command_that_might_fail || echo "It failed, but we continue"

my_function
if [ $? -ne 0 ]; then
  echo "my_function failed"
  exit 1
fi
```

---

## Conditionals

```bash
if [ "$DISK_USE" -gt 80 ]; then
  echo "Disk usage critical: ${DISK_USE}%"
elif [ "$DISK_USE" -gt 60 ]; then
  echo "Disk usage warning: ${DISK_USE}%"
else
  echo "Disk usage OK: ${DISK_USE}%"
fi
```

Common test operators:

| Test | Meaning |
|------|---------|
| `-eq`, `-ne`, `-gt`, `-lt`, `-ge`, `-le` | Numeric comparisons |
| `==`, `!=` | String comparison (inside `[[ ]]`) |
| `-f file` | File exists and is a regular file |
| `-d dir` | Directory exists |
| `-z string` | String is empty |
| `-n string` | String is not empty |
| `&&`, `\|\|` | Logical AND / OR |

```bash
if systemctl is-active nginx &>/dev/null; then
  echo "nginx is running"
else
  echo "nginx is down"
fi

if [ -f /etc/nginx/nginx.conf ]; then
  echo "config file exists"
fi
```

---

## Loops

```bash
# for — iterate over a list
for server in web01 web02 web03; do
  echo "Checking $server"
done

# for — iterate over command output
for svc in nginx ssh cron; do
  status=$(systemctl is-active "$svc")
  echo "$svc: $status"
done

# while — repeat until a condition is false
count=0
while [ "$count" -lt 5 ]; do
  echo "Attempt $count"
  count=$((count + 1))
done

# until — repeat until a condition becomes true
until ping -c1 example.com &>/dev/null; do
  echo "Waiting for network..."
  sleep 2
done
```

---

## Functions & Arguments

```bash
# Positional arguments to the script itself
echo "Script name: $0"
echo "First arg: $1"
echo "All args: $@"
echo "Arg count: $#"

# A reusable function
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

check_service nginx
check_service ssh
```

---

## Putting It Together — Server Health Check

```bash
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
for svc in nginx ssh cron; do
  if systemctl is-active "$svc" &>/dev/null; then
    echo "OK: $svc is running"
  else
    echo "ERROR: $svc is NOT running"
  fi
done
```

This is the same pattern used by `health-check.sh` in [Module 02-06 — Troubleshooting Basics](../06-troubleshooting-basics/lab-06-troubleshooting.md) — bash scripting is what turns that manual troubleshooting checklist into a single repeatable command.

---

## Next Step

Proceed to [Module 03 — IAM & AWS CLI →](../../module-03-iam-and-aws-cli/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
