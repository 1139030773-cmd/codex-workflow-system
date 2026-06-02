---
name: phase-closeout
description: 中文阶段收尾。用于完成一个阶段、准备开新对话、需要更新状态快照时。由 workflow-system 或其他子技能调用。
---

# 阶段收尾

把当前阶段压缩成可靠状态，让新对话可以接上。

## 优先读取

- `PROJECT.md`
- `TASK_QUEUE.md`
- `DECISIONS.md`
- `STATE_SNAPSHOT.md`

## 工作流程

1. 总结完成内容
2. 总结验证结果
3. 列出未完成内容
4. 识别新增决策
5. 判断哪些内容应冻结
6. 更新或建议更新项目文件
7. 给出新对话启动口令

## 应更新的文件

- `STATE_SNAPSHOT.md`：当前状态、已完成、已知问题、下一步
- `TASK_QUEUE.md`：移动已完成任务，设置新的正在进行的任务
- `DECISIONS.md`：记录长期决策
- `PROJECT.md`：更新目标、阶段、冻结区域、统一命名

## 新对话启动口令

收尾时提供：

```text
这是新对话。请先读取 PROJECT.md、DECISIONS.md、TASK_QUEUE.md 和 STATE_SNAPSHOT.md。
以这些文件为准，总结当前状态，并告诉我下一步唯一行动。
```

## 系统关联

收尾完成后如需新任务，建议 `/newbie-guide` 或 `/project-master`。

## 禁止事项

- 不要在收尾阶段继续开发新功能
- 不要隐藏未验证内容
- 不要把聊天历史当成唯一状态来源
