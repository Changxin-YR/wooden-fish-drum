# 浮动提示冒泡堆叠 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将首页敲击提示改为最多三条、最新在下、旧提示向上堆叠并逐级淡化的冒泡布局，避免快速点击时遮挡木鱼。

**Architecture:** 保留 `WoodenFishView` 现有提示数组、唯一键和 760ms 定时清理，只增加根据数组索引计算层级、偏移和透明度的纯方法。渲染层由向下扩展的 `Column` 改为固定在组件顶部中心的 `Stack`，所有提示共享锚点并按新旧层级向上偏移，不改变组件尺寸和点击数据流。

**Tech Stack:** HarmonyOS Stage、ArkTS、ArkUI、PowerShell、Hvigor、Hypium、HDC

---

## 文件结构

- Create: `scripts/check-floating-bubbles.ps1`：锁定冒泡堆叠的源码契约和现有限制。
- Modify: `entry/src/main/ets/components/WoodenFishView.ets`：计算提示层级并渲染向上堆叠布局。
- Create: `docs/qa/2026-08-02-floating-bubbles.md`：记录构建、测试和 phone 快速连击验收结果。
- Create: `docs/qa/screenshots/2026-08-02-floating-bubbles.jpeg`：保存最多三条向上堆叠的运行截图。

### Task 1: 建立冒泡布局回归约束

**Files:**
- Create: `scripts/check-floating-bubbles.ps1`
- Test: `scripts/check-floating-bubbles.ps1`

- [ ] **Step 1: 写入当前会失败的静态回归脚本**

```powershell
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$componentPath = Join-Path $projectRoot 'entry\src\main\ets\components\WoodenFishView.ets'
$source = Get-Content -Raw -Encoding UTF8 -LiteralPath $componentPath

$requiredFragments = @(
  'private floatingTextDistanceFromNewest(index: number): number {',
  'private floatingTextOffsetY(index: number): number {',
  'return -48 * this.floatingTextDistanceFromNewest(index);',
  'private floatingTextOpacity(index: number): number {',
  'return 0.76;',
  'return 0.52;',
  'ForEach(this.floatingTexts, (item: string, index: number) => {',
  '.opacity(this.floatingTextOpacity(index))',
  '.translate({ y: this.floatingTextOffsetY(index) })',
  '.height(44)',
  '.position({ x: 0, y: 8 })'
)

foreach ($fragment in $requiredFragments) {
  if (-not $source.Contains($fragment)) {
    throw "Floating bubble layout check failed: missing '$fragment'."
  }
}

$threeItemLimits = ([regex]::Matches($source, [regex]::Escape('next.length - 3'))).Count
$cleanupTimers = ([regex]::Matches($source, [regex]::Escape('}, 760);'))).Count
if ($threeItemLimits -ne 2) {
  throw "Floating bubble layout check failed: expected two three-item limits, found $threeItemLimits."
}
if ($cleanupTimers -ne 2) {
  throw "Floating bubble layout check failed: expected two 760ms cleanup timers, found $cleanupTimers."
}

Write-Host 'Floating bubble layout check passed.' -ForegroundColor Green
```

- [ ] **Step 2: 运行脚本确认旧实现失败**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-floating-bubbles.ps1
```

Expected: 退出码非 0，首先报告缺少 `floatingTextDistanceFromNewest`；此时组件仍使用普通 `Column({ space: 8 })` 向下排列。

### Task 2: 实现向上冒泡堆叠

**Files:**
- Modify: `entry/src/main/ets/components/WoodenFishView.ets:20`
- Modify: `entry/src/main/ets/components/WoodenFishView.ets:111`
- Test: `scripts/check-floating-bubbles.ps1`

- [ ] **Step 1: 增加层级、偏移和透明度计算**

在 `onHitSequenceChanged()` 之前加入：

```typescript
private floatingTextDistanceFromNewest(index: number): number {
  return this.floatingTexts.length - 1 - index;
}

private floatingTextOffsetY(index: number): number {
  return -48 * this.floatingTextDistanceFromNewest(index);
}

private floatingTextOpacity(index: number): number {
  const distance: number = this.floatingTextDistanceFromNewest(index);
  if (distance <= 0) {
    return 1;
  }
  if (distance === 1) {
    return 0.76;
  }
  return 0.52;
}
```

- [ ] **Step 2: 将向下扩展的 Column 改为固定锚点 Stack**

用以下代码替换当前浮动提示 `Column`：

```typescript
Stack({ alignContent: Alignment.Top }) {
  ForEach(this.floatingTexts, (item: string, index: number) => {
    Text(item.substring(item.indexOf(':') + 1))
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.dark ? '#F1D0AD' : '#8A5635')
      .padding({ left: 18, right: 18, top: 10, bottom: 10 })
      .backgroundColor(this.dark ? '#CC2A2724' : '#EFFFFDF8')
      .borderRadius(22)
      .opacity(this.floatingTextOpacity(index))
      .translate({ y: this.floatingTextOffsetY(index) })
  }, (item: string): string => item)
}
.width('100%')
.height(44)
.position({ x: 0, y: 8 })
```

不得修改 `floatingTexts` 的追加、最后三条裁剪、760ms 清理、提示文案和唯一键逻辑。

- [ ] **Step 3: 运行冒泡和木锤布局回归脚本**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-floating-bubbles.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-mallet-layout.ps1
```

Expected: 两个脚本均退出码 0，分别输出 `Floating bubble layout check passed.` 和 `Mallet layout check passed.`。

- [ ] **Step 4: 运行标准检查、debug 构建和差异检查**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
git diff --check
```

Expected: 标准检查和 debug 构建退出码 0，生成非空 debug HAP；`git diff --check` 无新增空白错误。ArkTS 编译若不接受 `ForEach` 索引签名或属性组合，先根据编译错误修正类型或链式调用，再重新执行本步骤，不改变设计参数。

- [ ] **Step 5: 审查任务差异**

Run:

```powershell
git diff -- scripts/check-floating-bubbles.ps1 entry/src/main/ets/components/WoodenFishView.ets
```

Expected: 新脚本只检查冒泡契约；组件只新增三个纯计算方法并替换提示渲染层。木锤 `x: '53%'`、`y: 45`、静止和复位 `-4` 度及击打动画参数保持不变。组件已有未提交修改，因此不自动提交该文件，避免混入既有用户改动。

### Task 3: 完成构建、Hypium 和 phone 验收

**Files:**
- Create: `docs/qa/2026-08-02-floating-bubbles.md`
- Create: `docs/qa/screenshots/2026-08-02-floating-bubbles.jpeg`

- [ ] **Step 1: 构建 ohosTest 和 release 产物**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode release
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
```

Expected: 三个构建退出码均为 0，最后重新生成 debug 主 HAP，避免安装 release 同名产物。

- [ ] **Step 2: 安装 HAP 并运行 Hypium**

Run:

```powershell
hdc -t 127.0.0.1:5555 install -r .\entry\build\default\outputs\default\entry-default-unsigned.hap
hdc -t 127.0.0.1:5555 install -r .\entry\build\default\outputs\ohosTest\entry-ohosTest-unsigned.hap
hdc -t 127.0.0.1:5555 shell aa test -b com.max.muyu -m entry_test -s unittest OpenHarmonyTestRunner
```

Expected: 两次安装成功；Hypium 为 Tests run 16，Pass 16，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`。

- [ ] **Step 3: 启动应用并采集快速连击截图**

Run:

```powershell
hdc -t 127.0.0.1:5555 shell aa force-stop com.max.muyu
hdc -t 127.0.0.1:5555 shell aa start -a EntryAbility -b com.max.muyu
hdc -t 127.0.0.1:5555 shell "uitest uiInput doubleClick 660 1100 && uitest uiInput click 660 1100 && snapshot_display -f /data/local/tmp/2026-08-02-floating-bubbles.jpeg"
hdc -t 127.0.0.1:5555 file recv /data/local/tmp/2026-08-02-floating-bubbles.jpeg .\docs\qa\screenshots\2026-08-02-floating-bubbles.jpeg
```

Expected: 截图非空，包含最多三条提示；最新提示在 `y: 8vp` 锚点，旧提示以 48vp 间距向上排列并逐级淡化，木鱼主体和右上角计数均无遮挡。若组合 shell 命令不被设备接受，分别执行一次 `doubleClick` 和一次 `click`，在第三次输入后立即运行 `snapshot_display`。

- [ ] **Step 4: 验证生命周期和连续输入**

等待 900ms 后重新执行 `uitest dumpLayout -b com.max.muyu` 并采集复位截图。

Expected: 三条提示均已清除，木鱼、木锤和页面其他组件的 bounds 与点击前一致；会话计数增加。重复五次快速输入期间同时可见提示不超过三条。

- [ ] **Step 5: 写入 QA 记录并执行最终门禁**

在 `docs/qa/2026-08-02-floating-bubbles.md` 记录冒泡脚本、标准检查、三个构建、Hypium、截图路径、三条堆叠顺序、透明度、无遮挡和 760ms 清理结果；tablet、2in1 无目标时标记 `blocked`。

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-floating-bubbles.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-mallet-layout.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
git diff --check
git status --short
```

Expected: 三个检查脚本均退出码 0，无新增空白错误；状态中只增加本任务文件并保留此前工作区改动。未经用户明确要求，不提交包含既有工作区改动的业务源码。
