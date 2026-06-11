#!/usr/bin/env bash
# Agent Workflow System — SessionEnd Hook (Linux/Mac)
# 1. Update last_session_end in RESUME.md (fallback)
# 2. Create/update .resume/{session-id}.md (multi-window, v1.8.0+)
set -e

PROJECT_DIR="${1:-$PWD}"
RESUME_PATH="$PROJECT_DIR/RESUME.md"
RESUME_DIR="$PROJECT_DIR/.resume"
SESSION_MARKER="$PROJECT_DIR/.claude/.current-session"
NOW=$(date '+%Y-%m-%d %H:%M:%S')
TODAY=$(date '+%Y-%m-%d')

SEDOPT=""
[[ "$OSTYPE" == "darwin"* ]] && SEDOPT=".bak"

# 1. Update RESUME.md
if [ -f "$RESUME_PATH" ]; then
  sed -i $SEDOPT "s/- \*\*last_updated\*\*:.*/- **last_updated**: $TODAY/" "$RESUME_PATH"
  if grep -q 'last_session_end' "$RESUME_PATH"; then
    sed -i $SEDOPT "s/- \*\*last_session_end\*\*:.*/- **last_session_end**: $NOW/" "$RESUME_PATH"
  else
    printf '\n- **last_session_end**: %s\n' "$NOW" >> "$RESUME_PATH"
  fi
fi

# 2. Create/update .resume/ session file
mkdir -p "$RESUME_DIR"

SESSION_ID=""
[ -f "$SESSION_MARKER" ] && SESSION_ID=$(cat "$SESSION_MARKER")
[ -z "$SESSION_ID" ] && SESSION_ID="session-$(date '+%Y%m%d-%H%M%S')"
SESSION_PATH="$RESUME_DIR/$SESSION_ID.md"

if [ -f "$SESSION_PATH" ]; then
  sed -i $SEDOPT "s/- \*\*last_updated\*\*:.*/- **last_updated**: $TODAY/" "$SESSION_PATH"
  if grep -q 'last_session_end' "$SESSION_PATH"; then
    sed -i $SEDOPT "s/- \*\*last_session_end\*\*:.*/- **last_session_end**: $NOW/" "$SESSION_PATH"
  else
    printf '\n- **last_session_end**: %s\n' "$NOW" >> "$SESSION_PATH"
  fi
elif [ -f "$RESUME_PATH" ]; then
  TASK_NAME="unknown"
  TASK_LINE=$(grep '\*\*task_name\*\*:' "$RESUME_PATH" 2>/dev/null | head -1)
  [ -n "$TASK_LINE" ] && TASK_NAME=$(echo "$TASK_LINE" | sed 's/.*\*\*task_name\*\*:[[:space:]]*//')
  cat > "$SESSION_PATH" << SESSIONEOF
# 🔄 Task recovery point (auto-saved by SessionEnd hook)

> Auto-generated because no closeout was performed.

---

- **session_id**: $SESSION_ID
- **status**: active
- **task_name**: $TASK_NAME
- **phase**: unknown
- **last_updated**: $TODAY
- **completed**: (auto-saved — run closeout for full context)
- **next_step**: Recover from last session
- **blocked_by**: (none)
- **task_stack**:
  - name: $TASK_NAME
    goal: (not recorded)
    progress: (not recorded)
    next_step: Recover from last session
    parent: null
    created: $TODAY
    last_active: $TODAY
- **context_snapshot**:
  - decisions: (run closeout to populate)
  - eliminated: (run closeout to populate)
  - user_style: (run closeout to populate)
  - landmarks: (auto-saved)
  - footguns: (run closeout to populate)

---

- **last_session_end**: $NOW
SESSIONEOF
fi

rm -f "$SESSION_MARKER"

exit 0
