# Dev Auto-Push Hook (Windows)
# 关窗口时自动提交并推送系统改动到 GitHub
# 仅开发者环境有效（检测到 temp-desc 仓库才执行）

param(
    [string]$ProjectDir = "c:\Users\11390\Documents\New project"
)

$RepoDir = Join-Path $ProjectDir "temp-desc"

# 不是开发环境，跳过
if (-not (Test-Path (Join-Path $RepoDir ".git"))) {
    exit 0
}

try {
    Push-Location $RepoDir

    # 检查是否有未提交的改动
    $status = git status --porcelain 2>$null
    if (-not $status) {
        Pop-Location
        exit 0
    }

    # 自动提交
    $now = Get-Date -Format "yyyy-MM-dd HH:mm"
    git add -A 2>$null
    git commit -m "auto: session checkpoint — $now" --quiet 2>$null

    # 推送到远程
    git push origin main --quiet 2>$null

    Pop-Location
    Write-Output "DevPush: auto-committed and pushed at $now"
} catch {
    Pop-Location
    Write-Output "DevPush: skipped ($_)"
    exit 0
}
