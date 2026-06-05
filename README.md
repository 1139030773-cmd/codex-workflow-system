# Agent Workflow System（智能工作流系统）

一套中文 AI 工作流系统，覆盖 Claude Code 和 Codex 双平台。通过 **7 个协作技能** + **行为规范宪法** + **会话恢复机制**，将模糊目标转化为可执行任务，在项目全生命周期中提供支持。

---

## ✨ 核心特性

### 🔄 会话恢复机制（v1.5.0 新增，v1.6.0 增强）

**窗口关了，任务还在。新窗口 AI 像同一个人。**

- **CLAUDE.md** — 每次新会话启动时自动检测未完成任务 + 单线程原则
- **RESUME.md** + **context_snapshot** — checkpoint + 用户偏好/决策记录/防犯错指南，新窗口 AI 不再"失忆"
- **四选项恢复 UI** — 继续 / 暂缓 / 放弃 / 新项目，精准区分场景
- **SessionEnd Hook** — 关窗口时自动写入恢复点（Windows/Linux/Mac）
- **跨平台支持** — PowerShell + Bash 双实现

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

14 章统一行为规范，约束所有技能：

- **职能隔离** — 策划者不写代码，执行者不做架构决策
- **五级纠错** — 从自查到强制人工介入的逐级升级
- **法律觉察** — 三层法律风险提示，不越界判断
- **Artifact 交接层** — 50k 上下文 → 5k Artifact，轻量技能间传递
- **会话恢复** — 跨会话任务连续性（第 14 章）

---

## 🚀 快速开始

### Claude Code

```bash
# 1. 克隆仓库
git clone https://github.com/1139030773-cmd/agent-workflow-system.git
cd agent-workflow-system

# 2. 复制技能到项目
cp -r .claude/skills/* /你的项目/.claude/skills/
cp CLAUDE.md /你的项目/
cp RESUME.md /你的项目/

# 3. 配置 hooks（推荐，启用会话恢复和自动更新）
mkdir -p /你的项目/.claude/hooks/
cp .claude/hooks/session-end.sh /你的项目/.claude/hooks/
cp .claude/hooks/session-start.sh /你的项目/.claude/hooks/
```

### Codex

在 Codex 聊天中输入：
```
/plugins add 1139030773-cmd/agent-workflow-system
```

或通过 CLI：
```bash
codex plugin marketplace add 1139030773-cmd/agent-workflow-system
codex plugin add agent-workflow-system@agent-workflow-system
```

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
    ├── 有未完成任务 → ⚠️ 四选项 UI
    │    A. 继续 → 从上次中断处接着做
    │    B. 暂缓 → 保留进度，先做别的
    │    C. 放弃 → 删除恢复点
    │    D. 新项目 → 归档旧任务
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
