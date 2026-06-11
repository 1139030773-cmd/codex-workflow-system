#!/usr/bin/env bash
# Agent Workflow System — SessionStart Hook (Linux/Mac)
# 1. Auto git pull (24h throttle)
# 2. Generate session ID for this window
# 3. Check remote plugin.json for newer version
set -e

PROJECT_DIR="${1:-$PWD}"
MARKETPLACE_DIR="$HOME/.claude/plugins/marketplaces/agent-workflow-system"
STAMP_FILE="$MARKETPLACE_DIR/.last-update-check"
UPDATE_INTERVAL_SEC=$((24 * 60 * 60))
TIMEOUT_SEC=5

# 1. git pull (24h throttle)
if [ -d "$MARKETPLACE_DIR" ]; then
  skip=false
  if [ -f "$STAMP_FILE" ]; then
    last=$(cat "$STAMP_FILE" 2>/dev/null)
    now=$(date +%s)
    [ $((now - last)) -lt $UPDATE_INTERVAL_SEC ] && skip=true
  fi
  if [ "$skip" != true ]; then
    timeout $TIMEOUT_SEC git -C "$MARKETPLACE_DIR" pull --ff-only --quiet 2>/dev/null || true
    date +%s > "$STAMP_FILE" 2>/dev/null || true
  fi
fi

# 2. Generate session ID
SESSION_ID="session-$(date '+%Y%m%d-%H%M%S')"
echo "$SESSION_ID" > "$PROJECT_DIR/.claude/.current-session" 2>/dev/null || true

# 3. Check remote version
VERSION_MARKER="$PROJECT_DIR/.claude/.version-check"
LOCAL_PLUGIN="$PROJECT_DIR/plugins/plugins/agent-workflow-system/.codex-plugin/plugin.json"
REMOTE_URL="https://raw.githubusercontent.com/1139030773-cmd/agent-workflow-system/main/plugins/agent-workflow-system/.codex-plugin/plugin.json"

rm -f "$VERSION_MARKER"

if [ -f "$LOCAL_PLUGIN" ]; then
  local_ver=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$LOCAL_PLUGIN" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
  remote_json=$(curl -s --connect-timeout 5 "$REMOTE_URL" 2>/dev/null)
  if [ -n "$remote_json" ]; then
    remote_ver=$(echo "$remote_json" | grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
    if [ -n "$remote_ver" ] && [ "$remote_ver" != "$local_ver" ]; then
      newer=false
      IFS='.' read -ra la <<< "$local_ver"
      IFS='.' read -ra ra <<< "$remote_ver"
      max=${#la[@]}; [ ${#ra[@]} -gt $max ] && max=${#ra[@]}
      for ((i=0; i<max; i++)); do
        l=${la[$i]:-0}; r=${ra[$i]:-0}
        [ "$r" -gt "$l" ] 2>/dev/null && { newer=true; break; }
        [ "$r" -lt "$l" ] 2>/dev/null && break
      done
      [ "$newer" = true ] && echo "newer|$remote_ver|$local_ver" > "$VERSION_MARKER"
    fi
  fi
fi

exit 0
