# System Bars Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the status bar and system navigation bar visually continuous with every app screen without placing app content inside either system bar.

**Architecture:** A pure resolver maps the current tab and resolved dark state to typed system-bar properties. A window service owns the HarmonyOS `Window` API, while `EntryAbility` binds the main window and `Index` requests style synchronization when reactive UI state is rendered.

**Tech Stack:** HarmonyOS Stage model, ArkTS, ArkUI, `@kit.ArkUI` window API, Hypium, PowerShell build scripts.

---

### Task 1: Test and implement system-bar style resolution

**Files:**
- Create: `entry/src/main/ets/models/SystemBarModels.ets`
- Create: `entry/src/main/ets/utils/SystemBarStyleResolver.ets`
- Create: `entry/src/ohosTest/ets/test/SystemBarStyle.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: Write the failing test**

Add tests asserting that light home resolves to status `DesignTokens.homeLightBackground`, light non-home resolves to `DesignTokens.lightBackground`, both use `DesignTokens.lightCard` for navigation, and dark mode uses `DesignTokens.darkBackground`/`darkCard` with light icons.

- [ ] **Step 2: Run the test build to verify it fails**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest`
Expected: FAIL because `SystemBarStyleResolver` does not exist.

- [ ] **Step 3: Write minimal implementation**

Create `SystemBarStyle` with `statusBarColor`, `navigationBarColor`, `statusBarContentColor`, `navigationBarContentColor`, `isStatusBarLightIcon`, and `isNavigationBarLightIcon`. Implement `SystemBarStyleResolver.resolve(tab: AppTab, dark: boolean)` using the approved token mapping and `#FFFFFF`/`#000000` content colors.

- [ ] **Step 4: Run the test build to verify it passes**

Run the same ohosTest build command. Expected: PASS and a non-empty ohosTest HAP.

### Task 2: Apply styles through the main window

**Files:**
- Create: `entry/src/main/ets/services/WindowChromeService.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: Add the service**

Store a typed `window.Window`, call `setWindowLayoutFullScreen(false)` during bind, and apply the resolved values through `setWindowSystemBarProperties`. Cache the last style key to avoid duplicate window writes; catch API failures without blocking the UI.

- [ ] **Step 2: Bind before loading content**

In `EntryAbility.onWindowStageCreate`, obtain `windowStage.getMainWindow()`, bind the service using the system theme and home tab, then load `pages/Index`; retain a load fallback when window setup fails.

- [ ] **Step 3: Synchronize reactive state**

In `Index.onDidBuild`, call `windowChromeService.update(this.selectedTab, this.isDark())`. This covers initialization, tab changes, explicit theme changes, and `@StorageLink('systemDark')` updates without putting window API calls in child pages.

- [ ] **Step 4: Run static and build verification**

Run `scripts/check-standard.ps1`, debug main HAP, debug ohosTest HAP, and release main HAP. Expected: every command exits 0.

### Task 3: Runtime verification and records

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`
- Create: `docs/qa/2026-08-03-system-bars.md`

- [ ] **Step 1: Run Hypium on the available phone**

Install the latest debug main and ohosTest HAPs, run `OpenHarmonyTestRunner`, and confirm zero failures/errors.

- [ ] **Step 2: Verify screens on the available phone**

Capture home, stats, settings, privacy, light and dark states. Confirm no white system-bar seam and no content overlap with system indicators.

- [ ] **Step 3: Record evidence**

Add task status using only `in_progress`, `done`, or `blocked`; document exact command and device outcomes in `changes.md` and the QA record. Keep unavailable tablet/2in1 runtime validation `blocked`.
