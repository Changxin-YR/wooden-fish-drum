# 静心木鱼 UI 高保真还原 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将首页、练习记录和设置页重构为用户批准的象牙金/黑金共享结构，并保持真实数据、三工具状态和多设备适配。

**Architecture:** 新增强类型 `ThemePalette` 作为页面语义色唯一入口，现有 `AppStore` 与 `PracticeController` 继续作为业务真相源。页面只重排 ArkUI 组件；Compact 贴合 phone 参考图，Medium/Expanded 复用同组件限宽双栏。

**Tech Stack:** HarmonyOS API 24、ArkTS、ArkUI、Preferences、Hypium、Hvigor、HDC UI Test。

---

### Task 1: 共享主题语义与响应式尺寸

**Files:**
- Create: `entry/src/main/ets/constants/ThemePalette.ets`
- Modify: `entry/src/main/ets/constants/DesignTokens.ets`
- Create: `entry/src/main/resources/base/media/theme_mountain_light.png`
- Create: `entry/src/main/resources/base/media/theme_mountain_dark.png`
- Modify: `entry/src/ohosTest/ets/test/CoreModels.test.ets`

- [x] **Step 1: 写入失败测试**

在 `CoreModels.test.ets` 增加：

```ts
it('resolvesApprovedIvoryAndBlackGoldPalettes', 0, (): void => {
  expect(ThemePalette.resolve(false).page).assertEqual('#F8F5EF');
  expect(ThemePalette.resolve(false).primary).assertEqual('#44352B');
  expect(ThemePalette.resolve(true).page).assertEqual('#0D0E0D');
  expect(ThemePalette.resolve(true).accent).assertEqual('#CE914A');
});

it('usesDiscreteReferenceLayoutMetrics', 0, (): void => {
  expect(DesignTokens.pageInset(390)).assertEqual(20);
  expect(DesignTokens.pageInset(800)).assertEqual(24);
  expect(DesignTokens.titleSize(390)).assertEqual(32);
  expect(DesignTokens.titleSize(1100)).assertEqual(34);
});
```

- [x] **Step 2: 验证 RED**

运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
```

预期：编译失败，提示 `ThemePalette`、`pageInset` 或 `titleSize` 不存在。

- [x] **Step 3: 实现最小主题 API**

`ThemePalette.ets` 提供显式字段：

```ts
export class ThemeColors {
  page: string = '';
  card: string = '';
  primary: string = '';
  secondary: string = '';
  accent: string = '';
  accentSoft: string = '';
  divider: string = '';
  selectedText: string = '';
}

export class ThemePalette {
  static resolve(dark: boolean): ThemeColors {
    const colors: ThemeColors = new ThemeColors();
    colors.page = dark ? '#0D0E0D' : '#F8F5EF';
    colors.card = dark ? '#191816' : '#FFFDFA';
    colors.primary = dark ? '#E7D4BF' : '#44352B';
    colors.secondary = dark ? '#9A8D80' : '#887A6E';
    colors.accent = dark ? '#CE914A' : '#C98C49';
    colors.accentSoft = dark ? '#3A2A1D' : '#F3E5D3';
    colors.divider = dark ? '#493B2E' : '#E8DED2';
    colors.selectedText = '#FFFFFF';
    return colors;
  }
}
```

在 `DesignTokens` 增加离散 `pageInset(width)`、`titleSize(width)`，不得使用随宽度连续缩放的公式。

从用户高分辨率设置稿固定裁切不含正文的右侧远山区域：浅色源图裁切 `(570,185,320,120)`，深色源图裁切 `(440,175,460,135)`，分别保存为 `theme_mountain_light.png` 和 `theme_mountain_dark.png`。页面只把它们作为低透明度、右对齐纹理。

- [x] **Step 4: 验证 GREEN 并提交**

运行 ohosTest 构建和项目标准检查，预期均通过。提交：

```powershell
git add entry/src/main/ets/constants entry/src/main/resources/base/media/theme_mountain_*.png entry/src/ohosTest/ets/test/CoreModels.test.ets
git commit -m "feat: 建立高保真主题语义"
```

### Task 2: 摘要、工具条和底部导航

**Files:**
- Modify: `entry/src/main/ets/components/TodaySummaryCard.ets`
- Modify: `entry/src/main/ets/components/ToolSegmentedControl.ets`
- Modify: `entry/src/main/ets/components/BottomNavBar.ets`
- Modify: `entry/src/ohosTest/ets/test/CoreModels.test.ets`

- [x] **Step 1: 写入并验证视觉契约 RED**

增加纯逻辑断言，要求 phone 摘要高度、工具条高度和底栏高度为固定离散值：

```ts
expect(DesignTokens.summaryHeight(390)).assertEqual(76);
expect(DesignTokens.toolBarHeight(390)).assertEqual(52);
expect(DesignTokens.bottomNavHeight(390)).assertEqual(76);
```

运行 ohosTest 构建，预期因三个方法不存在而失败。

- [x] **Step 2: 实现共享尺寸和组件样式**

实现三个尺寸方法，并将组件改为：

- 摘要为三等分居中布局，去掉圆形汉字徽章，数值和单位同行。
- 工具条使用现有三工具状态，选中项为金色填充/描边、白字和勾选图标。
- 底栏选中项使用金色图标明度、字重、背景和描边，不再显示 `✓ 首页` 文字前缀。
- 所有按钮保持至少 48vp。

- [x] **Step 3: 验证并提交**

运行 ohosTest 构建、标准检查和 `git diff --check`。提交：

```powershell
git add entry/src/main/ets/components entry/src/main/ets/constants entry/src/ohosTest/ets/test/CoreModels.test.ets
git commit -m "feat: 重塑共享摘要工具条和底栏"
```

### Task 3: 首页与三工具控制台

**Files:**
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `entry/src/main/ets/components/PracticeControlDock.ets`
- Modify: `entry/src/main/ets/components/WoodenFishView.ets`
- Modify: `entry/src/main/ets/components/BeadsView.ets`
- Modify: `entry/src/main/ets/components/IncenseView.ets`
- Modify: `entry/src/main/ets/utils/PracticeLayout.ets`
- Modify: `entry/src/ohosTest/ets/test/CoreModels.test.ets`

- [x] **Step 1: 写入并验证 Compact 布局 RED**

修改布局测试，要求参考稿的 Compact 画布和间距：

```ts
const compact: PracticeLayoutMetrics = PracticeLayout.resolve(390);
expect(compact.canvasHeight).assertEqual(150);
expect(compact.pageSpacing).assertEqual(10);
expect(compact.messageInControlDock).assertTrue();
```

先把期望值设置为当前实现不同的批准值，运行 ohosTest 构建并确认失败原因是尺寸不符。

- [x] **Step 2: 重排首页骨架**

`HomePage.PhoneContent()` 严格按以下顺序组合：

```ts
this.Header(true)
TodaySummaryCard(...)
ToolSegmentedControl(...)
this.PracticeCanvas(true)
this.Controls(true)
```

Header 使用 32fp 品牌标题和 48vp 离线胶囊；页面使用 `ThemePalette.resolve(this.dark)`，不在页面散落新颜色常量。

- [x] **Step 3: 贴合三个主体画布**

- 木鱼、念珠和一炷香都在 150vp Compact 画布内保持完整主体，不裁切关键部分。
- 主体区不放装饰卡片；浅色使用柔和暖光，深色只使用低对比暖光。
- 计数和计时位于主体下方，真实状态文案不固定为参考图示例。

- [x] **Step 4: 重塑控制台**

`PracticeControlDock` 保持现有回调接口，按参考稿实现：

- 木鱼/念珠：手动/自动、三档间隔、祝语、音频条。
- 一炷香：五档时长、主开始/暂停/继续按钮、结束、祝语、音频条。
- 音频条包含 `mode_general` 缩略图、音色名、播放按钮、音量 Slider 和振动 Toggle。

- [x] **Step 5: GREEN、设备 smoke test 和提交**

运行 ohosTest 构建和 debug 构建；安装 debug HAP 后切换三工具，确认每个主命令可见且底栏不遮挡。提交：

```powershell
git add entry/src/main/ets/pages/HomePage.ets entry/src/main/ets/components entry/src/main/ets/utils/PracticeLayout.ets entry/src/ohosTest/ets/test/CoreModels.test.ets
git commit -m "feat: 按参考稿重建三工具首页"
```

### Task 4: 练习记录页

**Files:**
- Modify: `entry/src/main/ets/pages/StatsPage.ets`
- Modify: `entry/src/main/ets/components/StatsBarChart.ets`
- Modify: `entry/src/ohosTest/ets/test/StatsPeriod.test.ets`

- [ ] **Step 1: 写入真实数据回归 RED**

增加断言确保视觉重排不合并单位或伪造记录：

```ts
expect(today.count).assertEqual(59);
expect(today.practiceDurationSeconds).assertEqual(38);
expect(today.incenseDurationSeconds).assertEqual(0);
expect(today.recentSessions.length).assertEqual(1);
```

用包含木鱼、念珠和香会话的固定测试数据构造 `StatsPeriodView`；先写期望并确认缺少或错误聚合时失败。

- [ ] **Step 2: 重排记录页面**

- 标题 32fp，副标题直接位于标题下。
- 周期条为 72vp 内的四等分控件，选中项带字重、金色文字和底边/柔光。
- 摘要卡、最近练习、本地统计和趋势卡按参考稿顺序排列。
- 空记录保留“还没有真实练习记录”，不显示参考稿中的 18:50 示例。

- [ ] **Step 3: 重塑趋势卡**

`StatsBarChart` 保留次数与时长独立数据，统一使用主题色；最近 7 日在 phone 单卡内完整显示，更多桶继续横向滚动。

- [ ] **Step 4: 验证并提交**

运行 StatsPeriod 测试、ohosTest 构建和 debug 构建。提交：

```powershell
git add entry/src/main/ets/pages/StatsPage.ets entry/src/main/ets/components/StatsBarChart.ets entry/src/ohosTest/ets/test/StatsPeriod.test.ets
git commit -m "feat: 按参考稿重建练习记录页"
```

### Task 5: 设置页贴稿与死代码清理

**Files:**
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`
- Modify: `entry/src/main/ets/pages/AboutPage.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/models/Enums.ets`
- Modify: `entry/src/main/ets/utils/ThemeResolver.ets`
- Delete: `entry/src/main/ets/pages/OpenSourceLicensePage.ets`
- Delete: `entry/src/main/ets/utils/TextValidator.ets`
- Modify: `entry/src/ohosTest/ets/test/CoreModels.test.ets`
- Modify: `scripts/check-standard.ps1`

- [ ] **Step 1: 写入许可合并和主题切换 RED**

在 `CoreModels.test.ets` 增加可测试的主题切换规则：

```ts
expect(ThemeResolver.toggle(false)).assertEqual(ThemeMode.DARK);
expect(ThemeResolver.toggle(true)).assertEqual(ThemeMode.LIGHT);
```

运行 ohosTest 构建，预期因 `toggle` 不存在而失败。

- [ ] **Step 2: 实现参考稿设置结构**

设置页只组合：本地身份条、练习设置、音频设置、显示设置、数据与合规。显示设置的“深色模式”开关通过 `ThemeResolver.toggle(dark)` 写入显式 LIGHT/DARK；减少动画保持现有回调。

- [ ] **Step 3: 合并许可并删除不可达 UI**

- 将运行包和 Hypium 许可说明并入 `AboutPage`。
- 删除 `SettingsRoute.LICENSES`、`OpenSourceLicensePage`、反馈文字编辑状态和 `TextValidator`。
- 保留 `AppSettings.feedbackText` 及迁移别名，保证升级数据可解码；首页继续显示保存值或默认值。
- 更新 `check-standard.ps1` 的必需文件清单。

- [ ] **Step 4: 保留清除确认交互**

清除今日和清除全部继续使用全屏遮罩、取消/确认、底栏交互锁定；不改变现有 Repository 删除范围。

- [ ] **Step 5: 验证并提交**

运行 ohosTest、标准检查、禁用能力扫描和 debug 构建。提交：

```powershell
git add -u
git add entry/src/main/ets/pages/SettingsPage.ets entry/src/main/ets/pages/AboutPage.ets
git commit -m "feat: 重建设定页并清理不可达界面"
```

### Task 6: 六图运行态验收与最终门禁

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`
- Modify: `design-qa.md`
- Create: `docs/qa/screenshots/muyu-reference-*.jpeg`

- [ ] **Step 1: 完整自动门禁**

依次运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
python C:\Users\27363\Desktop\harmonyos-project-standard-cn\scripts\check_harmonyos_standard.py .
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
hdc install -r .\entry\build\default\outputs\ohosTest\entry-ohosTest-unsigned.hap
hdc shell aa test -b com.max.muyu -m entry_test -s unittest OpenHarmonyTestRunner
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode release
git diff --check
```

预期：所有命令退出码 0；release 仅保留已知 unsigned 和混淆提示。

- [ ] **Step 2: 禁止能力和废弃引用扫描**

```powershell
rg -n "\bany\b|http://|https://|WebView|challenge|speedScore|rank|payment|advert" entry/src/main
rg -n "OpenSourceLicensePage|SettingsRoute\.LICENSES|TextValidator" entry/src/main entry/src/ohosTest scripts
```

预期：业务能力扫描无命中；废弃引用为 0。

- [ ] **Step 3: phone 六图验收**

安装最新 debug HAP，分别采集首页、记录、设置的浅色与深色截图。每张布局树必须包含 `bundleName: com.max.muyu`；逐项对照 `docs/ui/reference-2026-07-31/`，确认内容顺序、边距、卡片比例、主体比例、主题色、选中态和底栏。

- [ ] **Step 4: 交互和多设备边界**

验证主题切换不改变所选工具和真实计数；清除弹层背景不可点击；所有关键控件不小于 48vp。tablet/2in1 没有运行设备时继续记录为 `blocked`，不得伪造结果。

- [ ] **Step 5: 回填与最终提交**

更新任务、变更和 QA 记录，只暂存最终六张截图，不暂存中间布局 JSON。提交：

```powershell
git add tasks.md changes.md design-qa.md docs/qa/screenshots/muyu-reference-*.jpeg
git commit -m "feat: 完成深浅主题高保真还原"
```
