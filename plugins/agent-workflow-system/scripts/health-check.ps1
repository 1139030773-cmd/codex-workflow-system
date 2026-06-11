# System Health Check Script
# Modes: check (detect issues) / clean (archive old data)
# Runs silently on session start, reports only when issues found.

param(
    [ValidateSet("check", "clean")]
    [string]$Mode = "check"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# ============================================================
# Configuration
# ============================================================

$REQUIRED_SESSION_FIELDS = @("session_id", "status", "task_name", "phase", "last_updated", "next_step", "last_session_end")
$VALID_STATUSES = @("active", "paused", "completed", "inactive", "abandoned")
$COMPLETED_MAX = 15
$DECISIONS_MAX = 20
$SESSION_MAX_PER_TASK = 2
$ARCHIVE_DIR = "$root\archive"

# ============================================================
# Utilities
# ============================================================

function Score-Subtract($amount, $reason) {
    $script:totalScore = [Math]::Max(0, $script:totalScore - $amount)
    $script:issues += "[ -$amount ] $reason"
}

function Parse-YamlList($content, $fieldName) {
    $items = @()
    $inTarget = $false
    foreach ($line in ($content -split "`n")) {
        if ($line -match "^\s*-\s*\*\*$([regex]::Escape($fieldName))\*\*:") { $inTarget = $true; continue }
        if ($inTarget -and $line -match "^\s{4}-\s+(.+)$") {
            $items += $matches[1].Trim()
        }
        if ($inTarget -and $line -match "^\s*-\s*\*\*" -and $line -notmatch "$([regex]::Escape($fieldName))") { $inTarget = $false }
    }
    return $items
}

# ============================================================
# Global state
# ============================================================

$totalScore = 100
$issues = @()
$details = @{}

# ============================================================
# Check 1: RESUME.md + .resume/ session files
# ============================================================

if (-not (Test-Path "$root\RESUME.md")) {
    Score-Subtract 15 "RESUME.md file missing"
    $details["resume"] = "missing"
} else {
    $resumeContent = Get-Content "$root\RESUME.md" -Raw
    if ($resumeContent.Length -lt 10) {
        Score-Subtract 10 "RESUME.md empty or corrupted"
        $details["resume"] = "corrupted"
    } else {
        $details["resume"] = "ok"
    }
}

if (-not (Test-Path "$root\.resume")) {
    Score-Subtract 5 ".resume/ directory missing"
    $details["resume_dir"] = "missing"
} else {
    $sessionFiles = @(Get-ChildItem "$root\.resume" -Filter "session-*.md" -ErrorAction SilentlyContinue)
    $details["resume_dir"] = "$($sessionFiles.Count) session files"

    $taskSessionCounts = @{}
    foreach ($sf in $sessionFiles) {
        $sfContent = Get-Content $sf.FullName -Raw
        $missingFields = @()
        foreach ($field in $REQUIRED_SESSION_FIELDS) {
            if ($sfContent -notmatch "- \*\*$([regex]::Escape($field))\*\*:") {
                $missingFields += $field
            }
        }
        if ($missingFields.Count -gt 0) {
            Score-Subtract 5 "$($sf.Name): missing fields $($missingFields -join ', ')"
        }

        if ($sfContent -match '- \*\*status\*\*:\s*(\S+)') {
            $statusVal = $matches[1]
            if ($statusVal -notin $VALID_STATUSES) {
                Score-Subtract 3 "$($sf.Name): invalid status '$statusVal'"
            }
            if ($statusVal -eq "active") {
                if ($sfContent -match '- \*\*task_name\*\*:\s*(.+)$') {
                    $tn = $matches[1].Trim()
                    if ($taskSessionCounts.ContainsKey($tn)) { $taskSessionCounts[$tn]++ } else { $taskSessionCounts[$tn] = 1 }
                }
            }
        }

        if ($sfContent -match '- \*\*session_id\*\*:\s*(\S+)') {
            $sid = $matches[1]
            if ($sid -notmatch '^session-\d{8}-\d{6}$') {
                Score-Subtract 3 "$($sf.Name): invalid session_id format '$sid'"
            }
        }
    }

    foreach ($tn in $taskSessionCounts.Keys) {
        $count = $taskSessionCounts[$tn]
        if ($count -gt $SESSION_MAX_PER_TASK) {
            Score-Subtract 3 "Task '$tn' has $count active sessions (threshold $SESSION_MAX_PER_TASK)"
        }
    }
}

# ============================================================
# Check 2: TASK_QUEUE.md
# ============================================================

if (-not (Test-Path "$root\TASK_QUEUE.md")) {
    Score-Subtract 5 "TASK_QUEUE.md file missing"
    $details["task_queue"] = "missing"
} else {
    $tqContent = Get-Content "$root\TASK_QUEUE.md" -Raw
    $tqLines = $tqContent -split "`n"

    $taskRows = @()
    $taskIds = @{}
    $inTable = $false
    foreach ($line in $tqLines) {
        if ($line -match '^\| # \|') { $inTable = $true; continue }
        if ($line -match '^\|[-| ]+\|$') { continue }
        if ($inTable -and $line -match '^\| (\d+) \| (.+)$') {
            $num = [int]$matches[1]
            $rest = $matches[2]
            $cells = $rest -split '\|'
            if ($cells.Count -ge 6) {
                $taskName = $cells[0].Trim()
                $parent = $cells[1].Trim()
                $status = $cells[2].Trim()
                $taskRows += @{ num = $num; name = $taskName; parent = $parent; status = $status }
                $taskIds[$num] = $true
            }
        }
        if ($inTable -and $line -notmatch '^\|') { $inTable = $false }
    }

    if ($taskRows.Count -eq 0) {
        Score-Subtract 2 "TASK_QUEUE has no task entries"
    }

    foreach ($row in $taskRows) {
        if ($row.parent -match '^#(\d+)$') {
            $refNum = [int]$matches[1]
            if (-not $taskIds.ContainsKey($refNum)) {
                Score-Subtract 5 "TASK_QUEUE: #$($row.num) parent #$refNum not found"
            }
        }
    }

    $seenNums = @{}
    foreach ($row in $taskRows) {
        if ($seenNums.ContainsKey($row.num)) {
            Score-Subtract 3 "TASK_QUEUE: duplicate task number #$($row.num)"
        }
        $seenNums[$row.num] = $true
    }

    $details["task_queue"] = "$($taskRows.Count) tasks"
}

# ============================================================
# Check 3: task_stack orphans + context_snapshot completeness
# ============================================================

$allTaskNames = @{}
$allParents = @()
$stackSources = @("$root\RESUME.md")
if (Test-Path "$root\.resume") {
    $stackSources += (Get-ChildItem "$root\.resume" -Filter "session-*.md" -ErrorAction SilentlyContinue).FullName
}

foreach ($src in $stackSources) {
    $srcContent = Get-Content $src -Raw
    $inStack = $false
    $lines = $srcContent -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match 'task_stack:') { $inStack = $true; continue }
        if ($inStack -and $line -match '^\s{4}-\s*name:\s*(.+)$') {
            $taskName = $matches[1].Trim()
            $allTaskNames[$taskName] = $true
        }
        if ($inStack -and $line -match '^\s{6}parent:\s*(.+)$') {
            $parentName = $matches[1].Trim()
            if ($parentName -ne "null") {
                $allParents += @{ child = $taskName; parentRef = $parentName; source = $src }
            }
        }
        if ($inStack -and $line -match 'context_snapshot:') { $inStack = $false }
        if ($inStack -and $line -match '^\s{2}- \*\*') { $inStack = $false }
    }
}

foreach ($p in $allParents) {
    if (-not $allTaskNames.ContainsKey($p.parentRef)) {
        $shortName = (Split-Path $p.source -Leaf)
        Score-Subtract 8 "Orphan task_stack: '$($p.child)' parent '$($p.parentRef)' not found (source: $shortName)"
    }
}

$csContent = Get-Content "$root\RESUME.md" -Raw
$csBlocks = @("decisions", "eliminated", "user_style", "landmarks", "footguns")
$missingCS = @()
foreach ($blockName in $csBlocks) {
    if ($csContent -notmatch ('- ' + $blockName + ':')) {
        $missingCS += $blockName
    }
}
if ($missingCS.Count -gt 0) {
    Score-Subtract 5 "context_snapshot missing blocks: $($missingCS -join ', ')"
}

$details["task_stack"] = "$($allTaskNames.Count) task names, $($allParents.Count) parent refs"

# ============================================================
# Check 4: DECISIONS.md
# ============================================================

if (-not (Test-Path "$root\DECISIONS.md")) {
    Score-Subtract 3 "DECISIONS.md file missing"
    $details["decisions"] = "missing"
} else {
    $dContent = Get-Content "$root\DECISIONS.md" -Raw
    $dCount = ([regex]::Matches($dContent, '^## D\d+', 'Multiline')).Count
    $details["decisions"] = "$dCount decisions"

    if ($dCount -gt $DECISIONS_MAX) {
        Score-Subtract 3 "DECISIONS has $dCount entries (threshold $DECISIONS_MAX)"
    }

    $dDates = ([regex]::Matches($dContent, '\*\*(date|日期)\*\*[：:]\s*\S+', 'Multiline')).Count
    if ($dDates -lt $dCount) {
        Score-Subtract 3 "DECISIONS: $($dCount - $dDates) entries missing date field"
    }
}

# ============================================================
# Check 5: Skill component integrity
# ============================================================

$skillsDir = "$root\plugins\plugins\agent-workflow-system\skills"
if (Test-Path $skillsDir) {
    $expectedSkills = @(
        "agent-debug-fixer",
        "agent-drift-auditor",
        "agent-learning-coach",
        "agent-newbie-guide",
        "agent-phase-closeout",
        "agent-project-master"
    )
    $missingSkills = @()
    foreach ($skill in $expectedSkills) {
        $skillPath = "$skillsDir\$skill"
        if (-not (Test-Path $skillPath)) {
            $missingSkills += $skill
        }
        $manifestPath = "$skillPath\manifest.json"
        if (-not (Test-Path $manifestPath)) {
            if ($skill -notin $missingSkills) { $missingSkills += "$skill (no manifest)" }
        }
    }
    if ($missingSkills.Count -gt 0) {
        Score-Subtract 5 "Missing skills: $($missingSkills -join ', ')"
    }
    $details["skills"] = "$($expectedSkills.Count) skills"
} else {
    Score-Subtract 5 "Skills directory not found"
    $details["skills"] = "missing"
}

# ============================================================
# Check 6: Bloat detection (completed / decisions)
# ============================================================

$resumeContent = Get-Content "$root\RESUME.md" -Raw
$completedItems = Parse-YamlList $resumeContent "completed:"
$completedCount = $completedItems.Count
$details["completed"] = "$completedCount completed items"

if ($completedCount -gt $COMPLETED_MAX) {
    Score-Subtract 3 "Completed list has $completedCount items (threshold $COMPLETED_MAX)"
}

# ============================================================
# Output
# ============================================================

$totalScore = [Math]::Max(0, $totalScore)

if ($totalScore -ge 100) { $level = "Healthy" }
elseif ($totalScore -ge 90) { $level = "Warning" }
elseif ($totalScore -ge 70) { $level = "Needs maintenance" }
else { $level = "Damaged" }

if ($Mode -eq "check") {
    Write-Host ""
    Write-Host "System health: $totalScore% - $level"

    if ($issues.Count -gt 0) {
        Write-Host "Issues:"
        foreach ($issue in $issues) {
            Write-Host "  $issue"
        }
        Write-Host ""
        Write-Host "Say 'clean' to auto-archive."
    } else {
        Write-Host "All checks passed."
    }

    # Update RESUME.md dashboard fields
    $resumeContent = Get-Content "$root\RESUME.md" -Raw -Encoding UTF8

    # health_score
    $healthPct = "$totalScore%"
    if ($resumeContent -match '- \*\*health_score\*\*:') {
        $resumeContent = $resumeContent -replace '- \*\*health_score\*\*:.*', "- **health_score**: $healthPct"
    } else {
        $insertAfter = '- \*\*blocked_by\*\*:'
        $newLine = "- **health_score**: $healthPct`n- **active_tasks**: (none)"
        $resumeContent = $resumeContent -replace $insertAfter, "$insertAfter`n$newLine"
    }

    # active_tasks from TASK_QUEUE (status contains "进行中")
    $activeTasks = @()
    if (Test-Path "$root\TASK_QUEUE.md") {
        $tqContent = Get-Content "$root\TASK_QUEUE.md" -Raw
        $tqLines = $tqContent -split "`n"
        foreach ($line in $tqLines) {
            if ($line -match '^\| (\d+) \| (.+)$') {
                $rest = $matches[2]
                $cells = $rest -split '\|'
                if ($cells.Count -ge 6) {
                    $taskName = $cells[0].Trim()
                    $status = $cells[2].Trim()
                    if ($status -match '进行中') {
                        $activeTasks += $taskName
                    }
                }
            }
        }
    }
    $activeTasksStr = if ($activeTasks.Count -gt 0) { ($activeTasks -join ', ') } else { "(none)" }
    if ($resumeContent -match '- \*\*active_tasks\*\*:') {
        $resumeContent = $resumeContent -replace '- \*\*active_tasks\*\*:.*', "- **active_tasks**: $activeTasksStr"
    }
    Set-Content "$root\RESUME.md" -Value $resumeContent -Encoding UTF8 -NoNewline
}

if ($Mode -eq "clean") {
    Write-Host ""
    Write-Host "Starting cleanup..."

    if (-not (Test-Path $ARCHIVE_DIR)) {
        New-Item -ItemType Directory -Path $ARCHIVE_DIR -Force | Out-Null
        New-Item -ItemType Directory -Path "$ARCHIVE_DIR\sessions" -Force | Out-Null
    }

    $archived = @()

    # Clean 1: Archive old session files (>2 per task)
    if (Test-Path "$root\.resume") {
        $allSessions = @(Get-ChildItem "$root\.resume" -Filter "session-*.md" | Sort-Object LastWriteTime -Descending)
        $taskGroups = @{}
        foreach ($sf in $allSessions) {
            $sfc = Get-Content $sf.FullName -Raw
            if ($sfc -match '- \*\*task_name\*\*:\s*(.+)$') {
                $tn = $matches[1].Trim()
                if (-not $taskGroups.ContainsKey($tn)) { $taskGroups[$tn] = @() }
                $taskGroups[$tn] += $sf
            }
        }
        foreach ($tn in $taskGroups.Keys) {
            $group = $taskGroups[$tn]
            if ($group.Count -gt $SESSION_MAX_PER_TASK) {
                for ($i = $SESSION_MAX_PER_TASK; $i -lt $group.Count; $i++) {
                    $old = $group[$i]
                    $dest = "$ARCHIVE_DIR\sessions\$($old.Name)"
                    Move-Item $old.FullName $dest -Force
                    $archived += "session: $($old.Name) -> archive/sessions/"
                }
            }
        }
    }

    # Clean 2: Archive old completed items
    if ($completedCount -gt $COMPLETED_MAX) {
        $archiveCompleted = "$ARCHIVE_DIR\completed-archive.md"
        $excess = $completedItems[$COMPLETED_MAX..($completedItems.Count - 1)]
        $archiveContent = @"
# Completed Archive

> Archived: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
> Kept latest $COMPLETED_MAX entries.

$($excess | ForEach-Object { "- $_" } | Out-String)
"@
        Add-Content -Path $archiveCompleted -Value $archiveContent
        $archived += "completed: $($excess.Count) items -> archive/completed-archive.md"
    }

    # Clean 3: Mark old decisions as potentially stale
    if ($dCount -gt $DECISIONS_MAX) {
        $dContent = Get-Content "$root\DECISIONS.md" -Raw
        $dLines = $dContent -split "`n"
        $decisionDates = @{}
        $decisionLines = @{}
        $currentD = $null
        for ($i = 0; $i -lt $dLines.Count; $i++) {
            if ($dLines[$i] -match '^## (D\d+)') {
                $currentD = $matches[1]
                $decisionLines[$currentD] = $i
            }
            if ($currentD -and $dLines[$i] -match '\*\*date\*\*[：:]\s*(\S+)') {
                $decisionDates[$currentD] = $matches[1]
            }
        }
        $sortedD = $decisionDates.GetEnumerator() | Sort-Object { $_.Value }
        $toMark = [Math]::Min(10, $sortedD.Count)
        $updated = $false
        for ($i = 0; $i -lt $toMark; $i++) {
            $dId = $sortedD[$i].Key
            $lineNum = $decisionLines[$dId]
            if ($dLines[$lineNum] -notmatch '\[stale\]') {
                $dLines[$lineNum] = $dLines[$lineNum] -replace '^(## D\d+)', '$1 [stale]'
                $updated = $true
            }
        }
        if ($updated) {
            $dLines -join "`n" | Set-Content -Path "$root\DECISIONS.md" -Encoding UTF8
            $archived += "decisions: marked $toMark old entries as [stale]"
        }
    }

    if ($archived.Count -gt 0) {
        Write-Host ""
        foreach ($a in $archived) {
            Write-Host "  OK $a"
        }
        Write-Host ""
        Write-Host "Archive saved to archive/ directory."
    } else {
        Write-Host "  Nothing to clean."
    }

    Write-Host ""
    Write-Host "Re-run check to verify health score."
}

exit $(if ($totalScore -ge 90) { 0 } else { 1 })
