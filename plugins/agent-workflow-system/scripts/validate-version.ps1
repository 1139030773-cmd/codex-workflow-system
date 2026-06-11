# 版本一致性校验脚本
# 检查 CHANGELOG.md（×2）、plugin.json（×2）、README.md（×6）、README_CN.md（×3）、marketplace.json 的版本号是否一致

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. 读 CHANGELOG 最新版本（取文件中第一个版本号条目）
$changelogVersion = (Select-String -Path "$root\CHANGELOG.md" -Pattern '## \[([\d.]+)\]' | Select-Object -First 1).Matches.Groups[1].Value
Write-Host "CHANGELOG.md  : $changelogVersion"

# 2. 读 plugin.json 版本
$pluginPath = "$root\plugins\plugins\agent-workflow-system\.codex-plugin\plugin.json"
$plugin = Get-Content $pluginPath -Raw | ConvertFrom-Json
$pluginVersion = $plugin.version
Write-Host "plugin.json   : $pluginVersion"

# 3. 读根目录 README 版本表第一个条目
$rootReadmeVersion = (Select-String -Path "$root\README.md" -Pattern '\| \*\*([\d.]+)\*\* \|' | Select-Object -First 1).Matches.Groups[1].Value
Write-Host "README.md     : $rootReadmeVersion"

# 4. 读插件目录 README 版本表第一个条目
$pluginReadmePath = "$root\plugins\plugins\agent-workflow-system\README.md"
$pluginReadmeVersion = (Select-String -Path $pluginReadmePath -Pattern '\| \*\*([\d.]+)\*\* \|' | Select-Object -First 1).Matches.Groups[1].Value
Write-Host "插件 README.md: $pluginReadmeVersion"

# 5. 读 agent-workflow-system-local README 版本表第一个条目
$localReadmePath = "$root\agent-workflow-system-local\README.md"
$localReadmeVersion = (Select-String -Path $localReadmePath -Pattern '\| \*\*([\d.]+)\*\* \|' | Select-Object -First 1).Matches.Groups[1].Value
Write-Host "本地 README.md: $localReadmeVersion"

# 5b. 读根目录 README_CN 版本表
$rootReadmeCNVersion = (Select-String -Path "$root\README_CN.md" -Pattern '\| \*\*([\d.]+)\*\* \|' | Select-Object -First 1).Matches.Groups[1].Value
Write-Host "README_CN.md  : $rootReadmeCNVersion"

# 5c. 读插件目录 README_CN 版本表
$pluginReadmeCNPath = "$root\plugins\plugins\agent-workflow-system\README_CN.md"
$pluginReadmeCNVersion = (Select-String -Path $pluginReadmeCNPath -Pattern '\| \*\*([\d.]+)\*\* \|' | Select-Object -First 1).Matches.Groups[1].Value
Write-Host "插件 README_CN: $pluginReadmeCNVersion"

# 5d. 读 agent-workflow-system-local README_CN 版本表
$localReadmeCNPath = "$root\agent-workflow-system-local\README_CN.md"
$localReadmeCNVersion = (Select-String -Path $localReadmeCNPath -Pattern '\| \*\*([\d.]+)\*\* \|' | Select-Object -First 1).Matches.Groups[1].Value
Write-Host "本地 README_CN: $localReadmeCNVersion"

# 5e. 检查所有 README 的规则版本范围（vX.X ~ vY.Y 尾部版本号）
$versionRangePattern = 'v[\d.]+ ~ v([\d.]+)'
$readmePaths = @(
    "$root\README.md",
    "$root\README_CN.md",
    $pluginReadmePath,
    $pluginReadmeCNPath,
    $localReadmePath,
    $localReadmeCNPath
)
$rangeIssues = @()
foreach ($p in $readmePaths) {
    $m = Select-String -Path $p -Pattern $versionRangePattern | Select-Object -First 1
    if ($m) {
        $rangeVersion = $m.Matches.Groups[1].Value
        $shortName = $p.Replace("$root\", "")
        Write-Host "版本范围 $shortName : $rangeVersion"
        if ($rangeVersion -ne $pluginVersion) {
            $rangeIssues += "$shortName 版本范围尾部 ($rangeVersion) 和 plugin.json ($pluginVersion) 不一致！"
        }
    }
}

# 6. 读 agent-workflow-system-local CHANGELOG 最新版本
$localChangelogPath = "$root\agent-workflow-system-local\CHANGELOG.md"
$localChangelogVersion = (Select-String -Path $localChangelogPath -Pattern '## \[([\d.]+)\]' | Select-Object -First 1).Matches.Groups[1].Value
Write-Host "本地 CHANGELOG: $localChangelogVersion"

# 7. 读 marketplace.json 版本
$marketplacePath = "$root\agent-workflow-system-local\.github\plugin\marketplace.json"
if (Test-Path $marketplacePath) {
    $marketplace = Get-Content $marketplacePath -Raw | ConvertFrom-Json
    $marketplaceVersion = $marketplace.version
    Write-Host "marketplace.json: $marketplaceVersion"
} else {
    $marketplaceVersion = $null
    Write-Host "marketplace.json: (文件不存在，跳过)"
}

# 8. 读 agent-workflow-system 仓库 plugin.json 版本
$agentPluginPath = "$root\agent-workflow-system-local\plugins\agent-workflow-system\.codex-plugin\plugin.json"
if (Test-Path $agentPluginPath) {
    $agentPlugin = Get-Content $agentPluginPath -Raw | ConvertFrom-Json
    $agentPluginVersion = $agentPlugin.version
    Write-Host "agent plugin.json: $agentPluginVersion"
} else {
    $agentPluginVersion = $null
    Write-Host "agent plugin.json: (文件不存在，跳过)"
}

# 9. 检查 plugins/ 仓库的 git tag
Push-Location "$root\plugins"
$latestTag = git tag -l "v*" --sort=-v:refname | Select-Object -First 1
Pop-Location
Write-Host "git tag       : $latestTag"

# 10. 逐一对比
$ok = $true
if ($changelogVersion -ne $pluginVersion) {
    Write-Host "❌ 根 CHANGELOG ($changelogVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($localChangelogVersion -ne $pluginVersion) {
    Write-Host "❌ 本地 CHANGELOG ($localChangelogVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($rootReadmeVersion -ne $pluginVersion) {
    Write-Host "❌ README.md ($rootReadmeVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($rootReadmeCNVersion -ne $pluginVersion) {
    Write-Host "❌ README_CN.md ($rootReadmeCNVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($pluginReadmeVersion -ne $pluginVersion) {
    Write-Host "❌ 插件 README.md ($pluginReadmeVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($pluginReadmeCNVersion -ne $pluginVersion) {
    Write-Host "❌ 插件 README_CN.md ($pluginReadmeCNVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($localReadmeVersion -ne $pluginVersion) {
    Write-Host "❌ 本地 README.md ($localReadmeVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($localReadmeCNVersion -ne $pluginVersion) {
    Write-Host "❌ 本地 README_CN.md ($localReadmeCNVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($marketplaceVersion -and $marketplaceVersion -ne $pluginVersion) {
    Write-Host "❌ marketplace.json ($marketplaceVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($agentPluginVersion -and $agentPluginVersion -ne $pluginVersion) {
    Write-Host "❌ agent plugin.json ($agentPluginVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($latestTag -and $latestTag -ne "v$pluginVersion") {
    Write-Host "❌ plugin.json (v$pluginVersion) 和最新 git tag ($latestTag) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($rangeIssues.Count -gt 0) {
    foreach ($issue in $rangeIssues) {
        Write-Host "❌ $issue" -ForegroundColor Red
    }
    $ok = $false
}

if ($ok) {
    Write-Host "✅ 版本一致：$pluginVersion" -ForegroundColor Green
    exit 0
} else {
    Write-Host "请先修正版本号再推送。" -ForegroundColor Red
    exit 1
}
