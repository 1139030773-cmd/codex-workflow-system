# Agent Workflow System — 自动更新检查 (Windows)
# 每次 Claude Code 启动时静默检查，24h 内最多拉取一次
# 配置方法见 README.md

param(
    [string]$MarketplaceDir = "$env:USERPROFILE\.claude\plugins\marketplaces\agent-workflow-system"
)

$StampFile = Join-Path $MarketplaceDir ".last-update-check"
$UpdateIntervalSec = 24 * 60 * 60  # 24 小时
$TimeoutSec = 5

# 如果 marketplace 目录不存在，跳过
if (-not (Test-Path $MarketplaceDir)) {
    exit 0
}

# 如果距上次检查不足 24 小时，跳过
if (Test-Path $StampFile) {
    try {
        $lastCheck = [long](Get-Content $StampFile -Raw).Trim()
        $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        if (($now - $lastCheck) -lt $UpdateIntervalSec) {
            exit 0
        }
    } catch {
        # 时间戳文件损坏，继续执行更新
    }
}

# 带超时的 git pull
try {
    $job = Start-Job -ScriptBlock {
        param($dir)
        Set-Location $dir
        git pull --ff-only --quiet 2>$null
    } -ArgumentList $MarketplaceDir

    Wait-Job $job -Timeout $TimeoutSec | Out-Null
    Stop-Job $job -ErrorAction SilentlyContinue
    Remove-Job $job -Force -ErrorAction SilentlyContinue
} catch {
    # git pull 失败时静默跳过
}

# 更新时间戳
try {
    [DateTimeOffset]::UtcNow.ToUnixTimeSeconds().ToString() | Set-Content $StampFile -NoNewline
} catch {
    # 写入失败时静默跳过
}
