# 功德木鱼反馈改版 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将现有三用户静态木鱼应用重构为单用户、三档互斥会话、真实主题与可切换统计的完整版本。

**Architecture:** 保留 Preferences 数据格式兼容，在解码时迁移为普通用户。会话、统计周期和主题解析分别由强类型纯逻辑负责，页面只组合状态与交互。木鱼视图观察统一的敲击序列，从而让自动和手动走同一动画路径。

**Tech Stack:** HarmonyOS 6.1.1 API 24、ArkTS、ArkUI、Preferences、SoundPool、Hypium。

---

### Task 1: 单用户迁移和首页文案

**Files:**
- Modify: `entry/src/main/ets/data/JsonCodec.ets`
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/stores/AppStore.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`
- Test: `entry/src/ohosTest/ets/test/CoreModels.test.ets`
- Test: `entry/src/ohosTest/ets/test/DataAndSession.test.ets`

- [x] 写失败测试：默认设置已初始化且为普通用户；旧程序员快照解码后迁移为普通用户并保留自定义文字、主题和音色。
- [x] 构建并运行 Hypium，确认测试因仍返回程序员和未初始化而失败。
- [x] 修改默认值和解码迁移，删除 Index 的首启分支及设置页用户模式区域。
- [x] 删除首页模式标签和顶部自定义文字，仅保留“今日功德 + 数值”。
- [x] 运行 Hypium 与 debug 构建，提交 `统一普通用户并精简首页信息`。

### Task 2: 会话互斥、目标完成与统一敲击事件

**Files:**
- Modify: `entry/src/main/ets/models/Enums.ets`
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/services/SessionService.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Test: `entry/src/ohosTest/ets/test/DataAndSession.test.ets`

- [x] 写失败测试：自动档运行后切换自由档会停止定时器；再次选择自动档会回到自由；目标完成后 `targetCompleted=true` 且额外敲击无效。
- [x] 运行 Hypium，确认失败来自缺少目标完成状态和档位切换 API。
- [x] 在 `SessionService.selectMode()` 中集中处理自由、目标、自动及同档自动关闭，删除限时路径。
- [x] 使用 `session.mode` 渲染选中态，目标档显示进度和完成卡。
- [x] 运行 Hypium 与 debug 构建，提交 `修复会话互斥并补充目标完成反馈`。

### Task 3: 日周月年真实统计

**Files:**
- Create: `entry/src/main/ets/services/StatsPeriodService.ets`
- Modify: `entry/src/main/ets/models/Enums.ets`
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/repositories/StatsRepository.ets`
- Modify: `entry/src/main/ets/stores/AppStore.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/StatsPage.ets`
- Modify: `entry/src/main/ets/components/StatsBarChart.ets`
- Test: `entry/src/ohosTest/ets/test/StatsPeriod.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [x] 写失败测试：固定记录在日、周、月、年口径下得到不同摘要、标题、桶数和标签。
- [x] 运行 Hypium，确认因 `StatsPeriodService` 尚不存在而编译失败。
- [x] 实现 `StatsPeriodView`、`StatsBucket` 和纯逻辑聚合服务。
- [x] 仓库暴露全部记录副本，AppStore 同步全量记录，统计页按选中周期实时生成视图。
- [x] 图表改用桶标签和值，主题标题随周期变化。
- [x] 运行 Hypium 与 debug 构建，提交 `实现日周月年统计聚合`。

### Task 4: 音色选择和完整主题

**Files:**
- Create: `entry/src/main/ets/utils/ThemeResolver.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `entry/src/main/ets/pages/StatsPage.ets`
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`
- Modify: `entry/src/main/ets/components/BottomNavBar.ets`
- Modify: `entry/src/main/ets/components/StatsBarChart.ets`
- Test: `entry/src/ohosTest/ets/test/CoreModels.test.ets`

- [x] 写失败测试：浅色、深色和跟随系统在系统明暗值下解析出正确结果。
- [x] 运行 Hypium，确认因 `ThemeResolver` 尚不存在而编译失败。
- [x] EntryAbility 把系统色彩模式写入 AppStorage，Index 解析最终 `dark`。
- [x] 所有页面、统计图和底栏接收 `dark` 并切换背景、卡片、主次文字与分隔线。
- [x] 设置页音色行打开三项选择面板，点击保存并调用 SoundPool 试听。
- [x] 运行 Hypium、debug 构建和模拟器点击验证，提交 `实现完整主题与音色选择`。

### Task 5: 独立木槌和自动敲击动画

**Files:**
- Create: `entry/src/main/resources/base/media/muyu_body.png`
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/services/SessionService.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `entry/src/main/ets/components/WoodenFishView.ets`
- Modify: `docs/ui/asset-manifest.md`
- Test: `entry/src/ohosTest/ets/test/DataAndSession.test.ets`

- [x] 写失败测试：每次手动或自动记录都把 `hitSequence` 精确加一。
- [x] 运行 Hypium，确认缺少 `hitSequence` 而失败。
- [x] 从用户原木鱼素材编辑出仅移除静态木槌的 `muyu_body.png`，验证木鱼纹理和构图保持。
- [x] WoodenFishView 观察 `hitSequence`，统一触发木槌落下、木鱼回弹和无次数尾缀的浮动文字。
- [x] 模拟器验证手动与自动动画、自动切档停止；目标封顶由 Hypium 验证。
- [x] 运行 Hypium、静态门禁、debug/release 构建，提交 `重做木槌敲击动画并完成改版验收`。

### Task 6: 文档和最终证据

**Files:**
- Modify: `README.md`
- Modify: `design.md`
- Modify: `tasks.md`
- Modify: `changes.md`
- Modify: `design-qa.md`
- Modify: `docs/qa/2026-07-30-build.md`
- Modify: `docs/qa/2026-07-30-interaction.md`
- Create: `docs/qa/screenshots/2026-07-30-feedback-*.jpeg`

- [x] 在 phone 模拟器记录首页、音色面板、浅色和深色截图，并记录自动/统计标题运行态结果。
- [x] 更新功能说明、验收结果、HAP 大小和已知设备限制。
- [x] 执行 `scripts/check-standard.ps1`、外部标准检查、Hypium、debug/release 构建和 `git diff --check`。
- [x] 确认工作区只包含本轮改动，提交 `记录反馈改版完整验收结果`。

