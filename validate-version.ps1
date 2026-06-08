# 版本一致性校验脚本
# 检查 CHANGELOG.md、plugin.json、README.md（×2）的版本号是否一致

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. 读 CHANGELOG 最新版本（取文件中第一个版本号条目）
$changelogVersion = (Select-String -Path "$root\CHANGELOG.md" -Pattern '## \[([\d.]+)\]' | Select-Object -First 1).Matches.Groups[1].Value
Write-Host "CHANGELOG.md  : $changelogVersion"

# 2. 读 plugin.json 版本
$pluginPath = "$root\plugins\agent-workflow-system\.codex-plugin\plugin.json"
$plugin = Get-Content $pluginPath -Raw | ConvertFrom-Json
$pluginVersion = $plugin.version
Write-Host "plugin.json   : $pluginVersion"

# 3. 读根目录 README 版本表第一个条目
$rootReadmeVersion = (Select-String -Path "$root\README.md" -Pattern '\| \*\*([\d.]+)\*\* \|' | Select-Object -First 1).Matches.Groups[1].Value
Write-Host "README.md     : $rootReadmeVersion"

# 4. 读插件目录 README 版本表第一个条目
$pluginReadmePath = "$root\plugins\agent-workflow-system\README.md"
$pluginReadmeVersion = (Select-String -Path $pluginReadmePath -Pattern '\| \*\*([\d.]+)\*\* \|' | Select-Object -First 1).Matches.Groups[1].Value
Write-Host "插件 README.md: $pluginReadmeVersion"

# 5. 读 marketplace.json 版本
$marketplacePath = "$root\.github\plugin\marketplace.json"
$marketplace = Get-Content $marketplacePath -Raw | ConvertFrom-Json
$marketplaceVersion = $marketplace.version
Write-Host "marketplace.json: $marketplaceVersion"

# 6. 检查 git tag
$latestTag = git tag -l "v*" --sort=-v:refname | Select-Object -First 1
Write-Host "git tag       : $latestTag"

# 7. 逐一对比
$ok = $true
if ($changelogVersion -ne $pluginVersion) {
    Write-Host "❌ CHANGELOG ($changelogVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($rootReadmeVersion -ne $pluginVersion) {
    Write-Host "❌ README.md ($rootReadmeVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($pluginReadmeVersion -ne $pluginVersion) {
    Write-Host "❌ 插件 README.md ($pluginReadmeVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($marketplaceVersion -ne $pluginVersion) {
    Write-Host "❌ marketplace.json ($marketplaceVersion) 和 plugin.json ($pluginVersion) 不一致！" -ForegroundColor Red
    $ok = $false
}
if ($latestTag -and $latestTag -ne "v$pluginVersion") {
    Write-Host "❌ plugin.json (v$pluginVersion) 和最新 git tag ($latestTag) 不一致！" -ForegroundColor Red
    $ok = $false
}

if ($ok) {
    Write-Host "✅ 版本一致：$pluginVersion" -ForegroundColor Green
    exit 0
} else {
    Write-Host "请先修正版本号再推送。" -ForegroundColor Red
    exit 1
}
