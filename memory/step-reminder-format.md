---
name: step-reminder-format
description: 每次推进下一步时必须带完整背景信息，禁止简短几个字
metadata:
  type: feedback
---

每次推进下一步时，必须用固定格式带完整背景，禁止只说"继续录镜头X"这种几个字。

**固定格式：**

```
📹 任务：抖音推介视频
🎯 目标：让装了 Codex 不会用的人，用大白话装插件就能上手
✅ 已完成：镜头 1（钩子，Codex 空白界面）
📍 下一步：镜头 2 · 插件安装（8-18 秒）
📝 具体操作：在 Codex 输入框敲入「帮我安装 agent-workflow-system 插件，GitHub 地址是 1139030773-cmd/agent-workflow-system」，回车，等 AI 安装完成，停止录制
```

**Why:** 用户说简短几个字会忘记为什么要这样做，需要看到背景信息才能衔接。

**How to apply:**
- 每次推进下一步都用这个格式
- 至少包含：任务名、目标、已完成、下一步、具体操作
- 相关：[[response-tone]] [[no-skip-verification]]
