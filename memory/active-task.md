---
name: active-task
description: 当前活跃任务追踪 — 任务名称、阶段、进度、下一步
metadata: 
  node_type: memory
  type: project
  originSessionId: 54b17141-0ce4-4830-9c24-fd55a0d2bc26
---

# 活跃任务

此文件追踪当前正在进行的任务。与项目根目录 `RESUME.md` 保持同步。

**Why:** 任务状态需要在多个会话之间持久化，确保关窗口不丢任务。
**How to apply:** 工作过程中持续更新此文件，新会话时首先检查此文件确认是否有未完成任务。

## 当前状态

- **是否有活跃任务**: 是
- **任务名称**: 抖音推介工作流系统
- **阶段**: 执行中（内容制作 → 录屏拍摄）
- **下一步**: 用户装 OBS → 照着 video-script.md 录屏 → 导入剪映加 AI 配音 → 导出发布

## context_snapshot（v1.6.0 新增）

新窗口恢复时，AI 必须先读取 RESUME.md 的 context_snapshot 块，内化以下信息再开口：

- **decisions**: 推介形式=短视频录屏+AI机器配音；视频结构=6镜头75秒
- **eliminated**: 图文、直播、真人配音、纯字幕BGM
- **user_style**: 回复简短、拍视频经验不足需保姆级指导、不喜欢被问太多选择题、倾向直接给推荐方案
- **footguns**: 不要从头问配音/字幕、不要把市场PR和视频拍摄混一起、不要给多方案让用户选、必须读context_snapshot再开口

## 更新规则

- 每次完成一个重要步骤后更新
- 阶段变化时更新
- 遇到阻塞时更新
- **context_snapshot 随 RESUME.md 同步更新，不可省略**
- 与 `RESUME.md` 保持同步

## 关联

- [[session-recovery]] — 恢复流程
- 项目 `RESUME.md` — 任务恢复点（主要 checkpoint）+ context_snapshot
- 项目 `CLAUDE.md` — 启动自检
