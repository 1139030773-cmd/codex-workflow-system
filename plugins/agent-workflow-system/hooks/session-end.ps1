# Agent Workflow System — SessionEnd Hook
# 1. Update last_session_end in RESUME.md (backward compat fallback)
# 2. Create/update .resume/{session-id}.md (multi-window support, v1.8.0+)
# Called by .claude/settings.local.json SessionEnd hook

param(
    [string]$ProjectDir = "c:\Users\11390\Documents\New project"
)

$resumePath = Join-Path $ProjectDir "RESUME.md"
$resumeDir = Join-Path $ProjectDir ".resume"
$sessionMarker = Join-Path $ProjectDir ".claude" ".current-session"
$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$today = Get-Date -Format "yyyy-MM-dd"

# ============================================================
# 1. Update RESUME.md (fallback)
# ============================================================

if (Test-Path $resumePath) {
    try {
        $content = Get-Content $resumePath -Raw -Encoding UTF8

        # Update last_updated
        $content = $content -replace '- \*\*last_updated\*\*:.*', "- **last_updated**: $today"

        # Update last_session_end
        if ($content -notmatch 'last_session_end') {
            $content += "`n- **last_session_end**: $now`n"
        } else {
            $content = $content -replace '- \*\*last_session_end\*\*:.*', "- **last_session_end**: $now"
        }

        Set-Content $resumePath -Value $content -Encoding UTF8 -NoNewline
    } catch {
        # Non-fatal — .resume/ is the primary target now
    }
}

# ============================================================
# 2. Create/update .resume/{session-id}.md
# ============================================================

if (-not (Test-Path $resumeDir)) {
    try {
        New-Item -ItemType Directory -Path $resumeDir -Force | Out-Null
    } catch { }
}

# Read session ID from marker (written by SessionStart hook)
$sessionId = $null
if (Test-Path $sessionMarker) {
    try {
        $sessionId = (Get-Content $sessionMarker -Raw -Encoding UTF8).Trim()
    } catch { }
}
if (-not $sessionId) {
    $sessionId = "session-" + (Get-Date -Format "yyyyMMdd-HHmmss")
}

$sessionPath = Join-Path $resumeDir "$sessionId.md"

try {
    if (Test-Path $sessionPath) {
        # Session file exists (AI already did closeout) — update timestamps only
        $sfContent = Get-Content $sessionPath -Raw -Encoding UTF8
        $sfContent = $sfContent -replace '- \*\*last_updated\*\*:.*', "- **last_updated**: $today"
        if ($sfContent -notmatch 'last_session_end') {
            $sfContent += "`n- **last_session_end**: $now`n"
        } else {
            $sfContent = $sfContent -replace '- \*\*last_session_end\*\*:.*', "- **last_session_end**: $now"
        }
        Set-Content $sessionPath -Value $sfContent -Encoding UTF8 -NoNewline
    } elseif (Test-Path $resumePath) {
        # No session file yet (AI didn't do closeout) — create minimal from RESUME.md
        $resumeContent = Get-Content $resumePath -Raw -Encoding UTF8

        # Extract task_name from RESUME.md
        $taskName = "unknown"
        if ($resumeContent -match '- \*\*task_name\*\*:\s*(.+)$') {
            $taskName = $matches[1].Trim()
        }

        $minimalSession = @"
# 🔄 Task recovery point (auto-saved by SessionEnd hook)

> Auto-generated because no closeout was performed.

---

- **session_id**: $sessionId
- **status**: active
- **task_name**: $taskName
- **phase**: unknown
- **last_updated**: $today
- **completed**: (auto-saved — run closeout for full context)
- **next_step**: Recover from last session
- **blocked_by**: (none)
- **task_stack**:
  - name: $taskName
    goal: (not recorded)
    progress: (not recorded)
    next_step: Recover from last session
    parent: null
    created: $today
    last_active: $today
- **context_snapshot**:
  - decisions: (run closeout to populate)
  - eliminated: (run closeout to populate)
  - user_style: (run closeout to populate)
  - landmarks: (auto-saved)
  - footguns: (run closeout to populate)

---

- **last_session_end**: $now
"@
        Set-Content $sessionPath -Value $minimalSession -Encoding UTF8 -NoNewline
    }
} catch {
    # Non-fatal
}

# Clean up session marker
Remove-Item $sessionMarker -ErrorAction SilentlyContinue

exit 0
