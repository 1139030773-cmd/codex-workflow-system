# 发布检查清单

每次发布新版本前，逐项确认。全部打勾后再打 tag。

## 发布前

- [ ] **CHANGELOG.md** — 新版本条目已写，日期正确
- [ ] **README.md** — 新功能/机制已在核心机制或技能表中体现
- [ ] **marketplace.json** — 版本号已更新（`"version":"X.Y.Z"`，共 7 处）
- [ ] **BEHAVIOR_SPEC.md** — 新增规则已写入宪法
- [ ] **技能文件** — 所有受影响技能已修改

## 跨平台同步

- [ ] **Claude Code 版** — 项目根 `.claude/skills/` → `temp-desc/.claude/skills/`
- [ ] **Codex 版** — `temp-desc/skills/agent-*/` 已适配
- [ ] **插件包** — `temp-desc/plugins/agent-workflow-system/` 已同步
- [ ] **镜像** — `temp-readme2/` 已同步

## 发布

- [ ] **git commit** — 提交信息以版本号开头
- [ ] **git tag** — `vX.Y.Z` 附注标签（annotated tag）
- [ ] **git push** — 同时推送分支和标签
- [ ] **等待 CI** — GitHub Actions 自动创建 Release，确认显示为 Latest

## 发布后验证

- [ ] GitHub Releases 页显示新版本为 Latest
- [ ] Release Notes 内容正确（从 CHANGELOG 提取）
- [ ] `git clone` 新仓库验证文件完整
