<!-- 每个新会话自动加载。不要删除。 -->

## 系统改动铁律

**只要改了系统文件，以下 6 步必须一口气做完，不等用户催：**

| # | 步骤 | 说明 |
|---|------|------|
| 1 | **三目录同步** | 根目录 → `plugins/agent-workflow-system/` → `c:\Users\11390\Documents\New project\` |
| 2 | **CHANGELOG** | 在对应版本条目下记录改动（Added/Changed/Fixed） |
| 3 | **README** | 如果改动影响功能描述，同步更新核心特性/版本表 |
| 4 | **版本号** | 如果是新功能/breaking change，同步更新 `plugin.json` + `marketplace.json` 版本 |
| 5 | **commit + push + tag** | 提交推送；新功能/breaking change 需打版本 tag |
| 6 | **验证** | 推送后检查 Releases 页面，确认新版本在列表中且为 Latest。没确认 = 没完成 |

**违反信号**: 用户问"README 更新了吗"、"CHANGELOG 补了吗"、"推送了吗"、"Release 呢" = 你漏步骤了。

**自动化原则**: 同一件事用户让我做超过 3 次 → 把它写成规则或脚本，下次自动执行，不再让用户提醒。
