#!/bin/bash
# setup-deploy-key.sh - 設定 GitHub Deploy Key
# 用法: ./setup-deploy-key.sh [key-name]

set -e

KEY_NAME="${1:-openclaw_deploy}"
KEY_PATH="$HOME/.ssh/$KEY_NAME"

echo "=== Deploy Key Setup ==="

# Generate key if not exists
if [ ! -f "$KEY_PATH" ]; then
  echo "[1/3] Generating SSH key..."
  mkdir -p ~/.ssh
  ssh-keygen -t ed25519 -C "$KEY_NAME" -f "$KEY_PATH" -N ""
else
  echo "[1/3] Key already exists: $KEY_PATH"
fi

# Configure SSH
echo "[2/3] Configuring SSH..."
if ! grep -q "IdentityFile.*$KEY_NAME" ~/.ssh/config 2>/dev/null; then
  cat >> ~/.ssh/config << EOF
Host github.com
  HostName github.com
  User git
  IdentityFile $KEY_PATH
  IdentitiesOnly yes
EOF
  chmod 600 ~/.ssh/config
fi

# Add known hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null

# Copy to root if needed
if [ "$(id -u)" = "0" ] || [ -d /root ]; then
  echo "[3/3] Copying to /root/.ssh..."
  mkdir -p /root/.ssh
  cp "$KEY_PATH"* /root/.ssh/ 2>/dev/null || true
  cp ~/.ssh/config /root/.ssh/ 2>/dev/null || true
  cp ~/.ssh/known_hosts /root/.ssh/ 2>/dev/null || true
  chmod 600 /root/.ssh/config /root/.ssh/$KEY_NAME 2>/dev/null || true
fi

echo ""
echo "=== Public Key (add to GitHub) ==="
cat "${KEY_PATH}.pub"
echo ""
echo "請到 GitHub repo → Settings → Deploy keys → Add deploy key"
echo "貼上上面的 public key"
