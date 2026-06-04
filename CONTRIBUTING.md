# 贡献指南

感谢你想为 Agent Workflow System 做贡献！

## 快速开始

1. Fork 本仓库
2. 克隆你的 fork：`git clone https://github.com/你的用户名/agent-workflow-system.git`
3. 在 `.claude/skills/` 下修改技能文件，在 `skills/agent-*/` 下修改 Codex 版
4. 提交前对照 [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) 确认

## 项目结构

```
├── .claude/skills/          # Claude Code 版技能（7 技能 + references）
│   ├── workflow-system/     # 总入口
│   ├── newbie-guide/        # 新手引导
│   ├── project-master/      # 项目总控
│   ├── debug-fixer/         # 调试修复
│   ├── learning-coach/      # 学习教练
│   ├── drift-auditor/       # 漂移审计
│   ├── phase-closeout/      # 阶段收尾
│   └── references/          # 统一行为规范、状态机、证据链
├── skills/agent-*/          # Codex 版技能（6 技能，agent- 前缀）
├── plugins/                 # 插件包
├── hooks/                   # 自动更新脚本
└── .github/                 # CI + Issue 模板
```

## 修改技能

1. **先改 Claude Code 版**（`.claude/skills/`）
2. **再适配 Codex 版**（`skills/agent-*/`）——注意命名差异和引用格式
3. **同步到插件包**（`plugins/agent-workflow-system/`）

Codex 版差异要点：
- 技能名加 `agent-` 前缀
- 引用其他技能也用 `agent-` 前缀（如 `agent-drift-auditor`）
- 无 `allowed-tools` 字段
- 无 `references/` 目录，规范内嵌在技能中

## 提交规范

- 提交信息格式：`类型: 简述`
- 类型：`feat`（新功能）、`fix`（修复）、`docs`（文档）、`ci`（CI/CD）
- 示例：`feat: 新增代码审查维度到 drift-auditor`

## 发布流程

参见 [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)。核心步骤：

1. 修改代码 + CHANGELOG + README + marketplace.json 版本号
2. 同步所有目录
3. `git tag -a vX.Y.Z` → `git push --tags`
4. CI 自动校验版本一致性 → 创建 Release

## 行为准则

- 所有修改必须对齐 `BEHAVIOR_SPEC.md`（统一行为规范）
- 不新增技能时不改变 `STATE_MACHINE.md`
- 跨平台同步不可遗漏
