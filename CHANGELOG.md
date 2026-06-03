# Changelog

所有对该项目的重大更改将在此文件中进行记录。

## [1.3.2] - 2026-06-03

### Fixed
- 🔧 同步所有清单文件版本号至 1.3.2
- 🔧 修复 auto-release workflow 版本校验失败

## [1.3.1] - 2026-06-03

### Fixed
- 🔧 修正 Claude Code 安装命令（mkdir -p 防止目录不存在报错）
- 🔧 安装方式改为新手友好 — Codex 用 /plugins，Claude Code 一行命令

## [1.3.0] - 2026-06-03

### Added
- 💬 提问规范 (BEHAVIOR_SPEC.md §9) — 所有提问必须带 2-4 个备选答案
- 🔍 能力前置检查 (BEHAVIOR_SPEC.md §10) — 执行前确认用户工具能力，不匹配则降级
- 🚧 扩展审查机制 (BEHAVIOR_SPEC.md §11) — 防止 0 用户时过度扩展，5 级门槛
- 📝 摩擦记录 (BEHAVIOR_SPEC.md §12) — 使用偏离信号收集，3 次触发审计
- 📋 发布流水线 (RELEASE_PIPELINE.md) — 确保每次改动送达双平台
- 📋 使用摩擦记录 (USAGE_FEEDBACK.md) — 首 3 条真实摩擦记录

### Changed
- 🔧 newbie-guide: 新增能力前置检查步骤（第三步）
- 🔧 learning-coach: 新增工具能力诊断
- 🔧 phase-closeout: 新增发布检查清单

## [1.2.0] - 2026-06-03

### Added
- ⚖️ 法律觉察机制 (BEHAVIOR_SPEC.md §8) — 知识产权/隐私/合规/安全/管辖冲突 5 类触发信号
- ⚖️ 三层拦截 — workflow-system → project-master → debug-fixer
- ⚖️ 硬边界：不引法条、不做违法判断、不阻止用户
- 🔧 Auto-Release CI — 推送 tag 自动创建 GitHub Release

## [1.1.0] - 2026-06-03

### Added
- ✨ TDD 硬约束 (debug-fixer) — 修复前强制测试先行，顺序：写测试→确认失败→修复→确认通过
- ✨ 代码审查维度 (drift-auditor) — 规格符合性/代码重复/命名规范/安全风险，三级严重程度（Critical/Warning/Info）
- ✨ 子代理并行派发 (project-master) — 机器任务可并行不限量，交互任务强制串行
- ✨ 苏格拉底追问 (newbie-guide) — 目标/约束/动机/经验/边界五种追问，每次只问 1 个
- ✨ 交互预算自检 — 全部技能增加认知负荷控制，每次输出 ≤1 个用户决策点
- 📖 人机分离原则 (BEHAVIOR_SPEC.md §7) — 显式定义机器侧和人机接口侧边界
- 📖 子任务收敛规则 (TASK_QUEUE.md + EVIDENCE_CHAIN.md) — 补充任务有序回归主任务

### Changed
- 🔧 project-master 并行派发规则修正 — 机器侧可并行不限量，人机接口侧强制串行
- 🔧 TASK_QUEUE.md 模板增加 `父任务` 和 `交互` 字段
- 🔧 全平台同步 — Claude Code 7 技能 + Codex 6 技能均保持一致

## [1.0.0] - 2026-05-31

### Added
- ✨ 新手引导 (agent-newbie-guide) - 帮助用户将模糊目标转化为可执行任务
- ✨ 项目总控 (agent-project-master) - 项目全局管理和进度跟踪
- ✨ 学习教练 (agent-learning-coach) - 个性化学习指导
- ✨ 调试修复 (agent-debug-fixer) - 代码问题诊断和修复
- ✨ 漂移检查 (agent-drift-auditor) - 项目偏离检查和审计
- ✨ 阶段收尾 (agent-phase-closeout) - 项目阶段总结
- 📦 完整的 marketplace.json 配置
- 📚 详细的 MARKETPLACE.md 发布指南
- 🔧 每个 skill 的 manifest.json 配置文件
- 📖 每个 skill 的 README.md 说明文档

### Initial Release
- 🎉 第一个公开发布版本
- 🌐 完整的中文支持
- 📋 MIT 开源协议
