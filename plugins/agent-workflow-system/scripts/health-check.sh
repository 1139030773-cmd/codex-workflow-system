#!/usr/bin/env bash
# System Health Check Script (Linux/Mac)
# Modes: check (detect issues) / clean (archive old data)
# Runs silently on session start, reports only when issues found.
set -e

MODE="${1:-check}"
ROOT="${2:-$PWD}"

REQUIRED_FIELDS=("session_id" "status" "task_name" "phase" "last_updated" "next_step" "last_session_end")
VALID_STATUSES=("active" "paused" "completed" "inactive" "abandoned")
COMPLETED_MAX=15
DECISIONS_MAX=20
SESSION_MAX_PER_TASK=2
ARCHIVE_DIR="$ROOT/archive"

TOTAL_SCORE=100
ISSUES=()

score_subtract() {
  local amount=$1 reason=$2
  TOTAL_SCORE=$((TOTAL_SCORE - amount))
  [ $TOTAL_SCORE -lt 0 ] && TOTAL_SCORE=0
  ISSUES+=("[ -$amount ] $reason")
}

# ============================================================
# Check 1: RESUME.md + .resume/
# ============================================================

if [ ! -f "$ROOT/RESUME.md" ]; then
  score_subtract 15 "RESUME.md file missing"
else
  size=$(wc -c < "$ROOT/RESUME.md" 2>/dev/null || echo 0)
  [ "$size" -lt 10 ] && score_subtract 10 "RESUME.md empty or corrupted"
fi

if [ ! -d "$ROOT/.resume" ]; then
  score_subtract 5 ".resume/ directory missing"
else
  declare -A task_counts
  for sf in "$ROOT/.resume"/session-*.md; do
    [ ! -f "$sf" ] && continue
    fname=$(basename "$sf")
    content=$(cat "$sf" 2>/dev/null)

    # Check required fields
    missing=""
    for field in "${REQUIRED_FIELDS[@]}"; do
      echo "$content" | grep -q "\*\*${field}\*\*:" || missing="$missing $field"
    done
    [ -n "$missing" ] && score_subtract 5 "$fname: missing fields$missing"

    # Check status validity
    status_val=$(echo "$content" | grep -o '\*\*status\*\*:[[:space:]]*\S\+' | head -1 | sed 's/.*:[[:space:]]*//')
    valid=false
    for vs in "${VALID_STATUSES[@]}"; do [ "$status_val" = "$vs" ] && valid=true; done
    [ "$valid" = false ] && [ -n "$status_val" ] && score_subtract 3 "$fname: invalid status '$status_val'"

    # Count active sessions per task
    if [ "$status_val" = "active" ]; then
      tn=$(echo "$content" | grep '\*\*task_name\*\*:' | head -1 | sed 's/.*\*\*task_name\*\*:[[:space:]]*//')
      [ -n "$tn" ] && task_counts["$tn"]=$((${task_counts["$tn"]:-0} + 1))
    fi

    # Check session_id format
    sid=$(echo "$content" | grep '\*\*session_id\*\*:' | head -1 | sed 's/.*\*\*session_id\*\*:[[:space:]]*//')
    echo "$sid" | grep -q '^session-[0-9]\{8\}-[0-9]\{6\}$' || score_subtract 3 "$fname: invalid session_id '$sid'"
  done

  for tn in "${!task_counts[@]}"; do
    [ "${task_counts[$tn]}" -gt $SESSION_MAX_PER_TASK ] && score_subtract 3 "Task '$tn' has ${task_counts[$tn]} active sessions (threshold $SESSION_MAX_PER_TASK)"
  done
fi

# ============================================================
# Check 2: TASK_QUEUE.md
# ============================================================

if [ ! -f "$ROOT/TASK_QUEUE.md" ]; then
  score_subtract 5 "TASK_QUEUE.md file missing"
else
  # Extract task rows, IDs, and parent refs
  declare -A task_ids
  while IFS= read -r line; do
    num=$(echo "$line" | sed -n 's/^| \([0-9]\+\) | .*/\1/p')
    [ -z "$num" ] && continue
    parent=$(echo "$line" | sed 's/^| [0-9]\+ | [^|]* | \([^|]*\) |.*/\1/' | xargs)
    [ "$num" = "$parent" ] && continue
    [ -n "${task_ids[$num]}" ] && score_subtract 3 "TASK_QUEUE: duplicate task #$num"
    task_ids[$num]=1
    # Check parent reference
    pnum=$(echo "$parent" | sed -n 's/^#\([0-9]\+\)$/\1/p')
    if [ -n "$pnum" ] && [ -z "${task_ids[$pnum]}" ]; then
      score_subtract 5 "TASK_QUEUE: #$num parent #$pnum not found"
    fi
  done < <(grep -E '^\| [0-9]+ \|' "$ROOT/TASK_QUEUE.md")
  [ "${#task_ids[@]}" -eq 0 ] && score_subtract 2 "TASK_QUEUE has no tasks"
fi

# ============================================================
# Check 3: task_stack orphans + context_snapshot
# ============================================================

declare -A all_names
declare -a parents

for src in "$ROOT/RESUME.md" "$ROOT/.resume"/session-*.md; do
  [ ! -f "$src" ] && continue
  current_name=""
  in_stack=false
  while IFS= read -r line; do
    [[ "$line" =~ task_stack: ]] && { in_stack=true; continue; }
    $in_stack && [[ "$line" =~ ^[[:space:]]{4}-[[:space:]]*name:[[:space:]]*(.+) ]] && current_name="${BASH_REMATCH[1]}"
    [ -n "$current_name" ] && all_names["$current_name"]=1
    $in_stack && [[ "$line" =~ ^[[:space:]]{6}parent:[[:space:]]*(.+) ]] && {
      p="${BASH_REMATCH[1]}"
      [ "$p" != "null" ] && parents+=("$current_name|$p|$(basename "$src")")
    }
    $in_stack && [[ "$line" =~ context_snapshot: ]] && in_stack=false
    $in_stack && [[ "$line" =~ ^[[:space:]]{2}-[[:space:]]*\*\* ]] && in_stack=false
  done < "$src"
done

for entry in "${parents[@]}"; do
  IFS='|' read -r child pref srcname <<< "$entry"
  [ -z "${all_names[$pref]}" ] && score_subtract 8 "Orphan task_stack: '$child' parent '$pref' not found ($srcname)"
done

# context_snapshot completeness (RESUME.md only)
for block in decisions eliminated user_style landmarks footguns; do
  grep -q "\- $block:" "$ROOT/RESUME.md" 2>/dev/null || missing_cs="$missing_cs $block"
done
[ -n "$missing_cs" ] && score_subtract 5 "context_snapshot missing blocks:$missing_cs"

# ============================================================
# Check 4: DECISIONS.md
# ============================================================

if [ ! -f "$ROOT/DECISIONS.md" ]; then
  score_subtract 3 "DECISIONS.md file missing"
else
  dcount=$(grep -c '^## D[0-9]' "$ROOT/DECISIONS.md" 2>/dev/null || echo 0)
  [ "$dcount" -gt $DECISIONS_MAX ] && score_subtract 3 "DECISIONS has $dcount entries (threshold $DECISIONS_MAX)"
  ddates=$(grep -c '\*\*\(date\|日期\)\*\*[：:].*\S' "$ROOT/DECISIONS.md" 2>/dev/null || echo 0)
  [ "$ddates" -lt "$dcount" ] && score_subtract 3 "DECISIONS: $((dcount - ddates)) entries missing date"
fi

# ============================================================
# Check 5: Skill integrity
# ============================================================

SKILLS_DIR="$ROOT/plugins/plugins/agent-workflow-system/skills"
if [ -d "$SKILLS_DIR" ]; then
  for skill in agent-debug-fixer agent-drift-auditor agent-learning-coach agent-newbie-guide agent-phase-closeout agent-project-master; do
    [ ! -d "$SKILLS_DIR/$skill" ] && missing_skills="$missing_skills $skill(dir)"
    [ ! -f "$SKILLS_DIR/$skill/manifest.json" ] && missing_skills="$missing_skills $skill(manifest)"
  done
  [ -n "$missing_skills" ] && score_subtract 5 "Missing skills:$missing_skills"
else
  score_subtract 5 "Skills directory not found"
fi

# ============================================================
# Check 6: Bloat detection
# ============================================================

# Count completed items between "completed:" and next YAML key
completed_count=$(sed -n '/completed:/,/^[[:space:]]*- \*\*.*:/p' "$ROOT/RESUME.md" 2>/dev/null | grep -c '^[[:space:]]\{4\}- ' || echo 0)
[ "$completed_count" -gt $COMPLETED_MAX ] && score_subtract 3 "Completed list has $completed_count items (threshold $COMPLETED_MAX)"

# ============================================================
# Output
# ============================================================

[ $TOTAL_SCORE -lt 0 ] && TOTAL_SCORE=0

if [ $TOTAL_SCORE -ge 100 ]; then level="Healthy"
elif [ $TOTAL_SCORE -ge 90 ]; then level="Warning"
elif [ $TOTAL_SCORE -ge 70 ]; then level="Needs maintenance"
else level="Damaged"; fi

if [ "$MODE" = "check" ]; then
  echo ""
  echo "System health: $TOTAL_SCORE% - $level"
  if [ ${#ISSUES[@]} -gt 0 ]; then
    echo "Issues:"
    for issue in "${ISSUES[@]}"; do echo "  $issue"; done
    echo ""
    echo "Say 'clean' to auto-archive."
  else
    echo "All checks passed."
  fi

  # Update RESUME.md dashboard fields
  HEALTH_PCT="${TOTAL_SCORE}%"
  SEDOPT=""
  [[ "$OSTYPE" == "darwin"* ]] && SEDOPT=".bak"

  if grep -q '\*\*health_score\*\*:' "$RESUME_PATH" 2>/dev/null; then
    sed -i $SEDOPT "s/- \*\*health_score\*\*:.*/- **health_score**: $HEALTH_PCT/" "$RESUME_PATH"
  else
    sed -i $SEDOPT "s/- \*\*blocked_by\*\*:.*/&"$'\\\n'"- **health_score**: $HEALTH_PCT"$'\\\n'/"- **active_tasks**: (none)/" "$RESUME_PATH"
  fi

  # active_tasks from TASK_QUEUE
  ACTIVE_TASKS="(none)"
  if [ -f "$ROOT/TASK_QUEUE.md" ]; then
    ACTIVE=$(grep -E '^\| [0-9]+ \|' "$ROOT/TASK_QUEUE.md" 2>/dev/null | grep '进行中' | sed 's/^| [0-9]\+ | \([^|]*\).*/\1/' | tr -d ' ')
    [ -n "$ACTIVE" ] && ACTIVE_TASKS=$(echo "$ACTIVE" | paste -sd ', ' -)
  fi
  if grep -q '\*\*active_tasks\*\*:' "$RESUME_PATH" 2>/dev/null; then
    sed -i $SEDOPT "s/- \*\*active_tasks\*\*:.*/- **active_tasks**: $ACTIVE_TASKS/" "$RESUME_PATH"
  fi
fi

if [ "$MODE" = "clean" ]; then
  echo ""
  echo "Starting cleanup..."
  mkdir -p "$ARCHIVE_DIR" "$ARCHIVE_DIR/sessions"

  # Archive old session files
  if [ -d "$ROOT/.resume" ]; then
    declare -A task_sessions
    for sf in "$ROOT/.resume"/session-*.md; do
      [ ! -f "$sf" ] && continue
      tn=$(grep '\*\*task_name\*\*:' "$sf" 2>/dev/null | head -1 | sed 's/.*\*\*task_name\*\*:[[:space:]]*//')
      [ -z "$tn" ] && tn="unknown"
      task_sessions["$tn"]="${task_sessions[$tn]} $sf"
    done
    for tn in "${!task_sessions[@]}"; do
      files=(${task_sessions[$tn]})
      count=${#files[@]}
      if [ $count -gt $SESSION_MAX_PER_TASK ]; then
        for ((i=SESSION_MAX_PER_TASK; i<count; i++)); do
          fname=$(basename "${files[$i]}")
          mv "${files[$i]}" "$ARCHIVE_DIR/sessions/$fname"
          echo "  OK session: $fname -> archive/sessions/"
        done
      fi
    done
  fi

  # Archive old completed items
  if [ "$completed_count" -gt $COMPLETED_MAX ]; then
    excess=$((completed_count - COMPLETED_MAX))
    echo "  OK completed: $excess items would be archived (manual review recommended)"
  fi

  # Mark old decisions as stale
  if [ -f "$ROOT/DECISIONS.md" ] && [ "$dcount" -gt $DECISIONS_MAX ]; then
    echo "  OK decisions: $dcount entries (threshold $DECISIONS_MAX, manual review recommended)"
  fi

  echo ""
  echo "Archive saved to archive/ directory."
  echo "Re-run check to verify health score."
fi

[ $TOTAL_SCORE -ge 90 ] && exit 0 || exit 1
