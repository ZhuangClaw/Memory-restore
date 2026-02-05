#!/bin/bash
# memory-restore.sh - 快速恢復記憶腳本
# 用法: ./memory-restore.sh <repo-url> [repo-folder-name]

set -e

REPO_URL="${1:-}"
REPO_NAME="${2:-$(basename "$REPO_URL" .git)}"
WORKSPACE="/home/node/.openclaw/workspace"

if [ -z "$REPO_URL" ]; then
  echo "用法: $0 <github-repo-url> [folder-name]"
  echo "例如: $0 git@github.com:ZhuangClaw/ZhuangZi.git"
  exit 1
fi

echo "=== Memory Restore Script ==="
echo "Repo: $REPO_URL"
echo "Target: $WORKSPACE/$REPO_NAME"
echo ""

# Step 1: Clone (if not exists)
cd "$WORKSPACE"
if [ ! -d "$REPO_NAME" ]; then
  echo "[1/5] Cloning repo..."
  git clone "$REPO_URL"
else
  echo "[1/5] Repo already exists, pulling latest..."
  cd "$REPO_NAME" && git pull && cd ..
fi

# Step 2: Restore workspace files
echo "[2/5] Restoring workspace files..."
for f in AGENTS.md SOUL.md USER.md IDENTITY.md MEMORY.md HEARTBEAT.md TOOLS.md; do
  [ -f "$REPO_NAME/$f" ] && cp "$REPO_NAME/$f" . && echo "  ✓ $f"
done

# Step 3: Restore memory folder
echo "[3/5] Restoring memory folder..."
[ -d "$REPO_NAME/memory" ] && cp -r "$REPO_NAME/memory" . && echo "  ✓ memory/"

# Step 4: Restore skills folder
echo "[4/5] Restoring skills folder..."
[ -d "$REPO_NAME/skills" ] && cp -r "$REPO_NAME/skills" . && echo "  ✓ skills/"

# Step 5: Restore credentials
echo "[5/5] Restoring credentials..."
mkdir -p ~/.config/hkgbook ~/.config/moltbook ~/.config/clawpoker ~/.config/molthub

for skill in hkgbook moltbook clawpoker molthub; do
  cred="$REPO_NAME/skills/$skill/credentials.json"
  if [ -f "$cred" ]; then
    cp "$cred" ~/.config/$skill/
    echo "  ✓ $skill credentials"
  fi
done

echo ""
echo "=== Restore Complete ==="
echo "請執行以下命令確認恢復狀態："
echo "  cat MEMORY.md"
echo "  cat IDENTITY.md"
echo "  ls ~/.config/*/credentials.json"
