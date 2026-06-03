#!/usr/bin/env bash
# Agent Workflow System — 自动更新检查
# 每次 Claude Code 启动时静默检查，24h 内最多拉取一次
# 配置方法见 README.md

set -e

MARKETPLACE_DIR="$HOME/.claude/plugins/marketplaces/agent-workflow-system"
STAMP_FILE="$MARKETPLACE_DIR/.last-update-check"
UPDATE_INTERVAL_SEC=$((24 * 60 * 60))  # 24 小时
TIMEOUT_SEC=5

# 如果 marketplace 目录不存在，跳过
if [ ! -d "$MARKETPLACE_DIR" ]; then
  exit 0
fi

# 如果距上次检查不足 24 小时，跳过
if [ -f "$STAMP_FILE" ]; then
  last_check=$(cat "$STAMP_FILE")
  now=$(date +%s)
  if [ $((now - last_check)) -lt $UPDATE_INTERVAL_SEC ]; then
    exit 0
  fi
fi

# 带超时的 git pull
timeout $TIMEOUT_SEC git -C "$MARKETPLACE_DIR" pull --ff-only --quiet 2>/dev/null || true

# 更新时间戳
date +%s > "$STAMP_FILE" 2>/dev/null || true
