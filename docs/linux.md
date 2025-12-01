# Linux

### Paths
Scripts: /usr/local/bin

## GitHub SSH Setup

### 1. Create SSH keys

```bash
# Authentication key
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/github_auth
# Signing key
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/github_sign
```
_No passphrase → just press Enter._

### 2. Fix permissions
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
```
### 3. Enable systemd-managed ssh-agent socket
```bash
systemctl --user enable --now ssh-agent.socket

# Verify
systemctl --user status ssh-agent.socket

# Expected: `Active: active (listening)`
```

### 4. Set SSH_AUTH_SOCK system-wide (user)
```bash
echo "SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket" >> ~/.config/environment.d/ssh_agent.conf
```
_Log out & log back in._

### 5. Configure SSH
```bash
cat > ~/.ssh/config << 'EOF'
Host *
    AddKeysToAgent yes

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_auth

Host github-sign
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_sign
EOF
```
### 6. Auto-load SSH keys at login (systemd user service)
```bash
cat > ~/.config/systemd/user/ssh-add-github.service << 'EOF'
[Unit]
Description=Add GitHub SSH keys to ssh-agent
After=ssh-agent.socket
Requires=ssh-agent.socket

[Service]
Type=oneshot
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-add -q /home/fahim/.ssh/github_auth /home/fahim/.ssh/github_sign

[Install]
WantedBy=default.target
EOF

# Enable
systemctl --user daemon-reload
systemctl --user enable --now ssh-add-github.service
```

### 7. Add public keys to GitHub
```bash
# Show
cat ~/.ssh/github_auth.pub
cat ~/.ssh/github_sign.pub
```
GitHub → Settings → SSH and GPG Keys  
Add:
- **github_auth.pub** → SSH Authentication Key  
- **github_sign.pub** → SSH Signing Key  

### 8. Enable SSH commit signing in Git
```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/github_sign.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```
### 9. Test authentication
```bash
ssh -T github-auth

# Expected: Hi <username>! You've successfully authenticated...
```
