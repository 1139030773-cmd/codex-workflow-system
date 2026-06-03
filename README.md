# Agent Workflow 工作流系统

一套中文 AI 工作流系统，面向新手和非技术用户。**同时支持 Codex 和 Claude Code 两个平台。**

把模糊目标引导成可执行任务，并提供项目总控、学习教练、调试修复、漂移审计和阶段收尾能力。所有技能以 `agent-` 为前缀，代表可跨平台运行的智能体角色。

---

## 架构概览

```
[入口] → [引导] → [策划] → [执行] → [审计] → [收尾]
  ↑                   ↑        ↑        ↑        ↑
总调度              策划者   执行者    审计者   收尾者
(只调度)          (只规划) (只执行) (只诊断) (只冻结)
```

每个技能有明确的角色身份和硬边界权限。策划和执行隔离，审计只读不改，所有动作受统一行为规范约束。

---

## 包含的技能

| 技能 | 角色 | 用途 |
|------|------|------|
| `workflow-system` | 总调度 | 入口，自动判断任务类型并路由 |
| `agent-newbie-guide` | 引导者 | 把模糊想法变成可执行任务，苏格拉底式追问 |
| `agent-project-master` | 策划者 | 项目规划、任务拆分、决策闸门、并行派发 |
| `agent-debug-fixer` | 执行者 | 最小修复 + TDD 强制（测试先行），不重构不加功能 |
| `agent-learning-coach` | 执行者 | 讲-练-批改-复习循环，交互预算控制 |
| `agent-drift-auditor` | 审计者 | 只读诊断 + 代码审查（规格/重复/命名/安全），五级纠错 |
| `agent-phase-closeout` | 收尾者 | 冻结状态，汇总证据链 |

---

## 核心机制

### 统一行为规范
所有技能遵守同一套宪法：职能隔离、动作前校验、决策闸门、最小动作、回滚就绪。

### 人机分离原则
系统动作显式区分机器侧和人机接口侧。机器任务（扫描/测试/审计/记录）可并行不限量；交互任务强制串行，每次只给用户 1 个决策点，防止信息过载。

### 交互预算控制
每个技能输出前自检：本次是否只包含 1 个用户决策点？超过则拆分，逐个确认。

### 状态机锁定
技能之间有合法跳转表，不在路径上的跳转被拒绝或强制走审计中转。

### 五级纠错
| 级别 | 动作 |
|------|------|
| 第 1 级 | 自查纠正，记录证据链 |
| 第 2 级 | 审计者轻量诊断，输出纠正建议 |
| 第 3 级 | 深度检查 + 回滚到上一合法状态，暂停前进 |
| 第 4 级 | 冻结任务队列 + 完整偏离报告，标记人工介入 |
| 第 5 级 | 强制人工介入，系统锁定 |
| ≥5 级 | 等待人工解锁，停止所有自动动作 |

### 证据链追踪
每个动作记录：做了什么、对齐了哪条规范、验证结果、回滚点。阶段收尾时汇总到 `DECISIONS.md`。补充任务完成后自动验证与主任务的兼容性，有序收敛回主任务。

### 阶段位置指示器
每次启动技能时显示当前位置：
```
[●入口] → [●引导] → [◉策划] → [○执行] → [○审计] → [○收尾]
 当前角色: 策划者 | 上一站: 引导 | 下一站: 执行
```

### 共享真相源
四个文件贯穿所有技能：
- `PROJECT.md` — 项目目标、阶段、冻结区域
- `TASK_QUEUE.md` — 任务队列（只允许一个进行中）
- `DECISIONS.md` — 所有长期决策 + 证据链汇总
- `STATE_SNAPSHOT.md` — 当前状态快照 + 阶段位置

---

## 推荐启动语

```text
启动新手引导。我有一个模糊目标，请你一步一步问我，并把它变成可执行任务。
```

---

## 安装方式

### Codex

```bash
codex plugin marketplace add 1139030773-cmd/agent-workflow-system
```

然后在 Codex 中输入 `/plugins` 安装 "Codex 工作流系统"。

### Claude Code

将 `.claude/skills/` 目录复制到你的项目根目录下，重启 Claude Code 后即可使用 `/workflow-system` 等命令。

```bash
git clone https://github.com/1139030773-cmd/agent-workflow-system.git
cp -r agent-workflow-system/.claude/skills/ 你的项目/.claude/skills/
```

---

## 自动更新

### Claude Code

启用后每次启动自动检查更新，无需手动 `git pull`：

**1. 配置 SessionStart hook：**

在项目 `.claude/settings.json` 中添加：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "command": "bash ~/.claude/plugins/marketplaces/agent-workflow-system/hooks/session-start.sh"
      }
    ]
  }
}
```

**2. 或者全局生效**（所有项目自动更新），在 `~/.claude/settings.json` 中配置同上。

### Codex

Codex 暂不支持插件自动更新通知。推荐安装第三方工具：

```bash
npm i -g ai-tool-updater
```

安装后会自动监测 Claude Code、Codex 等 AI 工具的更新并通过系统通知提醒。

---

## 许可证

MIT
