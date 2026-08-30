# 07 — User & Group Management

## Why This Matters

Every process, file, and permission on Linux is tied to a user and a group. Before you can reason about *who* can do *what*, you need to know how to create, inspect, and remove the accounts themselves — and how `sudo` decides who is allowed to act as root.

---

## Inspecting Users & Groups

```bash
whoami                  # Current username
id                       # UID, GID, and all groups for the current user
id ubuntu                # Same, for a specific user
groups ubuntu             # Just the group memberships
who                      # Who is currently logged in
w                        # Who is logged in + what they're doing

# The three files that define local accounts
cat /etc/passwd           # username:x:UID:GID:comment:home:shell
cat /etc/group            # groupname:x:GID:members
sudo cat /etc/shadow      # hashed passwords + expiry (root only)
```

`/etc/passwd` fields explained:
```
ubuntu:x:1000:1000:Ubuntu:/home/ubuntu:/bin/bash
  │    │  │    │     │        │           │
  │    │  │    │     │        │           └── login shell
  │    │  │    │     │        └── home directory
  │    │  │    │     └── comment/full name (GECOS)
  │    │  │    └── primary GID
  │    │  └── UID
  │    └── password placeholder (real hash lives in /etc/shadow)
  └── username
```

---

## Creating & Managing Users

```bash
# Create a user with a home directory and bash shell
sudo useradd -m -s /bin/bash deploy

# Ubuntu's friendlier, interactive alternative (prompts for password, etc.)
sudo adduser deploy

# Set or change a password
sudo passwd deploy

# Modify an existing user
sudo usermod -aG sudo deploy       # add to a supplementary group (-a = append, don't replace)
sudo usermod -s /usr/sbin/nologin deploy   # disable interactive login (service accounts)
sudo usermod -l newname oldname    # rename a user

# Lock / unlock an account without deleting it
sudo passwd -l deploy              # lock
sudo passwd -u deploy              # unlock

# Delete a user
sudo userdel deploy                # keep home directory
sudo userdel -r deploy             # remove home directory and mail spool too
```

> `usermod -aG` — always use `-a` (append). `usermod -G` alone **replaces** all supplementary groups, silently removing the user from groups they needed (a very common mistake).

---

## Creating & Managing Groups

```bash
sudo groupadd developers            # Create a group
sudo usermod -aG developers deploy    # Add a user to it
sudo gpasswd -d deploy developers     # Remove a user from it
sudo groupdel developers            # Delete a group (only if no user has it as primary)
```

---

## sudo & sudoers

`sudo` lets a permitted user run a command as another user (usually root) without sharing the root password.

```bash
# Always edit sudoers through visudo — it validates syntax before saving
sudo visudo

# Grant full sudo access by adding the user to the sudo group (Debian/Ubuntu)
sudo usermod -aG sudo deploy

# Grant passwordless sudo for a specific command only (least privilege)
# Add a line like this via visudo, or a dedicated file in /etc/sudoers.d/
deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
```

> Never edit `/etc/sudoers` directly with `nano`/`vim`. A syntax error can lock **every** user out of `sudo`. `visudo` prevents saving a broken file.

Best practice: drop custom rules into their own file under `/etc/sudoers.d/` (e.g. `/etc/sudoers.d/deploy`) instead of editing the main file — easier to review and roll back.

---

## Real-World Scenario

A CI/CD pipeline needs to SSH in as `deploy` and restart nginx, but should never have full root access or an interactive login shell for humans:

```bash
sudo useradd -m -s /bin/bash deploy
sudo mkdir -p /home/deploy/.ssh
sudo cp ~/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
sudo chown -R deploy:deploy /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys

# Least-privilege sudo: only this one command, no password prompt
echo 'deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx' | sudo tee /etc/sudoers.d/deploy
sudo chmod 440 /etc/sudoers.d/deploy
```

---

## Lab — User & Group Management

### Step 1 — Create a User

```bash
sudo useradd -m -s /bin/bash testuser
sudo passwd testuser
id testuser
# Expected: uid=1001(testuser) gid=1001(testuser) groups=1001(testuser)
```

### Step 2 — Add to a Group and Verify

```bash
sudo usermod -aG sudo testuser
groups testuser
# Expected: testuser : testuser sudo
```

### Step 3 — Test sudo Access

```bash
su - testuser
sudo whoami
# Expected: root
exit
```

### Step 4 — Clean Up

```bash
sudo userdel -r testuser
id testuser
# Expected: id: 'testuser': no such user
```

---

## Next Step

[08 — Bash Scripting Basics →](../08-bash-scripting-basics/README.md)


---

## 🧑‍💻 Author

*Md. Sarowar Alam*  
Lead DevOps Engineer, WPP Production

📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/sarowar/
