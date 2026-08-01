# 静心木鱼界面优化与修复 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 HarmonyOS 6.0.2 API 22 工程中完成共享主题与安全区、设置实时刷新、可选木鱼目标、右上落槌、八档趋势、应用名称和上架门禁。

**Architecture:** `Index` 保持唯一响应式状态所有者，`AppStore/SettingsRepository` 保存设置，`PracticeController` 管目标状态，`StatsPeriodService` 管八档聚合。主题和窗口外观分别复用 `ThemePalette` 与新增共享服务，页面只组合强类型状态。

**Tech Stack:** HarmonyOS 6.0.2 API 22、Stage、ArkTS、ArkUI、Preferences、Hypium、Hvigor、HDC。

---

### Task 1: 先建立行为回归测试

**Files:**
- Modify: `entry/src/ohosTest/ets/test/CoreModels.test.ets`
- Modify: `entry/src/ohosTest/ets/test/PracticeController.test.ets`
- Modify: `entry/src/ohosTest/ets/test/StatsPeriod.test.ets`

- [ ] **Step 1: 写文字、设置和八档周期失败测试**

```ts
expect(FeedbackText.label('好运+1')).assertEqual('好运');
expect(SettingsMigration.decode('{"targetCount":1000}').targetCount).assertEqual(1000);
expect(StatsPeriodService.build(records, [], today, StatsPeriod.LAST_7_DAYS).buckets.length).assertEqual(7);
```

- [ ] **Step 2: 写目标达成与重置失败测试**

```ts
controller.configureTarget(3);
controller.startTarget();
controller.recordManual();
controller.recordManual();
controller.recordManual();
expect(controller.state.targetCompleted).assertTrue();
controller.restartTarget();
expect(controller.state.sessionCount).assertEqual(0);
```

- [ ] **Step 3: 构建 ohosTest，确认因缺少新 API 而 RED**

Run: `powershell -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest`

Expected: FAIL，错误指向 `FeedbackText`、新增 `StatsPeriod` 或目标控制 API 不存在。

### Task 2: 统一主题和沉浸式安全区

**Files:**
- Modify: `entry/src/main/ets/constants/DesignTokens.ets`
- Modify: `entry/src/main/ets/constants/ThemePalette.ets`
- Create: `entry/src/main/ets/services/WindowAppearanceService.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: 让 ThemePalette 成为页面背景唯一来源**

```ts
colors.page = dark ? '#171513' : '#F6F1E8';
colors.card = dark ? '#24211E' : '#FFFDF8';
```

- [ ] **Step 2: 用共享服务配置全屏布局、系统栏颜色和避让区**

```ts
await mainWindow.setWindowLayoutFullScreen(true);
await mainWindow.setWindowSystemBarProperties({ statusBarColor: color, navigationBarColor: color });
```

- [ ] **Step 3: 根页面背景扩展到系统安全区，交互内容保留系统避让**

- [ ] **Step 4: 运行标准检查和 debug 构建**

### Task 3: 恢复自定义文字并修复 Switch 布局

**Files:**
- Create: `entry/src/main/ets/utils/FeedbackText.ets`
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/utils/SettingsMigration.ets`
- Modify: `entry/src/main/ets/stores/AppStore.ets`
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: 实现文字标准化和标题标签解析使测试转绿**

```ts
static label(value: string): string {
  const result: string = value.trim().replace(/[+＋]\s*\d+\s*$/, '').trim();
  return result.length === 0 ? '功德' : result;
}
```

- [ ] **Step 2: 添加 `AppStore.saveFeedbackText`，保存成功后由 Index 统一同步新实例**

- [ ] **Step 3: 恢复带遮罩、自定义输入、非法输入行内错误的设置弹层**

- [ ] **Step 4: Switch 文本区使用 `layoutWeight(1)` 和 `minWidth: 0`，开关触控容器至少 60x48vp 且不裁切**

- [ ] **Step 5: 运行 ohosTest 构建并确认文字测试 GREEN**

### Task 4: 可选目标与完成后再来一次

**Files:**
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/models/Enums.ets`
- Modify: `entry/src/main/ets/models/PracticeModels.ets`
- Modify: `entry/src/main/ets/utils/SettingsMigration.ets`
- Modify: `entry/src/main/ets/services/PracticeController.ets`
- Modify: `entry/src/main/ets/components/PracticeControlDock.ets`
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: 增加 `targetCount`、目标模式、进度和完成状态**

```ts
targetCount: number = 108;
targetCompleted: boolean = false;
sessionCount: number = 0;
```

- [ ] **Step 2: 在 PracticeController 实现配置、达标封顶、停止自动和只重置本轮**

- [ ] **Step 3: 目标选择弹层提供 108、1000、10000 与正整数自定义输入**

- [ ] **Step 4: 保存目标到 AppSettings，重启通过 SettingsMigration 恢复**

- [ ] **Step 5: 运行目标控制测试并确认 GREEN**

### Task 5: 木鱼背景、右上木槌与联动标题

**Files:**
- Modify/Create: `entry/src/main/resources/base/media/muyu_body_transparent.png`
- Modify: `entry/src/main/ets/components/WoodenFishView.ets`
- Modify: `entry/src/main/ets/components/TodaySummaryCard.ets`
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `docs/ui/asset-manifest.md`

- [ ] **Step 1: 从已有用户木鱼素材派生透明、无静态木槌主体，不引入外部素材**

- [ ] **Step 2: 独立 ArkUI 木槌锚定画布右上，保留 90ms/180ms 动画曲线**

- [ ] **Step 3: 首页标题使用 `今日${FeedbackText.label(settings.feedbackText)}`**

- [ ] **Step 4: 检查深浅主题画布与页面都使用 `ThemePalette.page`，无卡片接缝**

### Task 6: 八档趋势聚合与选择器

**Files:**
- Modify: `entry/src/main/ets/models/Enums.ets`
- Modify: `entry/src/main/ets/services/StatsPeriodService.ets`
- Modify: `entry/src/main/ets/pages/StatsPage.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`

- [ ] **Step 1: 实现八个 StatsPeriod 的日期范围与日/周/月分桶**

- [ ] **Step 2: 运行周期测试，确认边界、桶数与汇总 GREEN**

- [ ] **Step 3: 用两行四列 48vp 选择器展示两组档位，默认 AppStorage `本日`**

- [ ] **Step 4: 图表、摘要、会话列表只消费同一个 `currentView()`**

### Task 7: 应用名称与合规收尾

**Files:**
- Modify: `entry/src/main/resources/base/element/string.json`
- Verify: `entry/src/main/module.json5`
- Modify: `scripts/check-standard.ps1`
- Modify: `README.md`

- [ ] **Step 1: 将资源显示名统一为静心木鱼，保留 bundleName、版本号和签名配置**

- [ ] **Step 2: 门禁检查 API 22、三设备声明、最小权限、名称引用和禁止网络能力**

- [ ] **Step 3: 运行标准检查与 `git diff --check`**

### Task 8: 全量构建和 API 22 设备验收

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`
- Create/Modify: `docs/qa/2026-08-01-interface-optimization.md`
- Create: `docs/qa/screenshots/muyu-api22-*-light.jpeg`
- Create: `docs/qa/screenshots/muyu-api22-*-dark.jpeg`

- [ ] **Step 1: 构建 debug、ohosTest 和 release HAP**

- [ ] **Step 2: 安装到 `127.0.0.1:5557` 并运行全部 Hypium**

- [ ] **Step 3: 回归自定义文字、冷启动、目标完成、八档趋势、Switch 和系统栏**

- [ ] **Step 4: 归档深浅主题首页、趋势页、设置页截图和设备信息**

- [ ] **Step 5: 更新任务、变更和 QA 证据，提交实现**

