# 设置反馈项分组排序 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 仅调整“敲击反馈”卡片内六个设置项的顺序，使开关项和箭头项分别连续排列。

**Architecture:** 不新增组件或状态。直接移动 `SettingsPage.build()` 中现有 ArkUI 代码块，保留每个代码块内部实现和分隔线样式，音量作为两组之间的过渡。

**Tech Stack:** ArkTS、ArkUI、PowerShell、Hvigor、Hypium、HDC。

---

### Task 1: 锁定并调整顺序

**Files:**
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`

- [x] 用 PowerShell 读取六个标题在源码中的索引，断言目标顺序；预期修改前失败。
- [x] 移动现有代码块为“音效开关、振动反馈、浮动文字、音量、音色选择、自定义文字”，不修改块内属性。
- [x] 重跑同一顺序断言；预期六项各出现一次且索引严格递增。

### Task 2: 验证并提交

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`
- Create: `docs/qa/2026-08-02-settings-feedback-order.md`

- [x] 运行 `scripts/check-standard.ps1`、debug、ohosTest、release 和 phone Hypium。
- [x] 在 phone 设置页确认最终顺序，保存截图并记录 tablet、2in1 为 `blocked`。
- [x] 更新任务与变更记录，只暂存本次设置页、测试/文档相关文件并创建提交。
