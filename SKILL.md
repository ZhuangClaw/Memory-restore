---
name: memory-restore
description: 從 GitHub backup repo 恢復 AI 記憶與設定。用於新安裝、遷移、或災難恢復時，恢復 workspace 檔案、credentials、skills 等。觸發場景：「恢復記憶」、「restore memory」、「從 backup 恢復」、「載入舊設定」。
---

# Memory Restore 記憶恢復技能

從 GitHub backup repo 恢復完整的 AI 狀態。

## 前置條件

1. 有一個 GitHub repo 包含 backup（可以是公開或私人）
2. 如果是私人 repo，需要設定 SSH deploy key

## 恢復流程

### Step 1: 設定 SSH Key（如需要）

如果 repo 是私人的：

```bash
# 生成 deploy key
ssh-keygen -t ed25519 -C "openclaw-deploy" -f ~/.ssh/openclaw_deploy -N ""

# 顯示 public key
cat ~/.ssh/openclaw_deploy.pub
```

告訴用戶：
> 請到 GitHub repo → Settings → Deploy keys → Add deploy key
> 貼上這個 public key，然後按 Add key

設定 SSH config：

```bash
cat >> ~/.ssh/config << 'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/openclaw_deploy
  IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config
```

如果 SSH 是用 root 執行，也要複製到 /root/.ssh/：

```bash
mkdir -p /root/.ssh
cp ~/.ssh/openclaw_deploy* /root/.ssh/
cp ~/.ssh/config /root/.ssh/
ssh-keyscan github.com >> /root/.ssh/known_hosts
chmod 600 /root/.ssh/config /root/.ssh/openclaw_deploy
```

### Step 2: Clone Backup Repo

```bash
cd /home/node/.openclaw/workspace
git clone git@github.com:USER/REPO.git
```

### Step 3: 恢復 Workspace 檔案

從 repo 複製核心設定檔到 workspace：

```bash
REPO_DIR="REPO_NAME"  # 替換為實際 repo 資料夾名

# 核心設定檔
cp $REPO_DIR/AGENTS.md .
cp $REPO_DIR/SOUL.md .
cp $REPO_DIR/USER.md .
cp $REPO_DIR/IDENTITY.md .
cp $REPO_DIR/MEMORY.md .
cp $REPO_DIR/HEARTBEAT.md .
cp $REPO_DIR/TOOLS.md .

# 記憶資料夾
cp -r $REPO_DIR/memory .

# 技能資料夾
cp -r $REPO_DIR/skills .
```

### Step 4: 恢復 Credentials

Credentials 可能在以下位置：

1. **Repo 內的 skills 資料夾**（如 `skills/*/credentials.json`）
2. **Backup tarball 內的 session history**
3. **用戶直接提供**

#### 從 skills 資料夾恢復：

```bash
# 搜索 credentials
find $REPO_DIR -name "credentials.json" -exec cat {} \;

# 複製到標準位置
mkdir -p ~/.config/hkgbook ~/.config/moltbook ~/.config/clawpoker
cp $REPO_DIR/skills/hkgbook/credentials.json ~/.config/hkgbook/ 2>/dev/null
cp $REPO_DIR/skills/moltbook/credentials.json ~/.config/moltbook/ 2>/dev/null
cp $REPO_DIR/skills/clawpoker/credentials.json ~/.config/clawpoker/ 2>/dev/null
```

#### 從 backup tarball 恢復：

```bash
# 解壓 backup
tar -xzf $REPO_DIR/openclaw-backup-*.tar.gz -C /tmp

# 搜索 API keys
grep -r "api_key\|o852_\|moltbook_sk\|clawpoker_" /tmp/home 2>/dev/null
```

#### 標準 Credentials 位置：

| 平台 | 路徑 | Key 格式 |
|------|------|----------|
| HKGBook | `~/.config/hkgbook/credentials.json` | `o852_xxx` (29 chars) |
| Moltbook | `~/.config/moltbook/credentials.json` | `moltbook_sk_xxx` |
| ClawPoker | `~/.config/clawpoker/credentials.json` | `clawpoker_xxx` |
| MoltHub | `~/.config/molthub/credentials.json` | varies |

### Step 5: 驗證恢復

```bash
# 確認檔案存在
ls -la *.md memory/ skills/

# 確認 credentials
cat ~/.config/hkgbook/credentials.json 2>/dev/null
cat ~/.config/moltbook/credentials.json 2>/dev/null

# 測試 API（可選）
curl -H "Authorization: Bearer YOUR_API_KEY" \
  https://rdasvgbktndwgohqsveo.supabase.co/functions/v1/agents-status
```

### Step 6: 讀取恢復的記憶

恢復後，讀取關鍵檔案：

1. `MEMORY.md` — 長期記憶
2. `IDENTITY.md` — 身份設定
3. `USER.md` — 用戶資訊
4. `memory/YYYY-MM-DD.md` — 近期日誌

## 常見問題

| 問題 | 解決方案 |
|------|----------|
| SSH Host key verification failed | `ssh-keyscan github.com >> ~/.ssh/known_hosts` |
| Permission denied | 確認 deploy key 已加到 GitHub |
| Credentials 找不到 | 從 session history 或 tarball 搜索 |
| Key 格式錯誤 | 確認 HKGBook key 是 29 字元 |

## 恢復後清理

```bash
# 刪除 /tmp 解壓的檔案
rm -rf /tmp/home

# 提交恢復狀態
cd /home/node/.openclaw/workspace
git add .
git commit -m "Memory restored: $(date +%Y-%m-%d)"
git push
```
