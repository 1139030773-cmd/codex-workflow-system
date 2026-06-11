# Agent Workflow System

A Chinese-English bilingual AI workflow system for **Claude Code** and **Codex CLI**. Turns vague ideas into executable tasks through **7 collaborative skills** + **behavioral constitution** + **session recovery**. Beginner-friendly.

[中文文档 →](README_CN.md)

---

## 🚪 New Here? Start Here.

**You don't need to understand how this system works.** Just say what you want to do. The AI will guide you step by step — no jargon, no technical background required.

---

## ✨ Core Features

### 🔄 Session Recovery (v1.5.0+, enhanced through v1.7.x)

**Close the window, the task survives. New window, same AI.**

- **CLAUDE.md** — Auto-detects unfinished tasks on session start
- **RESUME.md + context_snapshot** — Checkpoint with decisions, preferences, and footgun prevention
- **Open-ended recovery** — No fixed options; AI presents status, you decide direction
- **⏱️ Time-interval awareness** — Adjusts behavior based on how long since last session
- **SessionEnd Hook** — Auto-saves checkpoint + commits on window close
- **SessionStart Hook** — Auto `git pull` on session start (24h throttle)
- **Cross-platform** — PowerShell + Bash

### 🔧 Setup (2 minutes)

**Step 1: Enable hooks** — Add this to your `.claude/settings.local.json`:

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "",
      "hooks": [
        {"type": "command", "command": "powershell.exe -File .claude/hooks/session-start.ps1", "timeout": 10}
      ]
    }],
    "SessionEnd": [{
      "matcher": "",
      "hooks": [
        {"type": "command", "command": "powershell.exe -File .claude/hooks/session-end.ps1", "timeout": 15}
      ]
    }]
  }
}
```

Hook scripts are in `hooks/` (copy to `.claude/hooks/`). Both `.ps1` and `.sh` versions available.

**Step 2: Run health check** — `scripts/health-check.ps1 check` for system integrity scan.

### 🔁 Auto-Update Pipeline

```
You change system → Close window → Hook auto commit + push
                                          ↓
                                     GitHub updated
                                          ↓
                          User opens window → Hook auto pull
```

### 🧠 7 Collaborative Skills

| Skill | Role | When |
|------|------|------|
| `workflow-system` | Orchestrator | Entry routing to the right sub-skill |
| `newbie-guide` | Guide | Vague goal → actionable task (Socratic questioning) |
| `project-master` | Planner | Task breakdown, decision gates, acceptance criteria |
| `debug-fixer` | Executor | Errors / test failures / bugs (TDD minimal fix) |
| `learning-coach` | Executor | Learning programming, design, languages, etc. |
| `drift-auditor` | Auditor | Scope creep / context drift / task fork detection |
| `phase-closeout` | Closer | Phase wrap-up, freeze state, generate resume token |

### 📜 Behavioral Constitution

14-chapter unified behavioral standard governing all skills:

- **Role isolation** — Planners don't code, executors don't make architectural decisions
- **Five-level error correction** — From self-check to mandatory human intervention
- **Legal awareness** — Three-layer risk alerts without giving legal advice
- **Artifact handoff** — 50k context → 5k artifact for lightweight inter-skill transfer
- **Session recovery** — Cross-session task continuity
- **Task forking & convergence** — Sub-tasks anchored to parent task context, auto-return on completion
- **Four-question self-check** — Before every change: logical? conflicts? important? right timing?
- **Time-scale awareness** — Tasks track created/last-active timestamps; stale decisions flagged for re-confirmation

**CLAUDE.md Rules (v1.6.2 ~ v1.10.3):**
- **Verify by doing** — Run commands, don't guess from docs
- **Tone standards** — Patient, equal, explain everything; no dismissive one-liners
- **Task closeout rule** — Never close a task without user confirmation
- **Topic layer awareness** — Recap what was done and where you stand in natural language
- **Four-question self-check** — Pre-implementation gate: logic / conflict / importance / timing
- **Task registration rule** — Every new task must be registered in task_stack before starting
- **Task fork & converge** — Sub-tasks inherit parent context; auto-return on completion
- **Return-to-task format** — After drift, resume with: goal / progress / next step
- **Time-scale awareness** — Real-world timestamps on tasks & decisions; auto-flag stale items after idle periods

---

## 🚀 Installation

### Claude Code

**Option 1: Ask Claude (Recommended)**

In chat:
```
Install agent-workflow-system for me
```

**Option 2: Manual**

```bash
git clone https://github.com/1139030773-cmd/agent-workflow-system.git
cp -r agent-workflow-system/.claude ./ && cp agent-workflow-system/CLAUDE.md . && cp agent-workflow-system/RESUME.md .
```

### Codex

**Option 1: CLI One-liner (Recommended)**

```bash
codex plugin install 1139030773-cmd/agent-workflow-system
```

**Option 2: Desktop App — Install from URL**

Settings → Plugins → Menu next to search → Install from URL:
```
https://raw.githubusercontent.com/1139030773-cmd/agent-workflow-system/main/plugins/agent-workflow-system/.codex-plugin/plugin.json
```

**Option 3: Marketplace (requires PR merge)**

```bash
codex plugin marketplace add https://github.com/hashgraph-online/awesome-codex-plugins.git
```
Then type `/plugins` in chat and find **Agent Workflow System**.

> 💡 Marketplace install depends on [PR #202](https://github.com/hashgraph-online/awesome-codex-plugins/pull/202). Use Option 1 or 2 in the meantime.

### Starter Prompts

After installation, try one of these:

| Scenario | Say |
|----------|-----|
| 🆕 Vague idea | "Start the newbie guide, help me turn my idea into tasks" |
| 📋 Manage a project | "Enter project master mode, help me manage this project" |
| 🐛 Something's broken | "Help me fix this bug" |
| 📖 Learn something | "I want to learn Python, make me a study plan" |
| 🔍 Feeling off-track | "Check if my progress has drifted" |
| 📦 Wrap up | "Help me do a phase closeout and organize what we did" |

> 💡 No commands to memorize. Speak naturally. The system auto-detects your language and intent.

---

## 📖 Version History

| Version | Date | Highlights |
|---------|------|-----------|
| **1.10.3** | 2026-06-11 | Removed write-level gate — classification interference |
| **1.10.2** | 2026-06-11 | Full distribution — scripts + hooks included in plugin package |
| **1.10.0** | 2026-06-11 | One-click project archive — INDEX.md + NL recall |
| **1.9.2** | 2026-06-11 | Output self-check Q4 + phase-transition auto audit |
| **1.9.1** | 2026-06-11 | Project dashboard — health_score + active_tasks in RESUME.md |
| **1.9.0** | 2026-06-11 | Beginner mode — newbie entry + jargon filter + beginner channel |
| **1.8.2** | 2026-06-11 | Output self-check + write-level gate — prevent dev content leaking into workflow |
| **1.8.1** | 2026-06-11 | System health check + auto-cleanup — integrity scan on every session start |
| **1.8.0** | 2026-06-11 | Multi-window session management — .resume/ per-window files prevent conflicts |
| **1.7.7** | 2026-06-10 | Time-scale awareness — task timestamps + decision expiry + idle detection |
| **1.7.6** | 2026-06-10 | English adaptation — bilingual README + language auto-detect + starter prompts |
| **1.7.5** | 2026-06-09 | Skill exit protocol + Return-to-task format rule |
| **1.7.4** | 2026-06-09 | Mandatory format for drift → task return |
| **1.7.3** | 2026-06-09 | Sub-task anchoring: parent context = practice material |
| **1.7.2** | 2026-06-09 | Task registration rule + background recap on return |
| **1.7.1** | 2026-06-07 | Session closeout reminder + Version consistency validator |
| **1.7.0** | 2026-06-07 | CLAUDE.md split (dev rules / user rules) |
| **1.6.3** | 2026-06-07 | Task closeout rule |
| **1.6.2** | 2026-06-05 | Verify by doing + Tone standards |
| **1.6.1** | 2026-06-05 | Time-interval awareness + 7-step change protocol + Auto-update pipeline |
| **1.6.0** | 2026-06-05 | context_snapshot + Single-thread principle |
| **1.5.0** | 2026-06-05 | Session recovery mechanism, cross-platform hooks |

See [CHANGELOG.md](https://github.com/1139030773-cmd/agent-workflow-system/blob/main/CHANGELOG.md) for full details.

---

## 🔗 Links

- GitHub: [1139030773-cmd/agent-workflow-system](https://github.com/1139030773-cmd/agent-workflow-system)
- Codex: `codex plugin install 1139030773-cmd/agent-workflow-system`
- Community Marketplace: [awesome-codex-plugins](https://github.com/hashgraph-online/awesome-codex-plugins)
- [中文文档](README_CN.md)

## 📄 License

MIT
