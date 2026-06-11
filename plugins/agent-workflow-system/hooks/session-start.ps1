# Agent Workflow System — SessionStart Hook
# 1. Auto git pull (24h throttle)
# 2. Generate session ID for this window
# 3. Check remote plugin.json for newer version
# Called by .claude/settings.local.json SessionStart hook

param(
    [string]$ProjectDir = "c:\Users\11390\Documents\New project",
    [string]$MarketplaceDir = "$env:USERPROFILE\.claude\plugins\marketplaces\agent-workflow-system"
)

$TimeoutSec = 5

# ============================================================
# 1. Auto git pull (24h throttle)
# ============================================================

$StampFile = Join-Path $MarketplaceDir ".last-update-check"
$UpdateIntervalSec = 24 * 60 * 60

if (Test-Path $MarketplaceDir) {
    $skipPull = $false
    if (Test-Path $StampFile) {
        try {
            $lastCheck = [long](Get-Content $StampFile -Raw).Trim()
            $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
            if (($now - $lastCheck) -lt $UpdateIntervalSec) {
                $skipPull = $true
            }
        } catch { }
    }

    if (-not $skipPull) {
        try {
            $job = Start-Job -ScriptBlock {
                param($dir)
                Set-Location $dir; git pull --ff-only --quiet 2>$null
            } -ArgumentList $MarketplaceDir
            Wait-Job $job -Timeout $TimeoutSec | Out-Null
            Stop-Job $job -ErrorAction SilentlyContinue
            Remove-Job $job -Force -ErrorAction SilentlyContinue
        } catch { }
        try {
            [DateTimeOffset]::UtcNow.ToUnixTimeSeconds().ToString() | Set-Content $StampFile -NoNewline
        } catch { }
    }
}

# ============================================================
# 2. Generate session ID for this window
# ============================================================

$sessionId = "session-" + (Get-Date -Format "yyyyMMdd-HHmmss")
$sessionMarker = Join-Path $ProjectDir ".claude" ".current-session"
try {
    $sessionId | Set-Content $sessionMarker -NoNewline -Encoding UTF8
} catch { }

# ============================================================
# 3. Check remote plugin.json version
# ============================================================

$versionMarker = Join-Path $ProjectDir ".claude" ".version-check"

try {
    $localPluginPath = Join-Path $ProjectDir "plugins\plugins\agent-workflow-system\.codex-plugin\plugin.json"
    if (Test-Path $localPluginPath) {
        $localPlugin = Get-Content $localPluginPath -Raw | ConvertFrom-Json
        $localVersion = $localPlugin.version

        $remoteUrl = "https://raw.githubusercontent.com/1139030773-cmd/agent-workflow-system/main/plugins/agent-workflow-system/.codex-plugin/plugin.json"
        $remoteResult = Invoke-WebRequest -Uri $remoteUrl -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        $remotePlugin = $remoteResult.Content | ConvertFrom-Json
        $remoteVersion = $remotePlugin.version

        if ($remoteVersion -ne $localVersion) {
            # Compare as versions (not string)
            $localParts = [int[]]($localVersion -split '\.')
            $remoteParts = [int[]]($remoteVersion -split '\.')
            $isNewer = $false
            for ($i = 0; $i -lt [Math]::Max($localParts.Count, $remoteParts.Count); $i++) {
                $l = if ($i -lt $localParts.Count) { $localParts[$i] } else { 0 }
                $r = if ($i -lt $remoteParts.Count) { $remoteParts[$i] } else { 0 }
                if ($r -gt $l) { $isNewer = $true; break }
                if ($r -lt $l) { break }
            }
            if ($isNewer) {
                "newer|$remoteVersion|$localVersion" | Set-Content $versionMarker -NoNewline -Encoding UTF8
            } else {
                # Local is ahead or same major, clean up old marker
                Remove-Item $versionMarker -ErrorAction SilentlyContinue
            }
        } else {
            Remove-Item $versionMarker -ErrorAction SilentlyContinue
        }
    }
} catch {
    # Network error or file missing — silently skip
    Remove-Item $versionMarker -ErrorAction SilentlyContinue
}

exit 0
