# V2.1 Review Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修复现行设置弹层、文字校验和底栏选中态，并删除不再参与 V2.1 运行的旧会话模式代码。

**Architecture:** 保持 `PracticeController` 为唯一练习状态机，`EntryAbility` 生命周期也只调用该控制器。UI 修复局限于 `SettingsPage` 与 `BottomNavBar`，文字规则继续集中在 `TextValidator`。

**Tech Stack:** HarmonyOS API 24、ArkTS、ArkUI、Hypium、Hvigor。

---

### Task 1: 反馈文字校验

**Files:**
- Modify: `entry/src/main/ets/utils/TextValidator.ets`
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`
- Test: `entry/src/ohosTest/ets/test/CoreModels.test.ets`

- [x] 在 `CoreModels.test.ets` 增加 `validationMessage('   ') === '请输入至少 1 个有效字符'` 和有效值返回空字符串的断言。
- [x] 构建 ohosTest，确认因 `validationMessage` 不存在而 RED 失败。
- [x] 在 `TextValidator` 增加明确错误消息；设置编辑器保存前验证，失败时保持弹层并显示错误，有效时规范化后关闭。
- [x] 构建 ohosTest，确认 GREEN。

### Task 2: 弹层与底栏视觉状态

**Files:**
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`
- Modify: `entry/src/main/ets/components/BottomNavBar.ets`

- [x] 为文字编辑和清除确认增加覆盖全屏的 `#73000000` 遮罩，遮罩点击关闭，内容卡点击不冒泡到背景。
- [x] 设置音量滑轨使用深浅主题轨道色。
- [x] 底栏选中项显示 `✓`、背景和边框，未选中项保持固定尺寸，触控区不小于 48vp。
- [x] 构建 debug，并在 phone 模拟器用布局树验证弹层存在遮罩、背景入口不可点击、底栏选中态含 `✓`。

### Task 3: 删除旧 V1 会话状态机

**Files:**
- Delete: `entry/src/main/ets/services/SessionService.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`
- Modify: `entry/src/main/ets/stores/AppRuntime.ets`
- Modify: `entry/src/main/ets/models/Enums.ets`
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/constants/UserModeConfigs.ets`
- Modify: `entry/src/ohosTest/ets/test/DataAndSession.test.ets`

- [x] 将 `EntryAbility` 后台回调改为 `practiceController.onBackground()`，移除 `sessionService` 运行时实例。
- [x] 删除旧服务、`SessionMode`、`SessionState`、`recommendedTargets`、`featureOrder` 和四条旧模式测试。
- [x] 使用 `rg` 确认生产源码不再引用旧类型，且保留旧设置迁移需要的 `UserMode` 配置。
- [x] 运行设备 Hypium，预期全部通过且测试总数减少四条。

### Task 4: 完整门禁与记录

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`
- Modify: `design-qa.md`

- [x] 运行标准检查、外部检查、debug、ohosTest、release 和禁止能力扫描。
- [x] 回填修复项、淘汰项判定、测试数、产物和 phone 运行证据。
- [x] `git diff --check` 后提交 `fix: 修复设置交互并清理旧会话代码`。
