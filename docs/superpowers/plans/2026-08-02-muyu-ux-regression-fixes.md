# 功德木鱼界面与状态同步修复 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修复首页背景与木槌、文字独立计数、日周月最新周期定位、设置开关越界和设置值即时刷新。

**Architecture:** 统计仓库继续作为全部敲击数据源，`AppSettings` 只保存当前文字的今日计数基线；`AppStore` 派生首页文字计数。页面通过替换 `@State settings` 立即刷新，持久化仍异步执行。趋势服务维持时间升序，图表组件通过 `Scroller` 初始定位到末端。

**Tech Stack:** HarmonyOS Stage 模型、ArkTS、ArkUI、Preferences、Hypium、Hvigor。

---

### Task 1: 当前文字独立计数与迁移

**Files:**
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/data/JsonCodec.ets`
- Modify: `entry/src/main/ets/stores/AppStore.ets`
- Modify: `entry/src/ohosTest/ets/test/DataAndSession.test.ets`

- [x] **Step 1: 写失败测试**

在 `DataAndSession.test.ets` 增加 `SettingsRepository`、`AppStore` 测试，先记录两次今日敲击，再保存“今日好运”，断言 `summary.todayCount` 仍为 2、`currentTextCount()` 为 0；再敲一次后为 1，重复保存同一文字后仍为 1。

```typescript
it('resetsOnlyHomeTextCountWhenTextChanges', 0, async (): Promise<void> => {
  const memory: MemoryStore = new MemoryStore();
  const store: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
  await store.initialize();
  await store.recordHit(false);
  await store.recordHit(false);
  await store.saveCustomText('今日好运');
  expect(store.summary.todayCount).assertEqual(2);
  expect(store.currentTextCount()).assertEqual(0);
  await store.recordHit(false);
  expect(store.currentTextCount()).assertEqual(1);
  await store.saveCustomText('今日好运');
  expect(store.currentTextCount()).assertEqual(1);
});
```

- [x] **Step 2: 运行 ohosTest 构建确认失败**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest`

Expected: FAIL，提示 `currentTextCount` 不存在。

- [x] **Step 3: 实现最小数据模型**

在 `AppSettings` 增加：

```typescript
homeCountBaseline: number = 0;
homeCountDate: string = '';
```

`JsonCodec.decodeSettings` 对基线做非负数校验，对日期只接受字符串。`AppStore.saveCustomText` 仅在规范化文字与当前文字不同时写入当前 `summary.todayCount` 和 `DateUtil.todayKey()`；增加 `currentTextCount(today)`，同日返回 `todayCount - baseline`，跨日直接返回今日统计。

- [x] **Step 4: 构建并在设备运行 Hypium**

Run: ohosTest 构建，安装主/test HAP，然后运行 `hdc shell aa test -b com.max.muyu -m entry_test -s unittest OpenHarmonyTestRunner`。

Expected: 新用例 PASS，原有统计用例保持通过。

### Task 2: 页面即时刷新与首页标题

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`

- [x] **Step 1: 在 `Index` 建立响应式派生状态**

增加 `@State homeTextCount: number = 0`。`syncFromStore()` 替换 `settings` 副本并执行 `this.homeTextCount = appStore.currentTextCount()`。

- [x] **Step 2: 音量先刷新再保存**

每次 Slider `onChange` 立即更新 `appStore.settings.volume` 并替换页面 `settings` 副本；仅 `SliderChangeMode.End` 或 `Click` 调用 `persistSettings()`。

- [x] **Step 3: 自定义文字先刷新再保存**

调用 `appStore.saveCustomText(value)` 后，在 Promise 完成前立即执行 `syncFromStore()`；保存失败时设置 `storageError = true`。

- [x] **Step 4: 首页使用当前文字和独立计数**

`HomePage` 增加 `@Prop homeTextCount: number`，标题改为 `Text(`${this.settings.currentText}  ${this.homeTextCount.toLocaleString()}`)`，`Index` 传入该状态。

### Task 3: 日周月趋势与最新周期初始定位

**Files:**
- Modify: `entry/src/main/ets/models/Enums.ets`
- Modify: `entry/src/main/ets/services/StatsPeriodService.ets`
- Modify: `entry/src/main/ets/pages/StatsPage.ets`
- Modify: `entry/src/main/ets/components/StatsBarChart.ets`
- Modify: `entry/src/ohosTest/ets/test/StatsPeriod.test.ets`

- [x] **Step 1: 写失败测试**

将原日周月年测试改为日周月测试，断言三组桶的最后一项分别是今日 `07/30`、包含今日的周桶和本月 `07月`。

```typescript
expect(day.buckets[day.buckets.length - 1].label).assertEqual('07/30');
expect(day.buckets[day.buckets.length - 1].totalCount).assertEqual(5);
expect(week.buckets[week.buckets.length - 1].totalCount).assertEqual(7);
expect(month.buckets[month.buckets.length - 1].label).assertEqual('07月');
```

- [x] **Step 2: 运行 ohosTest 确认旧年趋势契约仍存在**

Run: ohosTest 构建并运行 Hypium。

Expected: 新日周月断言通过，但旧 `YEAR` 业务仍存在，尚未满足页面契约。

- [x] **Step 3: 删除年趋势业务分支**

从 `StatsPeriod` 删除 `YEAR`，从 `StatsPeriodService` 删除年标题、年桶和年聚合分支，从 `StatsPage` 删除年按钮。日、周、月保持早到晚生成。

- [x] **Step 4: 图表默认滚动到最新周期**

`StatsBarChart` 增加组件内 `Scroller`。为 `buckets` 增加 `@Watch`，组件出现和桶变化后调用 `this.scroller.scrollEdge(Edge.End)`，`Scroll(this.scroller)` 保持固定桶宽和水平拖动。

- [x] **Step 5: 运行 Hypium 和 debug 构建**

Expected: 日周月测试通过，ArkTS 构建通过，页面只显示三个等宽切换项。

### Task 4: 首页背景、木槌与设置开关布局

**Files:**
- Modify: `entry/src/main/ets/constants/DesignTokens.ets`
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `entry/src/main/ets/components/WoodenFishView.ets`
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`

- [x] **Step 1: 统一浅色首页表面**

增加与木鱼浅色素材外围一致的 `homeLightBackground` 令牌，并让 `HomePage.pageBackground()`、首页内容根节点和图片外层使用同一令牌；深色模式保持现有背景。

- [x] **Step 2: 上移木槌基准位置**

将木槌容器基准 `y` 从 `176` 调整到约 `145`，保留 `malletAngle`、`malletOffsetX/Y` 动画参数不变。

- [x] **Step 3: 仅约束三个开关**

保持当前设置行结构和顺序。让 `SettingRow` 在父 Row 内可收缩；三个 Toggle 使用 `.width(44).margin({ right: 8 })`，三个父 Row 使用 `.width('100%')`，保证完整落在卡片内。

### Task 5: 总门禁与 phone 视觉验收

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`
- Create: `docs/qa/2026-08-02-ux-regression.md`
- Create: `docs/qa/screenshots/2026-08-02-*.jpeg`

- [x] **Step 1: 运行全部自动门禁**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode release
git diff --check
```

Expected: 所有命令退出码 0；仅允许既有 unsigned signing warning。

- [x] **Step 2: 在 phone 模拟器运行 Hypium**

安装最新 debug 主 HAP 和 ohosTest HAP，运行 `OpenHarmonyTestRunner`。Expected: Failure 0，Error 0，`OHOS_REPORT_CODE: 0`。

- [x] **Step 3: 视觉与交互验证**

依次截图：首页背景与木槌；保存“今日好运”后首页显示“今日好运 0”；日周月趋势默认最新周期且可横向拖动；设置开关位于卡片内；音量拖动时百分比立即改变。

- [x] **Step 4: 回填记录**

`tasks.md`、`changes.md` 和 QA 文档记录实际构建、测试和设备证据；tablet/2in1 无设备时保持 `blocked`。
