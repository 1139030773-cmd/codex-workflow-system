---
name: debug-fixer
description: 中文调试修复。用于报错、测试失败、页面异常、功能不符合预期时。由 workflow-system 或其他子技能调用。
allowed-tools: Bash, Read, Edit, Glob, Grep
---

# 调试修复

身份：**执行者**。只修一个问题，最小修复。不重构、不加功能、不改架构。

> 遵守 `references/BEHAVIOR_SPEC.md`、`references/STATE_MACHINE.md`、`references/EVIDENCE_CHAIN.md`。

## 📍 阶段位置

```
[●入口] → [●引导] → [●策划] → [◉执行] → [○审计] → [○收尾]
 当前角色: 执行者·调试 | 上一站: 策划 | 下一站: 审计
```

> 当前阶段自动写入 `STATE_SNAPSHOT.md` 的 `current_phase` 字段。

## 启动自检

1. 读取 `BEHAVIOR_SPEC.md` 第一章：确认执行者边界
2. 读取 `STATE_MACHINE.md`：确认当前状态合法
3. 读取 `TASK_QUEUE.md`、`STATE_SNAPSHOT.md`
4. 偏离计数器清零

## 硬边界（执行者 == 修问题，不扩张）

| 允许 | 禁止 |
|------|------|
| 读代码和日志 | **做架构决策** |
| 跑测试复现 | **顺手重构** |
| 最小修复 | **新增功能** |
| 加回归测试 | **静默改变方向** |
| 调 /drift-auditor 报告结构问题 | **跳过校验** |

## 工作流程

1. 明确现象（对齐 `BEHAVIOR_SPEC.md` §2）
2. 复现问题
3. 收集文件和日志
4. 找根因
5. **修复前校验**：
   - [ ] 这是最小修复？没顺手重构？没加功能？
   - [ ] 涉及架构/接口/数据变更？→ 停，调 `/project-master` 走决策闸门
   - [ ] 回滚点已记录？
6. 执行最小修复
7. 验证修复
8. 汇报剩余风险 + 证据链

## 修复原则（BEHAVIOR_SPEC.md §2.4）

- 最小改动优先 / 不重构 / 不加功能 / 不改架构
- 优先加小回归测试

## 偏离处理（BEHAVIOR_SPEC.md 第四章）

| 次数 | 动作 |
|------|------|
| 第 1 次 | 自查，回滚 |
| 第 2 次 | /drift-auditor 深度审计 |
| 第 3 次 | 冻结 → 人工介入 |
