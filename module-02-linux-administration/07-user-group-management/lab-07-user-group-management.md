# Lab 07 — User & Group Management

## Task 1 — Inspect the Current Account

```bash
whoami
id
groups
cat /etc/passwd | grep "$USER"
```

Note your UID, primary GID, and every supplementary group you belong to.

---

## Task 2 — Create a Service-Style User

```bash
# Create a user with no login shell (typical for a service account, not a human)
sudo useradd -m -s /usr/sbin/nologin appsvc
id appsvc
# Expected: uid=1002(appsvc) gid=1002(appsvc) groups=1002(appsvc)

# Confirm it cannot log in interactively
sudo su - appsvc
# Expected: This account is currently not available. (or similar, then returns to your shell)
```

---

## Task 3 — Create a Human User With sudo Access

```bash
sudo useradd -m -s /bin/bash devops1
sudo passwd devops1
sudo usermod -aG sudo devops1

# Verify group membership
groups devops1
# Expected: devops1 : devops1 sudo

# Switch to the user and confirm sudo works
su - devops1
sudo whoami
# Expected: root
exit
```

---

## Task 4 — Least-Privilege sudo (One Command Only)

```bash
# Allow devops1 to restart nginx without a password, nothing else
echo 'devops1 ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx' | sudo tee /etc/sudoers.d/devops1
sudo chmod 440 /etc/sudoers.d/devops1

# Validate the sudoers syntax (visudo can check a specific file)
sudo visudo -cf /etc/sudoers.d/devops1
# Expected: /etc/sudoers.d/devops1: parsed OK

su - devops1
sudo systemctl restart nginx   # Expected: runs with no password prompt
sudo whoami                    # Expected: sudo: a password is required (blocked — not in the rule)
exit
```

---

## Task 5 — Group Management

```bash
sudo groupadd webteam
sudo usermod -aG webteam devops1
groups devops1
# Expected includes: webteam

sudo gpasswd -d devops1 webteam
groups devops1
# Expected: webteam no longer listed

sudo groupdel webteam
```

---

## Task 6 — Clean Up

```bash
sudo rm -f /etc/sudoers.d/devops1
sudo userdel -r devops1
sudo userdel -r appsvc

id devops1 2>&1   # Expected: no such user
id appsvc 2>&1     # Expected: no such user
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `usermod -G sudo user` (no `-a`) | Replaces all supplementary groups instead of adding one — use `-aG` |
| Editing `/etc/sudoers` directly | Always use `visudo` (or `visudo -cf` for files in `sudoers.d/`) — a typo can lock out all sudo access |
| Forgetting `-m` on `useradd` | No home directory is created; `ls /home` won't show the new user |
| `userdel` without `-r` | Home directory and mail spool are left behind, wasting disk space |


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
