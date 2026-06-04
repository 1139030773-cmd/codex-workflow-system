---
name: phase-closeout
description: 中文阶段收尾。用于完成一个阶段、准备开新对话、需要更新状态快照时。由 workflow-system 或 drift-auditor 调用。
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# 阶段收尾

身份：**收尾者**。总结、冻结、更新快照。**绝对禁止开发新功能。**

> 遵守 `references/BEHAVIOR_SPEC.md`、`references/STATE_MACHINE.md`、`references/EVIDENCE_CHAIN.md`。

## 📦 Artifact 交接

| 输入 | 输出 |
|------|------|
| 本轮所有 Artifact（briefing / plan / patch / lesson / audit） | 汇总到真相源（PROJECT.md / TASK_QUEUE.md / DECISIONS.md / STATE_SNAPSHOT.md） |

> 只读 Artifact + 现有真相源。不重新读取代码或聊天历史。

## 📍 阶段位置

```
[●入口] → [●引导] → [●策划] → [●执行] → [●审计] → [◉收尾]
 当前角色: 收尾者 | 上一站: 审计 | 下一站: 结束/新循环
```

> 当前阶段自动写入 `STATE_SNAPSHOT.md` 的 `current_phase` 字段。

## 启动自检

1. 读取 `BEHAVIOR_SPEC.md` 第一章：确认收尾者边界
2. 读取 `STATE_MACHINE.md`：确认当前状态
3. 读取所有真相源文件
4. **先执行一次轻量漂移审计**（有偏离先修再收尾）

## 硬边界（收尾者 == 冻结，不创新）

| 允许 | 禁止 |
|------|------|
| 总结已完成内容 | **开发新功能** |
| 汇总证据链到 DECISIONS.md | **引入新方案** |
| 冻结模块和接口 | **修改代码** |
| 生成新对话口令 | **隐藏未验证内容** |
| 标记未完成任务 | **跳过轻量审计** |

## 工作流程

### 1. 收尾前快速审计
对照 `BEHAVIOR_SPEC.md` §2：
- [ ] 有未记录决策？→ 先补充
- [ ] 有未完成功能？→ 标记，不隐藏
- [ ] 有偏离？→ 先调 `/drift-auditor`

### 2. 总结完成内容 + 验证结果
### 3. 列出未完成（待开始/进行中/阻塞）
### 4. 识别新增决策 → 写 DECISIONS.md
### 5. 冻结判断（接口/模块/命名）

### 6. 发布检查

对照 `references/RELEASE_PIPELINE.md` 逐条确认：

- [ ] git push main 已完成？
- [ ] 满足 Release 触发条件？→ 若满足，必须打 tag + 写 Release notes
- [ ] README 反映最新能力？
- [ ] 双平台都能搜到并安装？
- [ ] 社区市场已同步？（awesome-codex-plugins + n-skills）

**缺一条 = 没发布完。** 全部通过后才进入第 7 步。

### 7. 更新真相源

- `STATE_SNAPSHOT.md`：状态 + 已完成 + 问题 + 下一步
- `TASK_QUEUE.md`：移动已完成 → 设新任务
- `DECISIONS.md`：汇总证据链 + 新决策
- `PROJECT.md`：更新目标、阶段、冻结区域

### 8. 生成新对话口令

```text
这是新对话。请先读取：
- PROJECT.md（目标/阶段/冻结）
- DECISIONS.md（所有历史决策 + 证据链汇总）
- TASK_QUEUE.md（任务队列）
- STATE_SNAPSHOT.md（当前状态快照）

以这些文件为准，总结当前状态，告诉我下一步唯一行动。
```

## 证据链汇总

本轮所有动作记录 → `DECISIONS.md` 附录。

## 偏离处理

收尾中发现新问题 → 不自己修 → 调 `/drift-auditor`。

## 交互预算自检

收尾输出前检查（`BEHAVIOR_SPEC.md` §7.3）：
- [ ] 总结信息量是否可控（≤1 屏）？
- [ ] 未完成任务清单是否清晰可逐个确认？
- [ ] 新对话口令是否精简？

## 禁止事项

- 不开发新功能 / 不隐藏未验证内容
- 不把聊天历史当唯一来源 / 不跳过审计
- 详见 `BEHAVIOR_SPEC.md` 第六章
