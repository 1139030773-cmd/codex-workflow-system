# Changelog

所有对该项目的重大更改将在此文件中进行记录。

## [1.11.0] - 2026-06-12

### Added
- 📄 **PROJECT.md** — 项目总览，新手引导时创建，project-master 阶段更新

## [1.10.3] - 2026-06-11

### Removed
- 🗑️ **写入前层面自检** — 分类逻辑干扰铁律执行

## [1.10.2] - 2026-06-11

### Fixed
- 📦 **完整分发** — scripts/ + hooks/ 推送到插件仓库

## [1.10.1] - 2026-06-11

### Fixed
- 🔧 **phase-closeout 收尾/归档区分** — 新增步骤 0：先问再操作

## [1.10.0] - 2026-06-11

### Added
- 📦 **一键项目归档** — phase-closeout 归档模式 + INDEX.md + 自然语言触发

## [1.9.2] - 2026-06-11

### Added
- 🔁 **输出前自检第 4 问** — 重复建设预防
- 📡 **阶段切换自动审计** — 提醒 drift-auditor 检查

## [1.9.1] - 2026-06-11

### Added
- 📊 **项目驾驶舱** — RESUME.md 新增 health_score + active_tasks，health-check 自动更新

## [1.9.0] - 2026-06-11

### Added
- 🚪 **新手模式** — README 新手入口 + newbie-guide 术语过滤 + CLAUDE.md 新手频道规则

### Changed
- 🔧 **newbie-guide** — 输出改为纯人话，真相源静默执行

## [1.8.2] - 2026-06-11

### Added
- ⚡ **输出前自检** — CLAUDE.md 顶部新增强制执行三问
- 🚫 **写入前层面自检** — 开发内容不写入工作流文件
- 📌 **话题层面标定升级** — "必须执行" + 层面误判纠正

### Changed
- 🔧 **validate-version 扩展** — 检查项从 9 → 15 项

## [1.8.1] - 2026-06-11

### Added
- 🩺 **系统健康度检查** — `health-check.ps1` 启动时自动检测 RESUME/session/TASK_QUEUE/task_stack/DECISIONS/Skill 完整性
- 🧹 **系统清理归档** — `clean` 模式自动归档旧 session、旧 completed、标记 stale decisions
- 📁 `archive/` 目录 — 归档区，只移不删

### Changed
- 🔧 **CLAUDE.md 启动流程** — 新增第 2 步：版本检查 → 健康度 → 恢复

## [1.8.0] - 2026-06-11

### Added
- 📂 **多窗口 Session 管理** — `.resume/` 目录存放每个窗口独立的 session 文件，避免多窗口并行时互相覆盖
- 🔀 **"继续"多任务选择** — 多个活跃 session 时列出编号让用户选，单 session 直接展示，零 session fallback 到 RESUME.md
- 📝 **phase-closeout 增强** — 收尾时写 `.resume/{session-id}.md` + 根目录 RESUME.md 双位置

### Changed
- 🔧 **CLAUDE.md 启动恢复** — 从读单一 RESUME.md 改为扫描 `.resume/` 目录
- 🔧 **系统改动铁律步骤 4** — 从只更新 RESUME.md 扩展为 RESUME.md + .resume/ 双位置

## [1.7.7] - 2026-06-10

### Added
- ⏱️ **时间尺度感知** — task_stack 条目加 `created`/`last_active` 时间戳；decisions 加 `decided_at`；静置感知行为表；决策时效检查
- ⏱️ **漂移审计时间维度** — 同一任务静置 > 3 天自动触发审计介入；决策过期标记
- ⏱️ **四问自检时间问** — 新增问题 0："这个决策/任务放了多久了？时间过去了，情况变了吗？"
- 📜 **BEHAVIOR_SPEC 第十五章** — 时间尺度感知正式入宪

### Changed
- 🔧 **CLAUDE.md 时间间隔感知增强** — 从仅跨会话扩展到会话内也持续感知；新增任务静置感知 + 决策时效子表

## [1.7.6] - 2026-06-10

### Added
- 🌐 **英文适配** — README 双语（英文主 + 中文 README_CN）、plugin.json/marketplace.json 双语描述、newbie-guide 追问表中英双语
- 🌐 **语言自适应规则** — 所有 CLAUDE.md + newbie-guide 加语言检测规则：用户用什么语言提问，AI 用什么语言回应
- 📝 **推荐启动语** — README 新增 6 个场景的推荐启动语（中英双语）
- 📦 **Codex 安装方式改版** — 直接安装优先（CLI + URL），市场安装作备选

### Changed
- 🔧 **validate-version.ps1 增强** — 检查点从 4 个扩展到 8 个，新增 agent-workflow-system plugin.json 检查，防止版本号漏同步

## [1.7.5] - 2026-06-09

### Added
- 🔚 **技能出口协议** — learning-coach 教学结束时强制执行回任务格式交棒，不准自由发挥收尾

## [1.7.4] - 2026-06-09

### Added
- 📐 **回任务格式铁律** — 漂移后回任务层面必须用 🎯目标/📍进度/⚠️下一步 三行格式，缺一项算犯规

## [1.7.3] - 2026-06-09

### Added
- ⚓ **子任务锚定规则** — 开子任务时必须用父任务场景当练手材料，防止子任务飘走变纯理论课

### Fixed
- 🔧 agent-newbie-guide 新增启动自检（含锚定检查），宪法层规则现在有执行层检查兜底

## [1.7.2] - 2026-06-09

### Added
- 📋 **任务注册铁律** — 任何新任务开始必须在 task_stack 注册
- 🔄 **回任务层面背景复述** — 话题漂移后回任务时带目标+进度+下一步

## [1.7.1] - 2026-06-07

### Added
- 💬 **会话收尾提示** — 插件 CLAUDE.md 新增规则：用户说"暂停/走了/关窗/bye"时主动提醒收尾

## [1.7.0] - 2026-06-07

### Added
- 🔒 **任务收尾铁律** — 插件 CLAUDE.md 新增硬约束：关闭/归档任务前必须向用户确认
- 📁 **CLAUDE.md 拆分** — 开发规则（系统改动铁律）留在根目录，用户规则（恢复/单线程/语气等 8 条）移至插件目录

### Changed
- 🔧 根目录 CLAUDE.md 精简为仅含开发规则
- 🔧 插件新增独立 CLAUDE.md，装插件后自动对用户生效

## [1.6.3] - 2026-06-07

### Added
- 🔒 **任务收尾铁律** — 即使用户说效果不好，AI 也不能替用户判任务结束

## [1.6.2] - 2026-06-05

### Added
- 🔍 **实操验证优先** — CLAUDE.md 硬约束：验证必须直接执行实操（跑命令/调接口），禁止纯搜索文档推测
- 🗣️ **回复语气规范** — CLAUDE.md 硬约束：禁止简短否定甩结论、反问句、居高临下语气

## [1.6.1] - 2026-06-05

### Added
- ⏱️ **时间间隔感知** — 根据 last_session_end 计算间隔（小时/天/周），越久越先确认再动手
- 🔁 **全自动更新链路** — SessionEnd 自动 commit + push，SessionStart 自动 pull（24h 节流）
- 🔁 dev-push.ps1 / dev-push.sh — 开发者关窗口时自动推送系统改动到 GitHub
- 📋 **系统改动铁律** — CLAUDE.md 硬约束：改系统文件必须 5 步一口做完（同步→CHANGELOG→README→版本号→推送）
- 🚀 快速开始简化 — 零终端命令，聊天一句安装

### Changed
- 🔧 CLAUDE.md 新增时间间隔感知 + 系统改动铁律 + 自动化原则
- 🔧 README 新增自动更新链路说明 + 核心特性更新
- 🔧 双平台同步：CLAUDE.md ×2、phase-closeout SKILL.md ×2 全部更新

### Fixed
- 🐛 修复新窗口 AI 丢失用户偏好上下文（context_snapshot 填此缺口）
- 🐛 修复 AI 在多线程中同时扮演收尾者+执行者（单线程原则拦此行为）

## [1.6.0] - 2026-06-05

### Added
- 🧠 **context_snapshot** — RESUME.md 新增强制上下文快照字段（decisions/eliminated/user_style/landmarks/footguns）
- 🧠 新窗口恢复时 AI 必须先读取 context_snapshot 再开口，禁止重复问已决定的事
- 🔒 **单线程原则** — CLAUDE.md 新增硬约束：用户面前永远只推进一步，系统维护静默后台做
- 🔒 phase-closeout 收尾模板强制填写 context_snapshot

### Changed
- 🔧 CLAUDE.md 恢复流程新增 5 条恢复戒律
- 🔧 session-recovery.md memory 文件新增 context_snapshot 读取规则

## [1.5.1] - 2026-06-05

### Added
- 🔧 Windows session-start.ps1 — 四象限全覆盖恢复检测
- 🧹 CLAUDE.md 精简 + 智能恢复判断 + 上下文健康检查

### Changed
- 🔧 恢复触发改为智能判断（仅关键词触发，沉默/明确新任务跳过）
- 🔧 上下文健康自检：跨 3+ 话题建议收尾开新窗口

## [1.5.0] - 2026-06-05

### Added
- 🔄 会话恢复机制 — 自动检测未完成任务 (CLAUDE.md + RESUME.md)
- 🔄 四选项恢复 UI — 继续 / 暂缓 / 放弃 / 新项目
- 🔄 SessionEnd Hook — 关窗口自动 checkpoint（Windows: .ps1, Linux/Mac: .sh）
- 🔄 SessionStart Hook — 自动 git pull 更新（Linux/Mac: .sh）
- 🔄 恢复状态节点 — STATE_MACHINE.md 新增 [恢复] 状态和跳转规则
- 🔄 恢复感知 — 全部 7 个技能增加会话恢复自检步骤
- 🔄 BEHAVIOR_SPEC.md §14 — 新增"会话恢复机制"章节
- 🔄 EVIDENCE_CHAIN.md — 增加 RESUME.md 回滚目标和恢复记录格式
- 🔧 跨平台钩子系统 — bash 和 PowerShell 双实现
- 🔧 release.sh — Codex CLI 路径跨平台检测
- 📖 README.md — 项目根综合系统文档
- 📖 memory/ 目录 — session-recovery / active-task / MEMORY 持久化追踪

### Changed
- 🔧 phase-closeout — 新对话口令包含 CLAUDE.md + RESUME.md
- 🔧 workflow-system — 新增"恢复/继续上次任务"路由规则
- 🔧 settings.local.json — 双平台 SessionEnd + SessionStart hooks

## [1.4.0] - 2026-06-03

### Added
- 📦 Artifact 交接层 (BEHAVIOR_SPEC.md §13) — 技能间结构化产物传递
- 📦 5 个 Artifact 模板 — briefing/plan/patch/lesson/audit
- 📦 每个技能限定输入/输出 Artifact，禁止重复读取项目全貌

### Changed
- 🔧 全部 7 个技能新增 Artifact 输入/输出约束
- 🔧 上下文传递从 50k 聊天记录 → 5k 结构化产物

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
