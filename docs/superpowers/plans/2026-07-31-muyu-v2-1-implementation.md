# 静心木鱼 V2.1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有 API 24 HarmonyOS 工程上增量完成静心木鱼 V2.1，包括两步引导、三种练习工具、真实本地记录、设置与合规页面，以及 phone/tablet/2in1 适配。

**Architecture:** 保留 `Index.ets` 作为唯一入口和应用壳，将持久化集中在 Repository，将练习状态集中在 `PracticeController`，将系统能力保留在 Service。先完成可回滚的数据 schema 迁移和纯逻辑测试，再接入页面；每个阶段保持可构建并建立本地提交点。

**Tech Stack:** HarmonyOS 6.1.1 API 24、Stage 模型、ArkTS、ArkUI、Preferences、Hypium、Hvigor 6.24.3。

---

## 文件结构

### 新建

- `entry/src/main/ets/pages/ModeSelectPage.ets`：两步首次引导。
- `entry/src/main/ets/pages/PrivacyPolicyPage.ets`：本地隐私说明。
- `entry/src/main/ets/pages/UserNoticePage.ets`：产品边界和用户须知。
- `entry/src/main/ets/pages/OpenSourceLicensePage.ets`：实际依赖许可。
- `entry/src/main/ets/pages/AboutPage.ets`：版本和产品信息。
- `entry/src/main/ets/components/ToolSegmentedControl.ets`：三工具选择。
- `entry/src/main/ets/components/TodaySummaryCard.ets`：今日概览。
- `entry/src/main/ets/components/BeadsView.ets`：念珠热点、手势和反馈。
- `entry/src/main/ets/components/IncenseView.ets`：燃烧进度和减少动画状态。
- `entry/src/main/ets/components/PracticeControlDock.ets`：工具专属控制台。
- `entry/src/main/ets/models/PracticeModels.ets`：V2.1 练习和统计模型。
- `entry/src/main/ets/repositories/PracticeSessionRepository.ets`：真实练习历史。
- `entry/src/main/ets/services/PracticeController.ets`：活动练习唯一真相源。
- `entry/src/main/ets/services/AutoRhythmController.ets`：单定时器节律状态机。
- `entry/src/main/ets/services/IncenseTimer.ets`：时间戳驱动的香计时。
- `entry/src/main/ets/utils/SettingsMigration.ets`：V1 到 V2.1 设置迁移。
- `entry/src/main/ets/utils/StatsMigration.ets`：每日统计幂等迁移。
- `entry/src/ohosTest/ets/test/Migration.test.ets`：迁移回归。
- `entry/src/ohosTest/ets/test/PracticeController.test.ets`：工具状态机回归。
- `entry/src/ohosTest/ets/test/PracticeRepository.test.ets`：历史和汇总回归。

### 修改

- `entry/src/main/ets/models/Enums.ets`、`AppModels.ets`：新增场景、工具、练习状态及兼容字段。
- `entry/src/main/ets/data/JsonCodec.ets`：版本化解码、兼容旧 JSON。
- `entry/src/main/ets/repositories/SettingsRepository.ets`、`StatsRepository.ets`：V2.1 schema 和清除范围。
- `entry/src/main/ets/stores/AppRuntime.ets`、`AppStore.ets`：组合新 Repository 和 Controller。
- `entry/src/main/ets/pages/Index.ets`、`HomePage.ets`、`StatsPage.ets`、`SettingsPage.ets`：新信息架构和页面状态。
- `entry/src/main/ets/components/BottomNavBar.ets`、`WoodenFishView.ets`、`StatsBarChart.ets`：新视觉与强类型接口。
- `entry/src/main/ets/constants/DesignTokens.ets`、`UserModeConfigs.ets`：V2.1 Token 和场景默认值。
- `entry/src/main/resources/base/element/string.json`、`color.json`：展示名、可访问文本和主题资源。
- `entry/src/main/resources/base/profile/main_pages.json`：仍只声明 `pages/Index`。
- `entry/src/ohosTest/ets/test/List.test.ets`：注册新增测试。
- `scripts/check-standard.ps1`：检查 V2.1 必需文件和禁止能力。
- `README.md`、`tasks.md`、`changes.md`、`design.md`、`design-qa.md`、`docs/ui/asset-manifest.md`、`docs/qa/*`：真实状态和证据。

## Task 1：恢复可构建基线

**Files:**
- Modify: `entry/src/main/ets/pages/SettingsPage.ets:301`
- Modify: `scripts/check-standard.ps1:14`
- Modify: `tasks.md`
- Modify: `changes.md`

- [x] **Step 1: 记录基线失败**

运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
```

预期：标准检查报告旧 `ModeSelectPage.ets`、`muyu_dark.png` 缺失；debug 报告 `RowAttribute.flexWrap` 不存在。

- [x] **Step 2: 修复 API 24 布局类型错误**

把文字候选容器改为支持换行的 `Flex`：

```typescript
Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
  ForEach(GENERAL_AVAILABLE_TEXTS, (text: string) => {
    Text(text)
      .fontSize(14)
      .fontColor(this.customText === text ? '#FFFFFF' : this.primaryText())
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.customText === text ? '#9A612C' :
        (this.dark ? '#3B3530' : '#F7EFE4'))
      .borderRadius(20)
      .margin({ right: 8, bottom: 8 })
      .onClick((): void => {
        this.customText = text;
      })
  })
}
.width('100%')
```

- [x] **Step 3: 修正标准检查清单**

删除尚不存在的旧路径，改为当前真实资源：

```powershell
'entry\src\main\resources\base\media\muyu_body_dark.png',
'entry\src\main\resources\base\media\muyu_body_light.png',
```

Task 5 创建引导页时再将 `ModeSelectPage.ets` 加回必需文件。

- [x] **Step 4: 验证并提交**

运行上述标准检查和 debug 构建，预期退出码均为 0，且生成非空 HAP。

```powershell
git add entry/src/main/ets/pages/SettingsPage.ets scripts/check-standard.ps1 tasks.md changes.md
git commit -m "fix: 恢复 V2.1 改造前构建基线"
```

## Task 2：建立版本化设置模型和迁移

**Files:**
- Create: `entry/src/main/ets/utils/SettingsMigration.ets`
- Create: `entry/src/ohosTest/ets/test/Migration.test.ets`
- Modify: `entry/src/main/ets/models/Enums.ets`
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/data/JsonCodec.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [x] **Step 1: 写失败测试**

测试必须断言新用户进入引导、旧 general 用户免引导迁移为日常模式、旧设置被保留、重复迁移结果相同：

```typescript
const fresh: AppSettings = JsonCodec.createDefaultSettings();
expect(fresh.schemaVersion).assertEqual(2);
expect(fresh.initialized).assertFalse();
expect(fresh.selectedTool).assertEqual(ToolType.WOODEN_FISH);

const legacy: string = JSON.stringify({
  initialized: true,
  userMode: 'general',
  themeMode: 'dark',
  currentText: '保持专注',
  volume: 0.35
});
const migrated: AppSettings = JsonCodec.decodeSettings(legacy);
expect(migrated.selectedSceneMode).assertEqual(SceneMode.DAILY);
expect(migrated.themeMode).assertEqual(ThemeMode.DARK);
expect(migrated.feedbackText).assertEqual('保持专注');
expect(JsonCodec.encodeSettings(JsonCodec.decodeSettings(JsonCodec.encodeSettings(migrated))))
  .assertEqual(JsonCodec.encodeSettings(migrated));
```

- [x] **Step 2: 运行 ohosTest 构建并确认失败**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
```

预期：缺少 `SceneMode`、`ToolType`、`schemaVersion` 或迁移字段而失败。

- [x] **Step 3: 最小实现强类型模型**

在 `Enums.ets` 增加设计规格中的 `SceneMode`、`ToolType`、`PracticeStatus`。`AppSettings` 增加 schema、场景、工具、音频、节律和减少动画字段；保留旧字段仅供迁移读取。`SettingsMigration.migrate()` 必须是纯函数，不访问 Preferences。

- [x] **Step 4: 通过测试和 debug 构建后提交**

```powershell
git add entry/src/main/ets/models entry/src/main/ets/data/JsonCodec.ets entry/src/main/ets/utils/SettingsMigration.ets entry/src/ohosTest/ets/test
git commit -m "feat: 增加 V2.1 设置模型和幂等迁移"
```

## Task 3：扩展每日统计和练习历史

**Files:**
- Create: `entry/src/main/ets/models/PracticeModels.ets`
- Create: `entry/src/main/ets/utils/StatsMigration.ets`
- Create: `entry/src/main/ets/repositories/PracticeSessionRepository.ets`
- Create: `entry/src/ohosTest/ets/test/PracticeRepository.test.ets`
- Modify: `entry/src/main/ets/repositories/StatsRepository.ets`
- Modify: `entry/src/main/ets/data/JsonCodec.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [x] **Step 1: 写失败测试**

```typescript
const oldJson: string = JSON.stringify([
  { date: '2026-07-30', manualCount: 4, autoCount: 2, durationSeconds: 30 }
]);
const stats: DailyStats[] = StatsMigration.decode(oldJson);
expect(stats[0].woodenFishManualCount).assertEqual(4);
expect(stats[0].woodenFishAutoCount).assertEqual(2);
expect(stats[0].practiceSeconds).assertEqual(30);
expect(stats[0].incenseSeconds).assertEqual(0);

await sessions.append(new PracticeSession('s1', ToolType.BEADS, SceneMode.DAILY,
  1000, 4000, 3, 0, 3, true));
await sessions.append(new PracticeSession('s1', ToolType.BEADS, SceneMode.DAILY,
  1000, 4000, 3, 0, 3, true));
expect((await sessions.recent(10)).length).assertEqual(1);
```

- [x] **Step 2: 运行 ohosTest 构建并确认失败**

预期：新模型、迁移和 Repository 尚不存在。

- [x] **Step 3: 实现 schema 与 Repository**

`DailyStats` 和 `PracticeSession` 字段严格使用设计规格命名。`StatsRepository.applySession(session)` 先按 session id 幂等，再更新对应日期；`PracticeSessionRepository` 使用串行写队列并提供 `append`、`recent(limit)`、`all`、`clearDate`、`clearAll`。

- [x] **Step 4: 验证快速并发、迁移和清除范围后提交**

```powershell
git add entry/src/main/ets/models/PracticeModels.ets entry/src/main/ets/utils/StatsMigration.ets entry/src/main/ets/repositories entry/src/main/ets/data/JsonCodec.ets entry/src/ohosTest/ets/test
git commit -m "feat: 增加多工具统计和真实练习历史"
```

## Task 4：实现统一练习状态机

**Files:**
- Create: `entry/src/main/ets/services/AutoRhythmController.ets`
- Create: `entry/src/main/ets/services/IncenseTimer.ets`
- Create: `entry/src/main/ets/services/PracticeController.ets`
- Create: `entry/src/ohosTest/ets/test/PracticeController.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写失败测试**

覆盖单定时器、木鱼/念珠计数、前台暂停继续、后台提交新会话、香计时墙钟校正和只完成一次：

```typescript
controller.selectTool(ToolType.WOODEN_FISH);
controller.startAuto(1000, 60);
expect(controller.hasActiveTimer()).assertTrue();
expect(controller.startAuto(1000, 60)).assertFalse();
controller.pause();
expect(controller.state.status).assertEqual(PracticeStatus.PAUSED);
controller.resume();
controller.onBackground(5000);
expect(controller.hasActiveTimer()).assertFalse();

timer.start(1000, 300);
expect(timer.remainingAt(61000)).assertEqual(240);
timer.pause(61000);
expect(timer.remainingAt(121000)).assertEqual(240);
```

- [ ] **Step 2: 确认测试失败后实现最小状态机**

Controller 通过回调发出强类型 `PracticeEvent`，不直接访问 ArkUI 或 Preferences。`AutoRhythmController` 只持有一个 timer id；`IncenseTimer` 接受可注入时间值，纯逻辑计算剩余时间。

- [ ] **Step 3: 替换旧目标状态并验证**

删除业务层 `TARGET` 入口和目标封顶分支；旧 `SessionMode` 仅在迁移兼容处保留。运行全部 ohosTest 构建和 debug 构建。

- [ ] **Step 4: 提交**

```powershell
git add entry/src/main/ets/services entry/src/main/ets/models entry/src/ohosTest/ets/test
git commit -m "feat: 实现三工具统一练习状态机"
```

## Task 5：恢复两步引导和新应用壳

**Files:**
- Create: `entry/src/main/ets/pages/ModeSelectPage.ets`
- Create: `entry/src/main/ets/components/ToolSegmentedControl.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/constants/UserModeConfigs.ets`
- Modify: `entry/src/main/ets/components/BottomNavBar.ets`
- Modify: `scripts/check-standard.ps1`

- [ ] **Step 1: 写场景默认值和初始化路由测试**

断言三场景默认主题、音色、文字和推荐工具与规格表一致；新用户显示引导，升级用户直接进入主壳。

- [ ] **Step 2: 实现两步引导**

第一步只能选择场景，第二步只能选择工具；“开始使用”保存完整设置后进入主壳。选中态必须包含边框、勾选和文字；每个卡片热区至少 48vp。

- [ ] **Step 3: 接入三一级导航和响应式壳**

Compact 使用底栏；Medium 使用受控宽度；Expanded 允许侧边一级导航。`main_pages.json` 仍只声明 `pages/Index`。

- [ ] **Step 4: 将引导页加入标准清单并提交**

```powershell
git add entry/src/main/ets/pages/Index.ets entry/src/main/ets/pages/ModeSelectPage.ets entry/src/main/ets/components entry/src/main/ets/constants scripts/check-standard.ps1
git commit -m "feat: 恢复场景和默认工具两步引导"
```

## Task 6：整理并接入 V2.1 视觉资源

**Files:**
- Create: `entry/src/main/resources/base/media/practice_wooden_fish.png`
- Create: `entry/src/main/resources/base/media/practice_beads.png`
- Create: `entry/src/main/resources/base/media/practice_incense_base.png`
- Create: `entry/src/main/resources/base/media/practice_incense_smoke.png`
- Modify: `docs/ui/asset-manifest.md`
- Modify: `entry/src/main/ets/constants/DesignTokens.ets`

- [ ] **Step 1: 验证源图尺寸、alpha 和授权字段**

记录三张源图为 1024 x 1536 ARGB；清单必须包含来源、用户提供日期、授权状态、裁边和拆层方式。授权状态未知时标记“待用户提供证明”，不得写成已授权。

- [ ] **Step 2: 生成裁边和分层资源**

使用可复现图像命令裁掉透明留白；木鱼静止图不得保留烘焙点击圈。一炷香拆为基础层和烟雾层。若源图无法无损拆分，保留源图但将发布验收标为 `blocked`，不得粗糙涂抹。

- [ ] **Step 3: 更新视觉 Token 并构建验证**

集中定义背景、卡片、木色、强调色、间距、字号和 48vp 热区；不在页面散落重复色值。

- [ ] **Step 4: 提交**

```powershell
git add entry/src/main/resources/base/media entry/src/main/ets/constants/DesignTokens.ets docs/ui/asset-manifest.md
git commit -m "feat: 接入 V2.1 三工具视觉资源"
```

## Task 7：重建练习页和木鱼体验

**Files:**
- Create: `entry/src/main/ets/components/TodaySummaryCard.ets`
- Create: `entry/src/main/ets/components/PracticeControlDock.ets`
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `entry/src/main/ets/components/WoodenFishView.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: 写木鱼快速计数和事件序列测试**

连续 100 次手动输入必须得到 100；音效失败不能回滚计数；手动和自动共享递增反馈序列。

- [ ] **Step 2: 实现 V2 练习页层级**

按“标题/离线标识、今日概览、工具选择、练习画布、计数、控制区、音频控制台、一级导航”顺序组合。页面只消费 Store 展示模型和强类型回调。

- [ ] **Step 3: 完成木鱼静止和点击状态**

点击光圈、回弹和浮字由 ArkUI 独立绘制；减少动画时取消位移但保留计数和状态反馈。木鱼可视范围外扩为点击热区。

- [ ] **Step 4: debug 构建和 phone 截图对照后提交**

```powershell
git add entry/src/main/ets/pages/HomePage.ets entry/src/main/ets/pages/Index.ets entry/src/main/ets/components
git commit -m "feat: 重建 V2.1 练习页和木鱼体验"
```

## Task 8：实现念珠交互

**Files:**
- Create: `entry/src/main/ets/components/BeadsView.ets`
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `entry/src/main/ets/services/PracticeController.ets`
- Modify: `entry/src/ohosTest/ets/test/PracticeController.test.ets`

- [ ] **Step 1: 写点击、轻扫和节点失败测试**

一次手势只能计一次；27、54、108 节点各触发一次提示；109 次不触发 108 提示。

- [ ] **Step 2: 实现热点和高亮层**

热点坐标以源图宽高为基准按容器等比映射；点击和轻扫归一化为一次 `recordManual()`。选中珠子同时使用亮度和外圈，不只依赖颜色。

- [ ] **Step 3: 接入自动节律、音效和振动并验证**

切出念珠立即停止自动任务并提交会话；节点提示遵循用户振动和音效开关。

- [ ] **Step 4: 提交**

```powershell
git add entry/src/main/ets/components/BeadsView.ets entry/src/main/ets/pages/HomePage.ets entry/src/main/ets/services/PracticeController.ets entry/src/ohosTest/ets/test/PracticeController.test.ets
git commit -m "feat: 增加念珠计数和节点反馈"
```

## Task 9：实现一炷香计时

**Files:**
- Create: `entry/src/main/ets/components/IncenseView.ets`
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `entry/src/main/ets/services/IncenseTimer.ets`
- Modify: `entry/src/main/ets/services/PracticeController.ets`
- Modify: `entry/src/ohosTest/ets/test/PracticeController.test.ets`

- [ ] **Step 1: 写预设、暂停、后台恢复和完成一次测试**

分别覆盖 5/10/15/20/30 分钟，暂停不扣减，墙钟跨越后剩余准确，同一完成状态重复刷新只写一个 session。

- [ ] **Step 2: 实现燃烧进度和控制区**

进度为 `1 - remaining / target` 并限制在 0..1；减少动画时使用静态烟雾。点击香体不增加次数。

- [ ] **Step 3: 接入生命周期和持久化**

后台保存开始时间、目标时长、累计暂停时长和状态；回前台按墙钟恢复，完成后写入真实时长。

- [ ] **Step 4: 提交**

```powershell
git add entry/src/main/ets/components/IncenseView.ets entry/src/main/ets/pages/HomePage.ets entry/src/main/ets/services entry/src/ohosTest/ets/test
git commit -m "feat: 增加一炷香静心计时"
```

## Task 10：重建记录页

**Files:**
- Modify: `entry/src/main/ets/pages/StatsPage.ets`
- Modify: `entry/src/main/ets/components/StatsBarChart.ets`
- Modify: `entry/src/main/ets/services/StatsPeriodService.ets`
- Modify: `entry/src/main/ets/stores/AppStore.ets`
- Modify: `entry/src/ohosTest/ets/test/StatsPeriod.test.ets`

- [ ] **Step 1: 写口径、单位和真实历史测试**

次数只包含木鱼和念珠；时长独立统计；旧汇总进入趋势但不生成历史；最近历史顺序按 `startTime` 倒序。

- [ ] **Step 2: 实现今日/本周/本月/全部视图模型**

`StatsPeriodService` 保持纯逻辑，输出摘要、次数桶、时长桶和工具分类；不得用次数与分钟计算同一比例。

- [ ] **Step 3: 按 V2 稿重建记录页并验证空状态**

没有会话时显示明确空状态，不显示稿件中的 07:20、12:15、21:00 示例数据。

- [ ] **Step 4: 提交**

```powershell
git add entry/src/main/ets/pages/StatsPage.ets entry/src/main/ets/components/StatsBarChart.ets entry/src/main/ets/services/StatsPeriodService.ets entry/src/main/ets/stores/AppStore.ets entry/src/ohosTest/ets/test
git commit -m "feat: 重建多工具本地记录页"
```

## Task 11：重建设置和合规页面

**Files:**
- Create: `entry/src/main/ets/pages/PrivacyPolicyPage.ets`
- Create: `entry/src/main/ets/pages/UserNoticePage.ets`
- Create: `entry/src/main/ets/pages/OpenSourceLicensePage.ets`
- Create: `entry/src/main/ets/pages/AboutPage.ets`
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/stores/AppStore.ets`
- Modify: `entry/src/main/resources/base/element/string.json`

- [ ] **Step 1: 写清除今日和清除全部测试**

清除今日只删除当天统计和当天 session；清除全部删除设置、统计和历史，重新启动显示首次引导。

- [ ] **Step 2: 按六组设置重建页面**

实现练习、音频、显示、文字触感、数据、关于合规六组；移除 V2.1 未承诺的数据导出和背景音乐入口。所有开关和纯图标按钮提供可朗读说明。

- [ ] **Step 3: 实现四个真实二级页面**

隐私页只描述实际本地行为；用户须知明确非宗教和医疗功效；许可页列出打包的 Hypium 仅为测试依赖且不进入运行包；关于页从资源读取展示名和版本，不能硬编码虚假备案信息。

- [ ] **Step 4: 验证返回、二次确认和持久化后提交**

```powershell
git add entry/src/main/ets/pages entry/src/main/ets/stores/AppStore.ets entry/src/main/resources/base/element/string.json entry/src/ohosTest/ets/test
git commit -m "feat: 重建设置和本地合规页面"
```

## Task 12：多设备、视觉和最终门禁

**Files:**
- Modify: `entry/src/main/ets/utils/ResponsiveLayout.ets`
- Modify: `entry/src/main/ets/pages/*.ets`
- Modify: `entry/src/main/ets/components/*.ets`
- Modify: `README.md`
- Modify: `tasks.md`
- Modify: `changes.md`
- Modify: `design.md`
- Modify: `design-qa.md`
- Modify: `docs/qa/*`
- Modify: `docs/ui/asset-manifest.md`

- [ ] **Step 1: 完成三个断点布局检查**

Compact `<600vp` 使用 phone 单栏；Medium `600-1023vp` 双栏；Expanded `>=1024vp` 主画布加固定信息/控制栏。系统字体放大、横屏和窗口缩放不得重叠。

- [ ] **Step 2: phone 逐屏高保真 QA**

对练习、记录、设置进行真实运行截图；记录颜色、间距、素材比例、字号、48vp 热区及因系统规范产生的差异。不得把参考稿状态栏绘制进应用。

- [ ] **Step 3: 执行完整门禁**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode release
rg -n "\bany\b|http://|https://|WebView|challenge|speedScore|rank|payment|advert" entry/src/main
```

预期：前三项检查和三个构建退出码为 0；禁止能力扫描无业务命中；主 HAP 只有振动权限。

- [ ] **Step 4: 设备验证与文档**

phone、tablet、2in1 分别记录设备、系统版本、截图和交互结果。缺少对应设备时仅将该设备项标记 `blocked`，写明连接 API 24 目标后恢复验证。

- [ ] **Step 5: 最终提交**

```powershell
git add README.md tasks.md changes.md design.md design-qa.md docs/qa docs/ui entry/src/main
git commit -m "feat: 完成静心木鱼 V2.1 多设备版本"
```

## 执行规则

- 每个 Task 开始前确认 `git status --short`，不覆盖用户或其他任务的未提交改动。
- 每个业务 Task 必须先出现可解释的失败测试，再写实现。
- 每次提交只包含当前 Task 文件；构建产物、IDE 配置、签名和凭据不提交。
- 同一 worktree 的 default 与 ohosTest Hvigor 构建必须串行执行，避免输出目录清理竞争。
- 若当前 Task 的测试或 debug 构建失败，不进入下一 Task。
- 每完成一个 Task 更新本计划复选框、`tasks.md` 和 `changes.md`，使后续会话可从本地文件和 Git 日志恢复。
