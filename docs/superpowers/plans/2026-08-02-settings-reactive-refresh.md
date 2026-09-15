# 设置实时响应式刷新 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让设置页所有可变项在操作后立即刷新 UI，并在后台可靠持久化最新值。

**Architecture:** `AppStore.settings` 保留业务层可变对象，`AppStore.settingsSnapshot()` 生成独立的 ArkUI 渲染快照。`Index` 对每个设置回调统一执行“修改内存设置、立即替换 `@State settings`、异步持久化”，`SettingsPage` 只保留音量拖动与文字编辑所需的短期局部状态。

**Tech Stack:** HarmonyOS Stage、ArkTS、ArkUI、Preferences、Hypium、Hvigor 6.24.3、HDC。

---

## 文件结构

- `entry/src/main/ets/stores/AppStore.ets`：提供独立设置快照，保持业务状态与渲染状态边界明确。
- `entry/src/main/ets/pages/Index.ets`：统一设置变更、响应式快照替换和异步保存错误处理。
- `entry/src/main/ets/pages/SettingsPage.ets`：处理音量拖动和自定义文字草稿，并由最新 `@Prop settings` 驱动其余控件。
- `entry/src/ohosTest/ets/test/DataAndSession.test.ets`：覆盖快照独立性、连续写入最新值和设置业务状态即时改变。
- `tasks.md`、`changes.md`：记录任务状态和最终验证结果。
- `docs/qa/2026-08-02-settings-reactive-refresh.md`：记录构建、Hypium 和 phone 交互证据。

### Task 1: 建立可测试的设置快照边界

**Files:**
- Modify: `entry/src/ohosTest/ets/test/DataAndSession.test.ets`
- Modify: `entry/src/main/ets/stores/AppStore.ets`

- [ ] **Step 1: 写入失败测试**

在 `DataAndSession` 测试组中新增：

```typescript
it('createsIndependentSettingsSnapshotsForImmediateUiRefresh', 0, async (): Promise<void> => {
  const memory: MemoryStore = new MemoryStore();
  const store: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
  await store.initialize();

  const before: AppSettings = store.settingsSnapshot();
  store.settings.volume = 0.35;
  store.settings.currentText = '平安喜乐';
  const after: AppSettings = store.settingsSnapshot();

  expect(before === after).assertFalse();
  expect(before.volume).assertEqual(0.7);
  expect(before.currentText).assertEqual('功德+1');
  expect(after.volume).assertEqual(0.35);
  expect(after.currentText).assertEqual('平安喜乐');
});
```

- [ ] **Step 2: 构建 ohosTest 并确认 RED**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
```

Expected: 构建失败，错误明确指出 `AppStore` 不存在 `settingsSnapshot`；不得是测试导入、ArkTS 语法或环境错误。

- [ ] **Step 3: 实现最小快照 API**

在 `AppStore` 中增加：

```typescript
settingsSnapshot(): AppSettings {
  return JsonCodec.decodeSettings(JsonCodec.encodeSettings(this.settings));
}
```

不得返回 `this.settings` 本身，也不得引入 `any`。

- [ ] **Step 4: 重新构建并运行 Hypium 验证 GREEN**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
hdc -t 127.0.0.1:5555 install -r .\entry\build\default\outputs\default\entry-default-unsigned.hap
hdc -t 127.0.0.1:5555 install -r .\entry\build\default\outputs\ohosTest\entry-ohosTest-unsigned.hap
hdc -t 127.0.0.1:5555 shell aa test -b com.max.muyu -m entry_test -s unittest OpenHarmonyTestRunner
```

Expected: 新用例通过，Hypium 汇总 `Failure 0`、`Error 0`、`OHOS_REPORT_CODE: 0`。

### Task 2: 统一全部设置项的即时刷新顺序

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`

- [ ] **Step 1: 让父页面只从独立快照刷新**

将 `Index.syncSettingsFromStore()` 改为：

```typescript
private syncSettingsFromStore(): void {
  this.settings = appStore.settingsSnapshot();
  this.homeTextCount = appStore.currentTextCount();
}
```

- [ ] **Step 2: 提取非阻塞保存结果处理**

在 `Index` 中增加：

```typescript
private persistSettings(operation: Promise<boolean>): void {
  operation.then((saved: boolean): void => {
    if (!saved) {
      this.storageError = true;
    }
  });
}
```

该方法只处理持久化结果，不再次覆盖当前响应式快照。

- [ ] **Step 3: 修正开关、音色和主题回调顺序**

`updateSetting` 在修改 `appStore.settings` 后立即调用 `syncSettingsFromStore()`，再把 `appStore.persistSettings()` 交给 `persistSettings()`；不得先 `await` 保存。

音色回调使用以下顺序：

```typescript
appStore.settings.soundType = type;
this.syncSettingsFromStore();
audioService.play(type, appStore.settings.volume);
this.persistSettings(appStore.persistSettings());
```

主题回调先调用会同步修改内存状态的 `appStore.setThemeMode(mode)`，立即刷新快照，再异步处理返回的保存结果：

```typescript
const operation: Promise<boolean> = appStore.setThemeMode(mode);
this.syncSettingsFromStore();
this.persistSettings(operation);
```

- [ ] **Step 4: 修正音量和自定义文字回调顺序**

音量每次变化都先更新内存设置和父页面快照，只在 `SliderChangeMode.End` 或 `SliderChangeMode.Click` 时保存：

```typescript
appStore.settings.volume = value;
this.syncSettingsFromStore();
if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
  this.persistSettings(appStore.persistSettings());
}
```

自定义文字先取得 `saveCustomText()` 返回的 Promise；由于 `saveCustomText` 在首次异步等待前已完成校验和内存修改，可立即刷新快照：

```typescript
const operation: Promise<boolean> = appStore.saveCustomText(value);
this.syncSettingsFromStore();
this.persistSettings(operation);
```

- [ ] **Step 5: 保持设置页局部状态与父快照同步**

`SettingsPage` 保留：

```typescript
@Prop @Watch('onSettingsChanged') settings: AppSettings;
@State customText: string = '';
@State volumeValue: number = 0.7;

private syncVisibleSettings(): void {
  if (!this.showTextEditor) {
    this.customText = this.settings.currentText;
  }
  this.volumeValue = this.settings.volume;
}
```

滑块 `onChange` 必须先赋值 `this.volumeValue = value` 再调用父回调；文字保存必须先将规范化结果赋给 `this.customText` 再关闭编辑器和调用父回调。其余开关、音色和主题直接读取 `this.settings`，不新增重复局部状态。

- [ ] **Step 6: 构建 ArkTS 并修复类型问题**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
```

Expected: 退出码 0，无 ArkTS `any`、Promise/void 或装饰器错误。

### Task 3: 回归测试持久化与所有设置项

**Files:**
- Modify: `entry/src/ohosTest/ets/test/DataAndSession.test.ets`

- [ ] **Step 1: 补充业务状态即时变化测试**

在已有测试中新增：

```typescript
it('updatesRuntimeSettingsBeforePersistenceCompletes', 0, async (): Promise<void> => {
  const memory: ReorderedWriteStore = new ReorderedWriteStore();
  const store: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
  await store.initialize();

  const themeSave: Promise<boolean> = store.setThemeMode(ThemeMode.DARK);
  expect(store.settings.themeMode).assertEqual(ThemeMode.DARK);
  expect(store.settingsSnapshot().themeMode).assertEqual(ThemeMode.DARK);
  await themeSave;

  const textSave: Promise<boolean> = store.saveCustomText('诸事顺意');
  expect(store.settings.currentText).assertEqual('诸事顺意');
  expect(store.settingsSnapshot().currentText).assertEqual('诸事顺意');
  await textSave;
});
```

- [ ] **Step 2: 运行完整 Hypium**

重新构建并安装 debug 主 HAP 与 ohosTest HAP，运行：

```powershell
hdc -t 127.0.0.1:5555 shell aa test -b com.max.muyu -m entry_test -s unittest OpenHarmonyTestRunner
```

Expected: 全部测试通过，`Failure 0`、`Error 0`、`OHOS_REPORT_CODE: 0`。

### Task 4: phone 交互验收与项目收尾

**Files:**
- Create: `docs/qa/2026-08-02-settings-reactive-refresh.md`
- Modify: `tasks.md`
- Modify: `changes.md`

- [ ] **Step 1: 在 phone 逐项验证即时刷新**

安装最新 debug HAP 并启动应用。逐项操作并在离开设置页前确认：

- 音效、振动、浮动文字开关立即改变选中状态。
- 音色选择关闭面板后，摘要立即更新并使用新音色试听。
- 音量从 100% 拖至约 50% 时，滑块与百分比同步变化。
- 主题选择后当前页面立即切换完整主题。
- 自定义文字保存后，设置行摘要立即更新；切回首页后右上角和浮动文字使用新内容。

- [ ] **Step 2: 执行最终自动验证**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode release
git diff --check
```

Expected: 所有命令退出码为 0，debug/release 主 HAP 和 debug ohosTest HAP 均存在且非空。

- [ ] **Step 3: 记录证据并更新任务状态**

在 QA 文件中记录模拟器地址、构建产物大小、Hypium 汇总、六类设置项的交互结果和截图路径。`tasks.md` 新任务状态依次使用 `in_progress`、`done` 或 `blocked`；`changes.md` 记录根因、改动、验证和遗留设备风险。无 tablet 或 2in1 目标时必须写 `blocked`，不得写成通过。

- [ ] **Step 4: 审查改动边界**

Run:

```powershell
git status --short
git diff -- entry/src/main/ets/stores/AppStore.ets entry/src/main/ets/pages/Index.ets entry/src/main/ets/pages/SettingsPage.ets entry/src/ohosTest/ets/test/DataAndSession.test.ets tasks.md changes.md docs/qa/2026-08-02-settings-reactive-refresh.md
```

Expected: 未修改 `com.max.muyu`、版本发布状态或签名身份；未新增网络、广告、登录、支付或云同步能力。当前工作区已有的其他改动保持不回退、不覆盖。

> 当前工作区在计划开始前已包含同文件的未提交修改，因此执行阶段不自动创建代码提交，除非用户明确要求；这避免把既有改动错误归入本任务提交。
