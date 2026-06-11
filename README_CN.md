# Agent Workflow System（智能工作流系统）

一套中文 AI 工作流系统，覆盖 Claude Code 和 Codex 双平台。通过 **7 个协作技能** + **行为规范宪法** + **会话恢复机制**，将模糊目标转化为可执行任务，在项目全生命周期中提供支持。

---

## ✨ 核心特性

### 🔄 会话恢复机制（v1.5.0 新增，v1.7.x 持续增强）

**窗口关了，任务还在。新窗口 AI 像同一个人。**

- **CLAUDE.md** — 每次新会话启动时自动检测未完成任务 + 单线程原则
- **RESUME.md** + **context_snapshot** — checkpoint + 用户偏好/决策记录/防犯错指南，新窗口 AI 不再"失忆"
- **开放式恢复对话** — 不再死板选项，AI 展示任务状态后由用户自由决定方向
- **⏱️ 时间间隔感知** — 根据距离上次会话的时间（小时/天/周）自动调整恢复策略，间隔越长越先确认再动手
- **SessionEnd Hook** — 关窗口时自动写入恢复点 + 自动 commit/push 系统更新
- **SessionStart Hook** — 每次启动自动 `git pull` 拉取最新版本（24h 节流）
- **跨平台支持** — PowerShell + Bash 双实现

### 🔁 全自动更新链路

**开发者改完关窗口 → 自动推送 GitHub → 用户开窗口自动拉取。零人工干预。**

```
你改系统 → 关窗口 → hook 自动 commit + push
                              ↓
                         GitHub 更新
                              ↓
              用户开窗口 → hook 自动 pull（24h 一次）
```

### 🧠 7 个协作技能

| 技能 | 角色 | 触发场景 |
|------|------|----------|
| `workflow-system` | 总调度 | 入口分类，自动路由到合适的子技能 |
| `newbie-guide` | 引导者 | 模糊目标 → 可执行任务（苏格拉底式追问） |
| `project-master` | 策划者 | 任务拆分、决策闸门、验收标准定义 |
| `debug-fixer` | 执行者 | 报错/测试失败/功能异常（TDD 最小修复） |
| `learning-coach` | 执行者 | 学习编程/英语/设计/AI（讲-练-批改-复习） |
| `drift-auditor` | 审计者 | 项目跑偏/上下文漂移/任务分叉检测 |
| `phase-closeout` | 收尾者 | 阶段结束、冻结状态、生成新对话口令 |

### 📜 行为规范宪法（BEHAVIOR_SPEC.md）

15 章统一行为规范，约束所有技能：

- **职能隔离** — 策划者不写代码，执行者不做架构决策
- **五级纠错** — 从自查到强制人工介入的逐级升级
- **法律觉察** — 三层法律风险提示，不越界判断
- **Artifact 交接层** — 50k 上下文 → 5k Artifact，轻量技能间传递
- **会话恢复** — 跨会话任务连续性（第 14 章）
- **时间尺度感知** — 任务和决策带真实时间戳，静置过期自动标记（第 15 章）
- **任务分叉与收敛** — 子任务锚定父任务场景，完成自动回归
- **四问自检** — 改动落地前先过逻辑/冲突/重要性/时机四关

**CLAUDE.md 规则体系（v1.6.2 ~ v1.8.1）：**
- **实操验证优先** — 验证必须直接执行命令/接口，禁止纯搜索文档推测
- **回复语气规范** — 禁止简短否定甩结论、反问句、居高临下语气
- **任务收尾铁律** — 关闭/归档任务前必须向用户确认，AI 禁止自作主张判任务结束
- **CLAUDE.md 拆分** — 根目录放开发规则，插件目录放用户规则，各司其职
- **会话收尾提示** — 用户表达离开意图时主动提醒收尾，避免上下文丢失
- **话题层面标定** — 话题漂移时用自然语言帮用户回顾做了什么、现在在哪，不贴标签，宏观自适应
- **四问自检** — 讨论得出改动结论后、动手改之前，先过四问：逻辑成立？冲突？重要？该做？
- **任务注册铁律** — 新任务开始前必须在 task_stack 注册，不注册不干活
- **任务分叉与收敛** — 子任务锚定父任务场景，收尾时自动提示回归主线
- **回任务格式铁律** — 漂移后回到任务层面必须用固定格式：目标/进度/下一步，缺一不可
- **时间尺度感知** — 任务和决策带真实时间戳，静置过期自动提醒

---

## 🚀 快速开始

### Claude Code

**方式一（推荐）：对话安装**

在聊天里说：
```
帮我安装 agent-workflow-system
```
Claude 会读取仓库并自动配置所有文件。

**方式二：手动安装**

```bash
git clone https://github.com/1139030773-cmd/agent-workflow-system.git
cp -r agent-workflow-system/.claude ./  && cp agent-workflow-system/CLAUDE.md . && cp agent-workflow-system/RESUME.md .
```

### Codex

**方式一：直接安装（推荐）**

在终端执行：
```bash
codex plugin install 1139030773-cmd/agent-workflow-system
```

**方式二：桌面版 Setting 手动添加**

Settings → Plugins → 搜索框右边菜单 → Install from URL → 输入：
```
https://raw.githubusercontent.com/1139030773-cmd/agent-workflow-system/main/plugins/agent-workflow-system/.codex-plugin/plugin.json
```

**方式三：通过市场源安装**

```bash
codex plugin marketplace add https://github.com/hashgraph-online/awesome-codex-plugins.git
```
然后在聊天框输入 `/plugins`，在列表中找到 **Agent Workflow System** 安装。

> 💡 市场安装依赖 [PR #202](https://github.com/hashgraph-online/awesome-codex-plugins/pull/202) 合入。审核期间请用方式一或方式二直接安装，效果一样。

### 推荐启动语

安装后在聊天框里任选一句开始：

| 场景 | 说什么 |
|------|--------|
| 🆕 有一个模糊想法 | "启动新手引导，帮我把想法变成任务" |
| 📋 想管一个项目 | "进入总控模式，帮我管理这个项目" |
| 🐛 代码报错了 | "帮我修一下这个 bug" |
| 📖 想学点东西 | "我想学 Python，帮我做个学习计划" |
| 🔍 感觉跑偏了 | "帮我检查一下现在的进度有没有跑偏" |
| 📦 阶段性收尾 | "帮我做阶段收尾，整理一下做了什么"

> 💡 不用记命令，说大白话就行。系统会自动识别你的意图并路由到合适的技能。

---

## 🏗️ 项目结构

```
.
├── CLAUDE.md                  # 会话启动自检 + 恢复检查
├── RESUME.md                  # 任务恢复点（自动 checkpoint）
├── README.md                  # 本文件
├── RELEASE_CHECKLIST.md       # 发布检查清单
├── PROJECT.md                 # 项目目标与范围
├── TASK_QUEUE.md              # 任务队列
├── DECISIONS.md               # 架构决策记录
├── STATE_SNAPSHOT.md          # 状态快照
├── .claude/
│   ├── skills/                # 7 个技能 + references
│   ├── hooks/                 # SessionEnd/SessionStart 脚本
│   └── settings.local.json    # Hook 配置
├── memory/                    # 持久化任务追踪
├── skills/agent-*/            # Codex 版技能
└── plugins/                   # 插件包
```

---

## 🔧 配置

### 启用会话恢复（推荐）

将以下文件复制到你的项目中：
- `CLAUDE.md` — AI 在每个新会话中自动读取
- `RESUME.md` — AI 在工作过程中自动更新
- `.claude/hooks/session-end.ps1` — Windows 关窗口自动保存
- `.claude/hooks/session-end.sh` — Linux/Mac 关窗口自动保存

### 启用自动更新（推荐）

```json
// .claude/settings.local.json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-start.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

---

## 📋 使用流程

```
开窗口 → AI 自动检测 RESUME.md
    │
    ├── 有未完成任务 → 展示任务状态（5 字段格式）
    │    ↓
    │    用户自由决定：继续 / 暂缓 / 放弃 / 开新任务
    │    （开放式提问，不穷举选项）
    │
    └── 无活跃任务 → 正常开始
         │
         说 "我想做..." → workflow-system 自动分类
         → 引导 → 策划 → 执行 → 审计 → 收尾
              │
              └── 每步自动更新 RESUME.md
```

---

## 📖 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|----------|
| **1.8.1** | 2026-06-11 | 🩺 系统健康度检查——启动时自动扫描完整性 + 自动清理归档 |
| **1.8.0** | 2026-06-11 | 📂 多窗口 Session 管理——.resume/ 独立文件防覆盖 + "继续"多任务选择 |
| **1.7.7** | 2026-06-10 | ⏱️ 时间尺度感知——任务时间戳 + 决策时效 + 静置检测 |
| **1.7.6** | 2026-06-10 | 🌐 英文适配——README 双语 + 语言自适应 + 推荐启动语 |
| **1.7.5** | 2026-06-09 | 🔚 技能出口协议：learning-coach 结束强制交棒 |
| **1.7.4** | 2026-06-09 | 📐 回任务格式铁律：🎯目标/📍进度/⚠️下一步 缺一不可 |
| **1.7.3** | 2026-06-09 | ⚓ 子任务锚定规则：父任务场景=练手材料 |
| **1.7.2** | 2026-06-09 | 📋 任务注册铁律 + 🔄 回任务层面背景复述 |
| **1.7.1** | 2026-06-07 | 💬 会话收尾提示 + 🔧 版本一致性校验 |
| **1.7.0** | 2026-06-07 | 📁 CLAUDE.md 拆分（开发规则 / 用户规则分离） |
| **1.6.3** | 2026-06-07 | 🔒 任务收尾铁律：禁止 AI 替用户判任务结束 |
| **1.6.2** | 2026-06-05 | 🔍 实操验证优先 + 🗣️ 回复语气规范 |
| **1.6.1** | 2026-06-05 | ⏱️ 时间间隔感知 + 📋 系统改动铁律 + 🔁 全自动更新链路 |
| **1.6.0** | 2026-06-05 | 🧠 context_snapshot 记忆快照 + 单线程原则 |
| **1.5.0** | 2026-06-05 | 🔄 会话恢复机制、跨平台 hooks、README |
| 1.4.1 | 2026-06-04 | 发布管线 + 社区市场同步 |
| 1.4.0 | 2026-06-03 | Artifact 交接层 + 交互预算 |

详见 [CHANGELOG.md](https://github.com/1139030773-cmd/agent-workflow-system/blob/main/CHANGELOG.md)

---

## 🤝 贡献

欢迎提交 Issue 和 PR。详见 [CONTRIBUTING.md](https://github.com/1139030773-cmd/agent-workflow-system/blob/main/CONTRIBUTING.md)

## 📄 许可

MIT License

## 🔗 链接

- GitHub: [1139030773-cmd/agent-workflow-system](https://github.com/1139030773-cmd/agent-workflow-system)
- Codex 市场: `/plugins add 1139030773-cmd/agent-workflow-system`
- 社区市场: [awesome-codex-plugins](https://github.com/hashgraph-online/awesome-codex-plugins)
