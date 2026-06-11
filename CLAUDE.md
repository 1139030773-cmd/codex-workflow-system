<!-- 每个新会话自动加载。不要删除。 -->

## ⚡ 输出前自检（每次回复前强制执行，不可跳过）

| 1 | **话题层面** | 这轮在聊什么范畴？ |
| 2 | **话题变了吗** | 变了 → 必须先话题标定再回复 |
| 3 | **要写文件吗** | 写了什么文件？层面匹配吗？（工作流文件 ≠ 开发内容） |
| 4 | **重复建设？** | completed 里有没有已经做过类似的事？ |

## 启动恢复检查

**只有以下情况才扫描 `.resume/` 走恢复流程：**

| 用户第一句话 | 行为 |
|-------------|------|
| "继续" / "接着" / "上次" / "恢复" | 扫描 `.resume/` 目录 → 按活跃 session 数量处理（见下方） |
| 沉默 / 明确新任务 | 跳过，不打扰 |

### 多 session 选择逻辑

```
扫描 .resume/ 下所有 session-*.md 文件，过滤 status=active

0 个活跃 session → fallback 读根目录 RESUME.md（向后兼容）
1 个活跃 session → 直接按 5 字段格式展示，问「接下来想怎么做？」
≥2 个活跃 session → 列出编号让用户选：
  | # | 任务 | 阶段 | 最后活跃 |
  |---|------|------|----------|
  | ① | {task_name} | {phase} | {last_updated} |
  | ② | {task_name} | {phase} | {last_updated} |
  回复 1/2 选择，或者说"新任务"跳过
```

用户选定后再按 5 字段格式展示，问「接下来想怎么做？」

### Session 文件格式

文件路径：`.resume/session-YYYYMMDD-HHmmss.md`（时间戳 = 收尾时刻）

每个文件结构与根目录 RESUME.md 一致，额外包含 `session_id` 字段：
```
- session_id: session-YYYYMMDD-HHmmss
- status: active | paused | completed
- task_name: ...
- phase: ...
- last_updated: ...
- completed: ...
- next_step: ...
- blocked_by: ...
- task_stack: ...
- context_snapshot: ...
- last_session_end: ...
```

### 收尾写文件规则

收尾时写两个位置：
1. `.resume/{session-id}.md` — 该窗口专属 checkpoint（主）
2. 根目录 `RESUME.md` — 向后兼容 fallback（副，只保留最新一个任务的信息）

同一任务多次收尾用不同 session ID → 自然产生多个文件 → "继续"时按 task_name 去重，只展示每条任务的最新文件。 |

## 版本更新检查

**SessionStart hook 已自动检查远程版本号并写入 `.claude/.version-check`。第一轮回复时读这个文件即可。**

文件格式：`newer|远程版本|本地版本`（只有远程 > 本地时才存在）

如果存在 → 提醒用户。不存在 → 版本一致，沉默。
无需手动 WebFetch。

## 系统健康度检查

**每次会话启动时，静默运行 `scripts/health-check.ps1 check`（或 `.sh`）。**

全部健康（≥90%）→ 沉默，不打扰用户。
有问题（<90%）→ 在第一轮回复末尾附加报告。

检测范围：RESUME 完整性、session 文件字段、TASK_QUEUE 损坏/孤儿引用、task_stack 孤儿任务、DECISIONS 完整性、Skill 组件、膨胀检测。

同脚本 `clean` 模式：自动归档旧 session 文件、旧 completed 条目、标记旧 decisions。只归档不删除。

## 系统改动铁律

**只要改了系统文件，以下 7 步必须一口气做完，不等用户催：**

| # | 步骤 | 说明 |
|---|------|------|
| 1 | **三目录同步** | ① 根目录 `c:\Users\11390\Documents\New project\`（CHANGELOG/README.md/README_CN.md/CLAUDE.md）② `plugins/agent-workflow-system/`（插件 CLAUDE.md 规则）③ `plugins/plugins/agent-workflow-system/`（plugin.json/skills） |
| 2 | **CHANGELOG** | 在对应版本条目下记录改动（Added/Changed/Fixed），**版本号必须与步骤 5 的 plugin.json 一致** |
| 3 | **README** | 如果改动影响功能描述，同步更新 README.md + README_CN.md 两份文件 |
| 4 | **RESUME.md + .resume/** | 如果改动涉及任务状态变更，同步更新 `.resume/{session-id}.md` + 根目录 RESUME.md（last_updated / completed / next_step / phase） |
| 5 | **版本号** | 如果是新功能/breaking change，同步更新 `plugin.json` + `marketplace.json` 版本，**版本号必须与步骤 2 的 CHANGELOG 一致** |
| 6 | **commit + push + release** | 在 `plugins/` 和 `agent-workflow-system` 仓库提交推送；打版本 tag；`gh release create` 创建 GitHub Release |
| 7 | **版本一致性验证** | 运行 `scripts/validate-version.ps1`（或 `.sh`），通过（显示 ✅）才算完成。不通过 → 回去补步骤 2 或 5，不准跳过 |

> **步骤 2 和 5 互相交叉引用**：改 CHANGELOG 时想着 plugin.json，改 plugin.json 时想着 CHANGELOG。两个版本号互为锚点，忘了一个会自相矛盾。

> **步骤 7 是硬卡点**：不读文件、不跑 `git tag` 确认 = 没改完。AI 不能凭"我记得改过了"跳过这步。

**违反信号**: 用户问"README 更新了吗"、"CHANGELOG 补了吗"、"推送了吗"、"Release 呢" = 你漏步骤了。

**自动化原则**: 同一件事用户让我做超过 3 次 → 把它写成规则或脚本，下次自动执行，不再让用户提醒。

## 四问自检

**每轮讨论得出改动结论后、动手改之前，先过四问。全过直接动手，有异常才提出来给用户确认。**

| # | 问题 | 检查内容 |
|---|------|---------|
| 1 | 逻辑成立吗？ | 说得通吗？因果链条完整吗？ |
| 2 | 跟已有的冲突吗？ | 重叠 / 矛盾 / 互补？已有规则能覆盖吗？ |
| 3 | 重要吗？ | 必须做 / 锦上添花 / 可做可不做？ |
| 4 | 该落地吗？ | 现在做还是以后做？做了会影响什么？ |

**四问全过 → 直接动手。有异常 → 提出来给用户确认。**

## 🚪 新手频道

**用户表达模糊目标或不确定如何开始时，自动进入新手频道——全程不使用任何系统术语。**

禁止对用户说：workflow、artifact、task_stack、checkpoint、skill 名、文件名。内部照常运转，表面只说人话。

## 📦 归档（自然语言触发）

用户说"我之前做的xxx还在吗""还有哪些做完的项目""看看归档"→ 读 `archive/INDEX.md` 回答。用户说"归档项目"→ 触发 phase-closeout 归档模式。

## 🌐 语言自适应

**用户用什么语言提问，就用什么语言回应。** 中文 → 中文；English → English。不预设语言偏好，不强制切换。

## 话题层面标定

**话题自然漂移时，用一句话帮用户回顾做了什么、现在站在哪。不贴标签，说人话。**

### 层面识别（内部自适应，不展示固定分类给用户）

不对话题做固定分类。从宏观上判断当前在聊什么范畴——是推进项目、调整系统、技术操作，还是情绪/状态/探索——然后自然描述，不套模板、不细化到具体动作。

### 什么时候说

| 时机 | 行为 |
|------|------|
| 话题切换（从一事跳到另一事） | 一句话收尾旧话题 + 定位当前 |
| 回到任务层面（漂移后拉回） | **强制格式（见下方"回任务格式铁律"），缺一项算犯规** |
| 一段完整的讨论结束 | 按时间顺序总结这段做了什么 |
| 用户问"刚才干了什么"/"现在在哪" | 给出时间线小结 |

### 回任务格式铁律

**对话漂移后回到任务层面，必须用以下格式，不准自由发挥：**

```
回到 [任务名]
🎯 目标：[一句话说清楚要达成什么]
📍 进度：[已经做到了哪一步]
⚠️ 下一步：[现在要做什么]
```

**三项缺一不可。** 忘了就用下一轮补上，不等用户提醒。

### 怎么说（格式 A — 按时间顺序、自然语言）

**话题切换时：**
```
刚才补了 CLAUDE.md 的恢复格式，顺手修了版本号不一致，
现在回到做网站首页。
```

**阶段收尾时：**
```
这一轮做了这些：
先修了 marketplace.json 版本号 → 提了 PR #202 → 然后调整了恢复展示格式。
现在这些收尾了，任务层面还在等你。
```

### 核心原则

- **说人话，不贴标签** — 用户不需要记住分类体系
- **按时间顺序** — 匹配用户的工作节奏
- **自适应** — 根据实际内容描述，不强行套固定层级
- **轻量** — 只在切换时一句带过，不每次回复都标注
