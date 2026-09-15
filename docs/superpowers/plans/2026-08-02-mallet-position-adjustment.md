# 木锤位置调整 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将首页木锤调整到已确认的 B 方案位置，并保证每次击打后稳定恢复到相同的静止姿态。

**Architecture:** 保持 `WoodenFishView` 的现有结构和动画节奏，只修改木锤的初始角度、动画复位角度和 Stack 内绝对位置。新增一个独立 PowerShell 静态回归脚本锁定这三个 ArkUI 参数，再通过完整构建、Hypium 和 phone 模拟器截图验证运行效果。

**Tech Stack:** HarmonyOS Stage、ArkTS、ArkUI、PowerShell、Hvigor、Hypium、HDC

---

## 文件结构

- Create: `scripts/check-mallet-layout.ps1`：检查 B 方案的三个稳定源码契约。
- Modify: `entry/src/main/ets/components/WoodenFishView.ets`：设置木锤初始姿态、动画复位姿态和纵向位置。
- Create: `docs/qa/2026-08-02-mallet-position.md`：记录构建、Hypium、设备截图和动画验收结果。
- Create: `docs/qa/screenshots/2026-08-02-mallet-position-b.jpeg`：保存 phone 模拟器静止状态证据。

### Task 1: 建立木锤布局回归约束

**Files:**
- Create: `scripts/check-mallet-layout.ps1`
- Test: `scripts/check-mallet-layout.ps1`

- [ ] **Step 1: 写入当前会失败的静态回归脚本**

```powershell
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$componentPath = Join-Path $projectRoot 'entry\src\main\ets\components\WoodenFishView.ets'
$source = Get-Content -Raw -Encoding UTF8 -LiteralPath $componentPath

$expectedInitialAngle = '@State malletAngle: number = -4;'
$expectedRestingPosition = ".position({ x: '53%', y: 45 })"
$expectedResetAngle = 'this.malletAngle = -4;'

if (-not $source.Contains($expectedInitialAngle)) {
  throw "WoodenFishView must initialize the mallet angle to -4 degrees."
}
if (-not $source.Contains($expectedRestingPosition)) {
  throw "WoodenFishView must position the mallet at x 53% and y 45."
}
$resetCount = ([regex]::Matches($source, [regex]::Escape($expectedResetAngle))).Count
if ($resetCount -ne 1) {
  throw "WoodenFishView must reset the mallet to -4 degrees exactly once."
}

Write-Host 'Mallet layout check passed.' -ForegroundColor Green
```

- [ ] **Step 2: 运行脚本确认旧实现失败**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-mallet-layout.ps1
```

Expected: 退出码非 0，首先报告初始角度不是 `-4` 度；此时 `WoodenFishView.ets` 仍为 `-12` 度和 `y: 145`。

### Task 2: 实现 B 方案并通过自动检查

**Files:**
- Modify: `entry/src/main/ets/components/WoodenFishView.ets:12`
- Modify: `entry/src/main/ets/components/WoodenFishView.ets:55`
- Modify: `entry/src/main/ets/components/WoodenFishView.ets:109`
- Test: `scripts/check-mallet-layout.ps1`

- [ ] **Step 1: 修改初始角度和动画复位角度**

```typescript
@State malletAngle: number = -4;
```

在 `playHitAnimation()` 最后一个 `animateTo` 回调中使用：

```typescript
this.malletAngle = -4;
```

保留击打阶段的 `-38` 度、回弹阶段的 `-6` 度以及所有时长、位移、缩放和透明度参数。

- [ ] **Step 2: 修改木锤静止位置**

```typescript
.position({ x: '53%', y: 45 })
```

- [ ] **Step 3: 运行布局回归脚本**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-mallet-layout.ps1
```

Expected: `Mallet layout check passed.`，退出码 0。

- [ ] **Step 4: 运行项目静态检查和 debug 构建**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
git diff --check
```

Expected: 标准检查和 debug 构建退出码均为 0，debug HAP 存在且非空，`git diff --check` 无输出。若仓库原有未提交文件产生既有告警，区分并记录，不修改与本任务无关的文件。

- [ ] **Step 5: 审查本任务差异**

Run:

```powershell
git diff -- scripts/check-mallet-layout.ps1 entry/src/main/ets/components/WoodenFishView.ets
```

Expected: 新脚本仅含三个布局契约；组件相对实施前只新增 `-12` 到 `-4` 的两处变化和 `y: 145` 到 `y: 45` 的一处变化。由于组件已有未提交修改，不自动提交该文件，避免把现有用户改动混入新提交。

### Task 3: 完成构建、Hypium 和设备验收

**Files:**
- Create: `docs/qa/2026-08-02-mallet-position.md`
- Create: `docs/qa/screenshots/2026-08-02-mallet-position-b.jpeg`

- [ ] **Step 1: 构建 ohosTest 和 release 产物**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode release
```

Expected: 两个命令退出码均为 0，`entry/build/default/outputs/ohosTest/entry-ohosTest-unsigned.hap` 和 release 主 HAP 均存在且非空。

- [ ] **Step 2: 重新生成 debug 主 HAP 并安装测试产物**

release 构建会复用主 HAP 输出名，因此先重新构建 debug，再安装主 HAP 和测试 HAP：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
hdc -t 127.0.0.1:5555 install -r .\entry\build\default\outputs\default\entry-default-unsigned.hap
hdc -t 127.0.0.1:5555 install -r .\entry\build\default\outputs\ohosTest\entry-ohosTest-unsigned.hap
```

Expected: debug 构建成功，两次安装均返回成功。

- [ ] **Step 3: 运行设备 Hypium**

Run:

```powershell
hdc -t 127.0.0.1:5555 shell aa test -b com.max.muyu -m entry_test -s unittest OpenHarmonyTestRunner
```

Expected: Tests run 16，Pass 16，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`。

- [ ] **Step 4: 启动应用并采集静止截图**

Run:

```powershell
hdc -t 127.0.0.1:5555 shell aa start -a EntryAbility -b com.max.muyu
hdc -t 127.0.0.1:5555 shell snapshot_display -f /data/local/tmp/2026-08-02-mallet-position-b.jpeg
hdc -t 127.0.0.1:5555 file recv /data/local/tmp/2026-08-02-mallet-position-b.jpeg .\docs\qa\screenshots\2026-08-02-mallet-position-b.jpeg
```

Expected: 应用启动成功并生成非空截图。截图中木锤位于 B 方案位置、处于木鱼上方，不遮挡标题且没有不合理重叠。

- [ ] **Step 5: 验证击打与复位**

在 phone 模拟器上点击木鱼中心，观察完整击打和回弹；连续点击三次后停止操作。

Expected: 每次都有明确击打动作，结束后木锤回到截图中的 `y: 45`、`-4` 度静止姿态，不漂移，也不跳回旧角度。若动画因新的基准位置无法形成合理击打，仅微调 `malletOffsetY` 或击打阶段角度，然后重新执行 Task 2 Step 3 至 Task 3 Step 5。

- [ ] **Step 6: 写入 QA 证据**

在 `docs/qa/2026-08-02-mallet-position.md` 记录：三个构建结果及 HAP 大小、Hypium 汇总、模拟器目标、截图路径、静止位置结果、单次及连续击打复位结果。tablet 和 2in1 无可用目标时明确写为 `blocked`，不得写成通过。

- [ ] **Step 7: 最终差异检查**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-mallet-layout.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
git diff --check
git status --short
```

Expected: 两个检查脚本退出码 0；无新增空白错误；状态中只出现本任务文件和此前已存在的用户改动。未经用户明确要求，不提交包含既有工作区改动的业务源码。
