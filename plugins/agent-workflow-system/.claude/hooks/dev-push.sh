#!/usr/bin/env bash
# Dev Auto-Push Hook (Linux/Mac)
# 关窗口时自动提交并推送系统改动到 GitHub
# 仅开发者环境有效（检测到 temp-desc 仓库才执行）

set -e

PROJECT_DIR="${1:-$PWD}"
REPO_DIR="$PROJECT_DIR/temp-desc"

# 不是开发环境，跳过
if [ ! -d "$REPO_DIR/.git" ]; then
  exit 0
fi

cd "$REPO_DIR"

# 检查是否有未提交的改动
if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  exit 0
fi

# 自动提交
NOW=$(date '+%Y-%m-%d %H:%M')
git add -A 2>/dev/null
git commit -m "auto: session checkpoint — $NOW" --quiet 2>/dev/null || true

# 推送到远程
git push origin main --quiet 2>/dev/null || true

echo "DevPush: auto-committed and pushed at $NOW"
