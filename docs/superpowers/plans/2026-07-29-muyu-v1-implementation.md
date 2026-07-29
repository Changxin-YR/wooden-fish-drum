# 功德木鱼 HarmonyOS V1.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建可在 HarmonyOS 6.1.1 API 24 上编译运行的功德木鱼 V1.0，支持 phone、tablet、2in1，完成模式选择、敲击反馈、会话模式、设置、统计和本地持久化。

**Architecture:** 单一 Stage 模型 `entry` 模块，`Index` 作为唯一入口并承载原生 Navigation；页面依赖共享 AppStore，AppStore 通过 Repository 和 Service 编排 Preferences、统计、会话、音频与振动。三种用户模式只读取统一配置表，所有设备复用一套响应式页面。

**Tech Stack:** ArkTS、ArkUI、HarmonyOS NEXT API 24、Preferences、SoundPool、Vibrator、Hypium、Hvigor 6.24.3。

---

## 文件结构

```text
AppScope/
entry/src/main/ets/
├── entryability/EntryAbility.ets
├── pages/Index.ets
├── pages/ModeSelectPage.ets
├── pages/HomePage.ets
├── pages/StatsPage.ets
├── pages/SettingsPage.ets
├── components/ModeSelectCard.ets
├── components/WoodenFishView.ets
├── components/FloatingTextLayer.ets
├── components/BottomNavBar.ets
├── components/StatsBarChart.ets
├── models/AppModels.ets
├── models/NavigationModels.ets
├── models/FeedbackModels.ets
├── constants/UserModeConfigs.ets
├── constants/DesignTokens.ets
├── data/PreferencesStore.ets
├── data/JsonCodec.ets
├── repositories/SettingsRepository.ets
├── repositories/StatsRepository.ets
├── services/SessionService.ets
├── services/AudioService.ets
├── services/VibrationService.ets
├── stores/AppStore.ets
└── utils/DateUtil.ets
entry/src/ohosTest/ets/test/
├── TestDoubles.ets
├── UserModeConfig.test.ets
├── DateUtil.test.ets
├── JsonCodec.test.ets
├── StatsRepository.test.ets
├── SessionService.test.ets
├── ModeSwitch.test.ets
└── ResponsiveLayout.test.ets
```

## Task 1: 标准 Stage 工程骨架

**Files:**
- Create: `AppScope/app.json5`
- Create: `build-profile.json5`
- Create: `oh-package.json5`
- Create: `package.json`
- Create: `hvigorfile.ts`
- Create: `hvigor/hvigor-config.json5`
- Create: `entry/build-profile.json5`
- Create: `entry/oh-package.json5`
- Create: `entry/hvigorfile.ts`
- Create: `entry/src/main/module.json5`
- Create: `entry/src/main/resources/base/profile/main_pages.json`
- Create: `entry/src/main/ets/entryability/EntryAbility.ets`
- Create: `entry/src/main/ets/pages/Index.ets`
- Create: `entry/src/ohosTest/module.json5`
- Create: `entry/src/ohosTest/ets/test/List.test.ets`
- Copy from local API 24 reference: `vendor/hypium/`
- Create: `README.md`, `AGENTS.md`, `tasks.md`, `changes.md`, `design.md`, `design-qa.md`
- Create: `docs/qa/README.md`, `scripts/check-standard.ps1`, `scripts/build-harmony.ps1`

- [ ] **Step 1: 创建 API 24 根工程配置**

```json5
{
  "app": {
    "signingConfigs": [],
    "products": [{
      "name": "default",
      "compatibleSdkVersion": "6.1.1(24)",
      "targetSdkVersion": "6.1.1(24)",
      "runtimeOS": "HarmonyOS"
    }],
    "buildModeSet": [{ "name": "debug" }, { "name": "release" }]
  },
  "modules": [{ "name": "entry", "srcPath": "./entry", "targets": [{ "name": "default", "applyToProducts": ["default"] }] }]
}
```

- [ ] **Step 2: 创建 `module.json5`，只声明振动权限和三类设备**

```json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    "mainElement": "EntryAbility",
    "deviceTypes": ["phone", "tablet", "2in1"],
    "deliveryWithInstall": true,
    "installationFree": false,
    "pages": "$profile:main_pages",
    "requestPermissions": [{ "name": "ohos.permission.VIBRATE" }],
    "abilities": [{
      "name": "EntryAbility",
      "srcEntry": "./ets/entryability/EntryAbility.ets",
      "icon": "$media:app_icon",
      "label": "$string:app_name",
      "exported": true,
      "skills": [{ "entities": ["entity.system.home"], "actions": ["action.system.home"] }]
    }]
  }
}
```

- [ ] **Step 3: 创建最小 Ability 与 Index**

```typescript
export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index');
  }
}

@Entry
@Component
struct Index {
  build() {
    Column() { Text('功德木鱼') }.width('100%').height('100%')
  }
}
```

- [ ] **Step 4: 运行静态门禁和首次 debug 构建**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1`

Expected: `Standard project check passed.`

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug`

Expected: exit 0 and a non-empty `entry-default-signed.hap` or `entry-default-unsigned.hap`.

- [ ] **Step 5: 构建空测试 HAP，验证本地 Hypium 依赖可用**

Run: `hvigorw --mode module -p product=default -p module=entry@ohosTest assembleHap --no-daemon`

Expected: exit 0 and a non-empty `entry_test-default-signed.hap` or `entry_test-default-unsigned.hap`.

- [ ] **Step 6: Commit**

```powershell
git add AppScope entry hvigor vendor package.json oh-package.json5 hvigorfile.ts build-profile.json5 README.md AGENTS.md tasks.md changes.md design.md design-qa.md docs/qa scripts
git commit -m "build: scaffold HarmonyOS API 24 application"
```

## Task 2: 强类型模型、模式配置和响应式规则

**Files:**
- Create: `entry/src/main/ets/models/AppModels.ets`
- Create: `entry/src/main/ets/models/NavigationModels.ets`
- Create: `entry/src/main/ets/constants/UserModeConfigs.ets`
- Create: `entry/src/main/ets/constants/DesignTokens.ets`
- Create: `entry/src/main/ets/utils/DateUtil.ets`
- Test: `entry/src/ohosTest/ets/test/UserModeConfig.test.ets`
- Test: `entry/src/ohosTest/ets/test/DateUtil.test.ets`
- Test: `entry/src/ohosTest/ets/test/ResponsiveLayout.test.ets`

- [ ] **Step 1: 写模式配置、日期和断点失败测试**

```typescript
it('usesProgrammerDefaults', 0, (): void => {
  const config: UserModeConfig = USER_MODE_CONFIGS[UserMode.PROGRAMMER];
  expect(config.defaultText).assertEqual('Bug-1');
  expect(config.defaultTheme).assertEqual(ThemeMode.DARK);
  expect(config.recommendedTargets.length).assertEqual(4);
});

it('formatsLocalDate', 0, (): void => {
  expect(DateUtil.formatDate(new Date(2026, 6, 29))).assertEqual('2026-07-29');
});

it('mapsWindowWidthsToLayouts', 0, (): void => {
  expect(ResponsiveLayout.forWidth(599)).assertEqual(LayoutSize.COMPACT);
  expect(ResponsiveLayout.forWidth(600)).assertEqual(LayoutSize.MEDIUM);
  expect(ResponsiveLayout.forWidth(1024)).assertEqual(LayoutSize.EXPANDED);
});
```

- [ ] **Step 2: 增加最小可编译声明并运行测试，确认断言失败**

Run: `hvigorw --mode module -p product=default -p module=entry@ohosTest assembleHap --no-daemon`

Expected: Hypium reports assertion failures because the temporary declarations return empty/default values. The failure must name `usesProgrammerDefaults`, `formatsLocalDate`, or `mapsWindowWidthsToLayouts`, not a syntax/import error.

- [ ] **Step 3: 实现枚举、接口、配置和纯函数**

```typescript
export enum LayoutSize { COMPACT = 'compact', MEDIUM = 'medium', EXPANDED = 'expanded' }

export class ResponsiveLayout {
  static forWidth(width: number): LayoutSize {
    if (width >= 1024) return LayoutSize.EXPANDED;
    if (width >= 600) return LayoutSize.MEDIUM;
    return LayoutSize.COMPACT;
  }
}

export class DateUtil {
  static formatDate(value: Date): string {
    const month: string = `${value.getMonth() + 1}`.padStart(2, '0');
    const day: string = `${value.getDate()}`.padStart(2, '0');
    return `${value.getFullYear()}-${month}-${day}`;
  }
}

export class DailyRecordModel implements DailyRecord {
  constructor(
    public date: string,
    public manualCount: number,
    public autoCount: number,
    public durationSeconds: number
  ) {}
  get totalCount(): number { return this.manualCount + this.autoCount; }
}

```

- [ ] **Step 4: 重新构建并在模拟器运行 Hypium**

Run: install main/test HAP, then `hdc shell aa test -b com.max.muyu -m entry_test -s unittest OpenHarmonyTestRunner`

Expected: `Failure: 0`, `Error: 0`, `TestFinished-ResultCode: 0`.

- [ ] **Step 5: Commit**

```powershell
git add entry/src/main/ets/models entry/src/main/ets/constants entry/src/main/ets/utils entry/src/ohosTest
git commit -m "feat: add typed modes and responsive rules"
```

## Task 3: Preferences、JSON 编解码和 Repository

**Files:**
- Create: `entry/src/main/ets/data/LocalStoreAdapter.ets`
- Create: `entry/src/main/ets/data/PreferencesStore.ets`
- Create: `entry/src/main/ets/data/JsonCodec.ets`
- Create: `entry/src/main/ets/repositories/SettingsRepository.ets`
- Create: `entry/src/main/ets/repositories/StatsRepository.ets`
- Create: `entry/src/ohosTest/ets/test/TestDoubles.ets`
- Test: `entry/src/ohosTest/ets/test/JsonCodec.test.ets`
- Test: `entry/src/ohosTest/ets/test/StatsRepository.test.ets`

- [ ] **Step 1: 写设置默认值、损坏 JSON、跨日和汇总失败测试**

```typescript
class MemoryStore implements LocalStoreAdapter {
  private values: Map<string, string> = new Map<string, string>();
  async getString(key: string, fallback: string): Promise<string> {
    return this.values.get(key) ?? fallback;
  }
  async putString(key: string, value: string): Promise<void> {
    this.values.set(key, value);
  }
  async remove(key: string): Promise<void> {
    this.values.delete(key);
  }
}

it('loadsSafeDefaultsFromInvalidSettings', 0, (): void => {
  const settings: AppSettings = JsonCodec.decodeSettings('{broken');
  expect(settings.initialized).assertFalse();
  expect(settings.userMode).assertEqual(UserMode.PROGRAMMER);
});

it('derivesTotalsFromDailyRecords', 0, async (): Promise<void> => {
  const repository: StatsRepository = new StatsRepository(new MemoryStore());
  await repository.replace([
    new DailyRecordModel('2026-07-28', 2, 3, 0),
    new DailyRecordModel('2026-07-29', 4, 1, 0)
  ]);
  expect((await repository.summary('2026-07-29')).totalCount).assertEqual(10);
});
```

- [ ] **Step 2: 增加最小可编译 Repository 声明并运行 Hypium，确认断言失败**

Expected: tests fail because codec/repositories do not exist.

- [ ] **Step 3: 实现适配器、Preferences 封装、编解码和 Repository**

```typescript
export interface LocalStoreAdapter {
  getString(key: string, fallback: string): Promise<string>;
  putString(key: string, value: string): Promise<void>;
  remove(key: string): Promise<void>;
}

export class SettingsRepository {
  constructor(private readonly store: LocalStoreAdapter) {}
  async load(): Promise<AppSettings> {
    return JsonCodec.decodeSettings(await this.store.getString('settings', ''));
  }
  async save(settings: AppSettings): Promise<boolean> {
    try {
      await this.store.putString('settings', JsonCodec.encodeSettings(settings));
      return true;
    } catch {
      return false;
    }
  }
}
```

- [ ] **Step 4: 运行全部 Hypium 测试**

Expected: settings, codec, date rollover, recent seven days, totals and clear tests pass.

- [ ] **Step 5: Commit**

```powershell
git add entry/src/main/ets/data entry/src/main/ets/repositories entry/src/ohosTest
git commit -m "feat: persist settings and daily statistics"
```

## Task 4: 首次启动、AppStore、Navigation 和模式选择 UI

**Files:**
- Create: `entry/src/main/ets/stores/AppStore.ets`
- Create: `entry/src/main/ets/pages/ModeSelectPage.ets`
- Create: `entry/src/main/ets/components/ModeSelectCard.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Create assets: `entry/src/main/resources/base/media/muyu_brand.png`, `mode_programmer.png`, `mode_monk.png`, `mode_general.png`
- Test: `entry/src/ohosTest/ets/test/ModeSwitch.test.ets`
- Test helper: `entry/src/ohosTest/ets/test/TestDoubles.ets`

- [ ] **Step 1: 写初始化与模式切换失败测试**

```typescript
function createTestStore(): AppStore {
  const memory: MemoryStore = new MemoryStore();
  return new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
}

it('initializesSelectedMode', 0, async (): Promise<void> => {
  const store: AppStore = createTestStore();
  await store.selectInitialMode(UserMode.MONK);
  expect(store.settings.initialized).assertTrue();
  expect(store.settings.userMode).assertEqual(UserMode.MONK);
  expect(store.settings.currentText).assertEqual('功德+1');
});
```

- [ ] **Step 2: 运行测试确认失败**

Expected: `selectInitialMode` is missing.

- [ ] **Step 3: 实现 AppStore 和根导航切换**

```typescript
async selectInitialMode(mode: UserMode): Promise<boolean> {
  this.settings = createSettingsForMode(mode);
  const saved: boolean = await this.settingsRepository.save(this.settings);
  this.initialized = saved;
  return saved;
}
```

- [ ] **Step 4: 从用户原图裁切模式页生产资源并登记 asset manifest**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\prepare-ui-assets.ps1`

Expected: four PNG files exist, dimensions are logged, no screenshot文字被烘焙进人物资源。

- [ ] **Step 5: 实现高保真模式选择页和 Medium/Expanded 双栏**

```typescript
ModeSelectCard({
  config: USER_MODE_CONFIGS[mode],
  selected: this.selectedMode === mode,
  onSelect: (value: UserMode): void => { this.selectedMode = value; }
})
```

- [ ] **Step 6: 构建、安装、验证首次启动与重启**

Expected: first launch shows selection; confirmation shows Home; force-stop and restart stays on Home.

- [ ] **Step 7: Commit**

```powershell
git add entry scripts docs/ui
git commit -m "feat: add persistent onboarding flow"
```

## Task 5: 敲击统计与会话状态机

**Files:**
- Create: `entry/src/main/ets/services/SessionService.ets`
- Extend: `entry/src/main/ets/stores/AppStore.ets`
- Test: `entry/src/ohosTest/ets/test/SessionService.test.ets`
- Test: `entry/src/ohosTest/ets/test/StatsRepository.test.ets`

- [ ] **Step 1: 写快速敲击、目标、限时和重复定时器失败测试**

```typescript
it('countsEveryRapidManualHit', 0, (): void => {
  const session: SessionService = new SessionService();
  for (let index: number = 0; index < 100; index++) session.recordManualHit();
  expect(session.state.currentCount).assertEqual(100);
});

it('stopsExactlyAtTarget', 0, (): void => {
  const session: SessionService = new SessionService();
  session.startTarget(3);
  session.recordManualHit();
  session.recordManualHit();
  session.recordManualHit();
  expect(session.state.running).assertFalse();
  expect(session.state.currentCount).assertEqual(3);
});

it('rejectsSecondAutoStart', 0, (): void => {
  const session: SessionService = new SessionService();
  expect(session.startAuto(1000)).assertTrue();
  expect(session.startAuto(1000)).assertFalse();
  session.stop();
});
```

- [ ] **Step 2: 运行测试确认失败**

- [ ] **Step 3: 实现纯状态机和唯一计时器所有权**

```typescript
startAuto(intervalMs: number): boolean {
  if (this.timerId !== -1 || this.state.running) return false;
  this.state = createRunningSession(SessionMode.AUTO);
  this.timerId = setInterval((): void => this.recordAutoHit(), intervalMs);
  return true;
}

stop(): void {
  if (this.timerId !== -1) clearInterval(this.timerId);
  this.timerId = -1;
  this.state = createIdleSession();
}
```

- [ ] **Step 4: 运行全部状态机和统计测试**

- [ ] **Step 5: Commit**

```powershell
git add entry/src/main/ets/services entry/src/main/ets/stores entry/src/ohosTest
git commit -m "feat: add counting and session state machine"
```

## Task 6: 音频、振动、木鱼组件和首页

**Files:**
- Create: `entry/src/main/ets/services/AudioService.ets`
- Create: `entry/src/main/ets/services/VibrationService.ets`
- Create: `entry/src/main/ets/models/FeedbackModels.ets`
- Create: `entry/src/main/ets/components/WoodenFishView.ets`
- Create: `entry/src/main/ets/components/FloatingTextLayer.ets`
- Create: `entry/src/main/ets/components/BottomNavBar.ets`
- Create: `entry/src/main/ets/pages/HomePage.ets`
- Create raw resources: `entry/src/main/resources/rawfile/sounds/deep.wav`, `crisp.wav`, `soft.wav`
- Create media: `muyu_light.png`, `muyu_dark.png`

- [ ] **Step 1: 写敲击副作用计划失败测试**

```typescript
it('createsOneFeedbackPlanPerHit', 0, (): void => {
  const plan: HitFeedbackPlan = HitFeedbackPlan.create(true, true, true, 'Bug-1');
  expect(plan.playSound).assertTrue();
  expect(plan.vibrate).assertTrue();
  expect(plan.floatingText).assertEqual('Bug-1');
});
```

- [ ] **Step 2: 运行测试确认失败**

- [ ] **Step 3: 实现 SoundPool 和振动降级服务**

```typescript
async play(type: SoundType, volume: number): Promise<void> {
  const soundId: number | undefined = this.soundIds.get(type);
  if (this.pool === null || soundId === undefined) return;
  await this.pool.play(soundId, { loop: 0, rate: audio.AudioRendererRate.RENDER_RATE_NORMAL, leftVolume: volume, rightVolume: volume, priority: 0 });
}
```

- [ ] **Step 4: 实现首页交互和 200ms 非阻塞回弹**

```typescript
.onClick((): void => {
  this.onHit();
  this.scaleValue = 0.95;
  animateTo({ duration: 100 }, (): void => { this.scaleValue = 1.02; });
  animateTo({ duration: 100, delay: 100 }, (): void => { this.scaleValue = 1; });
})
```

- [ ] **Step 5: 验证 100 次快速点击、音频失败降级和最多三条浮动文字**

- [ ] **Step 6: Commit**

```powershell
git add entry/src/main/ets entry/src/main/resources scripts docs/ui
git commit -m "feat: implement wooden fish feedback experience"
```

## Task 7: 设置、文字和模式切换

**Files:**
- Create: `entry/src/main/ets/pages/SettingsPage.ets`
- Extend: `entry/src/main/ets/stores/AppStore.ets`
- Test: `entry/src/ohosTest/ets/test/ModeSwitch.test.ets`

- [ ] **Step 1: 写自定义文字和主题保留失败测试**

```typescript
it('keepsCustomTextAndManualThemeWhenSwitchingMode', 0, async (): Promise<void> => {
  const store: AppStore = createTestStore();
  await store.saveCustomText('保持专注');
  await store.setThemeMode(ThemeMode.DARK);
  await store.switchMode(UserMode.GENERAL);
  expect(store.settings.currentText).assertEqual('保持专注');
  expect(store.settings.themeMode).assertEqual(ThemeMode.DARK);
});
```

- [ ] **Step 2: 运行测试确认失败**

- [ ] **Step 3: 实现模式切换、文字校验和设置保存**

```typescript
async switchMode(mode: UserMode): Promise<boolean> {
  const currentConfig: UserModeConfig = USER_MODE_CONFIGS[this.settings.userMode];
  const currentIsPreset: boolean = currentConfig.availableTexts.includes(this.settings.currentText);
  const next: AppSettings = JsonCodec.decodeSettings(JsonCodec.encodeSettings(this.settings));
  next.userMode = mode;
  if (currentIsPreset) next.currentText = USER_MODE_CONFIGS[mode].defaultText;
  if (!next.themeManuallyChanged) next.themeMode = USER_MODE_CONFIGS[mode].defaultTheme;
  this.settings = next;
  return this.settingsRepository.save(next);
}
```

- [ ] **Step 4: 实现设置页四个分组和清除确认 Dialog**

- [ ] **Step 5: 构建并验证设置重启持久化**

- [ ] **Step 6: Commit**

```powershell
git add entry/src/main/ets entry/src/ohosTest
git commit -m "feat: add settings and mode switching"
```

## Task 8: 目标、限时和自动控制面板

**Files:**
- Extend: `entry/src/main/ets/pages/HomePage.ets`
- Extend: `entry/src/main/ets/services/SessionService.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`
- Test: `entry/src/ohosTest/ets/test/SessionService.test.ets`

- [ ] **Step 1: 写暂停、继续、后台停止和结束摘要失败测试**

```typescript
it('stopsWhenApplicationMovesToBackground', 0, (): void => {
  const session: SessionService = new SessionService();
  session.startAuto(500);
  session.onBackground();
  expect(session.state.running).assertFalse();
  expect(session.hasTimer()).assertFalse();
});
```

- [ ] **Step 2: 运行测试确认失败**

- [ ] **Step 3: 实现底部 Sheet、目标快捷值、限时时长与自动间隔**

- [ ] **Step 4: 将 Ability 后台事件接入 AppStore flush + SessionService stop**

- [ ] **Step 5: 验证目标准确停止、限时摘要和自动唯一计时器**

- [ ] **Step 6: Commit**

```powershell
git add entry/src/main/ets entry/src/ohosTest
git commit -m "feat: add target timer and auto sessions"
```

## Task 9: 统计页和多设备布局

**Files:**
- Create: `entry/src/main/ets/pages/StatsPage.ets`
- Create: `entry/src/main/ets/components/StatsBarChart.ets`
- Extend: `entry/src/main/ets/pages/ModeSelectPage.ets`
- Extend: `entry/src/main/ets/pages/HomePage.ets`
- Extend: `entry/src/main/ets/pages/SettingsPage.ets`
- Test: `entry/src/ohosTest/ets/test/ResponsiveLayout.test.ets`

- [ ] **Step 1: 写最近 7 天零填充和断点布局失败测试**

```typescript
it('returnsSevenOrderedDaysWithZeroFill', 0, async (): Promise<void> => {
  const values: DailyRecord[] = await repository.recentDays('2026-07-29', 7);
  expect(values.length).assertEqual(7);
  expect(values[6].date).assertEqual('2026-07-29');
});
```

- [ ] **Step 2: 运行测试确认失败**

- [ ] **Step 3: 实现 ArkUI 柱图和统计摘要**

```typescript
ForEach(this.records, (record: DailyRecord): void => {
  Column() {
    Text(`${record.totalCount}`)
    Row().height(this.barHeight(record.totalCount)).backgroundColor(this.colors.accent)
    Text(DateUtil.shortLabel(record.date))
  }.layoutWeight(1)
})
```

- [ ] **Step 4: 实现 Compact/Medium/Expanded 页面重排**

- [ ] **Step 5: 在 phone、tablet、2in1 模拟器或真机记录截图和前台证明**

- [ ] **Step 6: Commit**

```powershell
git add entry/src/main/ets entry/src/ohosTest docs/qa
git commit -m "feat: add statistics and responsive layouts"
```

## Task 10: 完整回归、发布构建和文档回填

**Files:**
- Modify: `README.md`
- Modify: `tasks.md`
- Modify: `changes.md`
- Modify: `design.md`
- Modify: `design-qa.md`
- Create: `docs/qa/2026-07-29-build.md`
- Create: `docs/qa/2026-07-29-interaction.md`
- Create: `docs/ui/asset-manifest.md`

- [ ] **Step 1: 运行禁止能力扫描**

Run: `rg -n "INTERNET|HTTP|WebView|广告|支付|登录|云同步|any" AppScope entry/src/main`

Expected: no network permission, SDK, or ArkTS `any` usage; Chinese product copy matches are reviewed rather than treated as code violations.

- [ ] **Step 2: 运行完整 Hypium 测试**

Run: build/install main and test HAP, then `hdc shell aa test -b com.max.muyu -m entry_test -s unittest OpenHarmonyTestRunner`

Expected: `Failure: 0`, `Error: 0`, `TestFinished-ResultCode: 0`.

- [ ] **Step 3: 运行标准门禁、debug 和 release 构建**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode release
```

Expected: all commands exit 0 and print non-empty HAP artifact paths.

- [ ] **Step 4: 执行设备交互回归**

验证首次启动、重启、100 次快速敲击、模式切换、自定义文字、深浅色、目标、限时、自动后台停止、最近 7 天和二次确认清除。每项记录操作前状态、动作、操作后状态和截图。

- [ ] **Step 5: 回填真实证据并关闭任务**

Only mark `done` when implementation, tests, builds and available device QA are complete. Unavailable tablet or 2in1 targets remain `blocked` with exact recovery requirements.

- [ ] **Step 6: Commit**

```powershell
git add README.md tasks.md changes.md design.md design-qa.md docs/qa docs/ui
git commit -m "docs: record HarmonyOS V1 verification"
```
