# Codex Workflow System - GitHub Marketplace 发布指南

本文档记录了将此项目发布到 GitHub Marketplace 的完整过程。

## 项目概述

**项目名称**: Codex Workflow System  
**项目类型**: GitHub Copilot Extensions/Skills  
**开源协议**: MIT License  
**仓库**: https://github.com/1139030773-cmd/agent-workflow-system

## 项目描述

一套中文 Copilot Skills 工作流系统，面向新手和非技术用户。通过智能引导和协作，将模糊目标转化为可执行任务，并在项目全生命周期中提供支持。

## 包含的 Skills

### 1. agent-newbie-guide (新手引导)
- **描述**: 新手引导入口
- **功能**: 帮助新手将模糊目标逐步转化为具体任务
- **推荐用语**: "启动新手引导。我有一个模糊目标，请你一步一步问我，并把它变成可执行任务。"

### 2. agent-project-master (项目总控)
- **描述**: 项目全局管理和进度跟踪
- **功能**: 项目规划、进度监控、资源分配

### 3. agent-learning-coach (学习教练)
- **描述**: 个性化学习指导
- **功能**: 学习路径规划、个性化教学、进度评估

### 4. agent-debug-fixer (调试修复)
- **描述**: 代码问题诊断和修复
- **功能**: 错误诊断、根因分析、代码修复

### 5. agent-drift-auditor (漂移检查)
- **描述**: 项目偏离检查和审计
- **功能**: 目标偏离检测、质量审计、风险提示

### 6. agent-phase-closeout (阶段收尾)
- **描述**: 项目阶段总结
- **功能**: 阶段总结、经验沉淀、下阶段规划

## 发布配置

### 已创建的文件

1. ✅ **`.github/plugin/marketplace.json`** - Marketplace 配置
2. ✅ **每个 skill 的 `manifest.json`** - skill 元数据
3. ✅ **每个 skill 的 `README.md`** - skill 说明文档
4. ✅ **`MARKETPLACE.md`** - 发布指南（本文件）

## 安装方式

用户可以通过以下命令安装此插件：

```bash
# 全局安装
npx agent-marketplace add 1139030773-cmd/agent-workflow-system --plugin --global

# 项目级安装
npx agent-marketplace add 1139030773-cmd/agent-workflow-system --plugin --project
```

## GitHub Marketplace 发布步骤

### 步骤 1: 准备工作（已完成）
- ✅ 仓库为公开状态
- ✅ 包含 MIT License
- ✅ 包含完整的 README.md
- ✅ 包含 marketplace.json 配置
- ✅ 所有 skill 都有 manifest.json

### 步骤 2: 访问 GitHub Marketplace

1. 访问 https://github.com/marketplace/new
2. 使用你的 GitHub 账户登录（1139030773-cmd）

### 步骤 3: 填写应用信息

填写以下信息：

| 字段 | 值 |
|------|----|
| 应用名称 | Codex Workflow System |
| 简短描述 | 中文 Copilot Skills 工作流系统，助力新手和非技术用户 |
| 完整描述 | 一套中文 Copilot Skills 工作流插件，面向新手和非技术用户。它把模糊目标引导成可执行任务，并提供项目总控、学习教练、调试修复、漂移审计和阶段收尾能力。 |
| 应用类别 | Development / Productivity |
| 应用 URL | https://github.com/1139030773-cmd/agent-workflow-system |
| 支持 URL | https://github.com/1139030773-cmd/agent-workflow-system/issues |
| 所有者 | 1139030773-cmd |

### 步骤 4: 配置定价

- 选择 **"免费"** (Free) 定价模式
- 此应用不需要付费订阅

### 步骤 5: 上传应用图标

- 上传应用图标（推荐 400x400px PNG 格式）
- 可以创建一个代表 "Codex Workflow" 的简单图标

### 步骤 6: 配置权限

选择应用所需的权限：
- 读取代码
- 读取 issues
- 读取项目信息

### 步骤 7: 验证和发布

1. 审查所有信息
2. 点击 "发布到 GitHub Marketplace"
3. GitHub 将审核你的应用（通常需要 1-3 天）

### 步骤 8: 发布后

- 应用将出现在 GitHub Marketplace
- 用户可以通过仓库链接安装
- 监控应用的使用和反馈

## 推荐启动语

在 Copilot Chat 中，用户可以使用以下启动语激活各个 skill：

```
启动新手引导。我有一个模糊目标，请你一步一步问我，并把它变成可执行任务。
```

## 后续维护

1. **版本更新**: 在 marketplace.json 和各 skill 的 manifest.json 中更新版本号
2. **问题修复**: 在 GitHub Issues 中处理用户反馈
3. **功能增强**: 为 skills 添加新功能时更新文档
4. **更新日志**: 在 CHANGELOG.md 中记录所有更新

## 相关资源

- [GitHub Marketplace 文档](https://docs.github.com/en/github-ae@latest/developers/github-marketplace/github-marketplace-overview)
- [Copilot Extensions 文档](https://github.com/github/copilot-docs)
- [本仓库的 Issues](https://github.com/1139030773-cmd/agent-workflow-system/issues)

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

**最后更新**: 2026-05-31  
**发布状态**: ✅ 已为发布做准备
