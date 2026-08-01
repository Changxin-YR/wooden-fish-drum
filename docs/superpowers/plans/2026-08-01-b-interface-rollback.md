# B Interface Rollback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore the user-approved B visual language while preserving every current behavior, persisted setting, API 22 constraint, and responsive device path.

**Architecture:** Keep controllers, repositories, services, and page callback contracts unchanged. Selectively restore visual tokens and ArkUI composition in shared components first, then update page composition so phone, tablet, and 2in1 consume the same state and callbacks.

**Tech Stack:** HarmonyOS Stage model, ArkTS, ArkUI, Preferences, AppStorage, Hypium, Hvigor API 22.

---

### Task 1: Lock the Functional Baseline

**Files:**
- Verify: `entry/src/main/ets/controllers/PracticeController.ets`
- Verify: `entry/src/main/ets/services/StatsPeriodService.ets`
- Verify: `entry/src/main/ets/repositories/`
- Verify: `entry/src/ohosTest/ets/test/`

- [ ] **Step 1: Record the current tracked-file baseline**

Run:

```powershell
git status --short
git diff --name-only 8c0742f..HEAD -- entry/src/main/ets
```

Expected: only the pre-existing untracked QA evidence is present before implementation; current functional changes are visible relative to `8c0742f`.

- [ ] **Step 2: Run the static baseline**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
```

Expected: exit code 0 and `Standard checks passed.`

### Task 2: Restore Shared B Visual Tokens and Components

**Files:**
- Modify: `entry/src/main/ets/constants/ThemePalette.ets`
- Modify: `entry/src/main/ets/components/BottomNavBar.ets`
- Modify: `entry/src/main/ets/components/PracticeControlDock.ets`
- Modify: `entry/src/main/ets/components/WoodenFishView.ets`

- [ ] **Step 1: Restore the B palette without changing its interface**

Keep `ThemeColors` fields and `ThemePalette.resolve(dark)` unchanged as public contracts. Replace only returned color values so dark mode uses the B baseline: near-black page, low-contrast charcoal cards, warm gold accent, subdued secondary text, and fine separators. Provide the structurally equivalent light palette.

- [ ] **Step 2: Restore compact shared component composition**

Keep all existing `@Prop`, `@Link`, and callback declarations. Apply B-style 8vp corners, compact spacing, fine borders, and lower visual weight to navigation and controls. Preserve 48vp minimum interaction targets and icon-plus-text-plus-marker selected state.

- [ ] **Step 3: Preserve the interactive wooden-fish behavior**

Keep the current separated fish body and upper-right mallet, `hitSequence`, `reducedMotion`, timing, hit callback, ripple, bounce, and feedback text. Adjust only canvas background, sizing, offsets, shadows, and typography to visually fit B; ensure no second baked-in mallet is rendered.

- [ ] **Step 4: Run static verification**

Run the standard check command from Task 1. Expected: exit code 0.

### Task 3: Restore B Page Composition

**Files:**
- Modify: `entry/src/main/ets/pages/HomePage.ets`
- Modify: `entry/src/main/ets/pages/StatsPage.ets`
- Modify: `entry/src/main/ets/pages/SettingsPage.ets`

- [ ] **Step 1: Recompose HomePage**

Restore B phone hierarchy and density around the existing builders. Keep the dynamic `今日${FeedbackText.label(...)}` title, all three practice modes, target picker presets/custom validation, target completion, restart action, automatic interval, tool switching, and Compact/Medium/Expanded branches.

- [ ] **Step 2: Recompose StatsPage**

Apply B cards, metrics, charts, session rows, and two-row period selector styling. Keep `@StorageLink('statsPeriod')`, all eight `StatsPeriod` values, `StatsPeriodService.build(...)`, empty state, and true session data unchanged.

- [ ] **Step 3: Recompose SettingsPage**

Apply B grouping, row density, separators, header, modal surfaces, and overlay styling. Keep controlled theme switching, minimum switch container dimensions, feedback-text validation/save state, immediate AppStorage refresh callback, audio controls, data clearing, and compliance navigation unchanged.

- [ ] **Step 4: Build debug and ohosTest artifacts**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
```

Expected: both commands exit 0 and produce HAP files under `entry/build/default/outputs/default/`.

### Task 4: Regression, Evidence, and Delivery

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`
- Create: `docs/qa/2026-08-01-b-interface-rollback.md`
- Create: `docs/qa/screenshots/muyu-b-rollback-*.jpeg` when a device is available

- [ ] **Step 1: Run API 22 device regression**

Install the debug and ohosTest HAPs on the connected API 22 device, then run Hypium. Expected: at least 54 tests, Failure 0, Error 0.

- [ ] **Step 2: Verify visual and interaction paths**

Check phone dark/light pages, 320vp overflow, target presets/custom target, target completion/restart, automatic mode, immediate feedback-text refresh, eight statistics periods, theme switching, modal overlays, restart persistence, system bars, and safe areas. Check Medium/Expanded on tablet/2in1 when those device profiles are available; otherwise record only those runtime checks as `blocked`.

- [ ] **Step 3: Run release build**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode release
```

Expected: exit code 0 and an unsigned release HAP, with bundle name, version, and signing identity unchanged.

- [ ] **Step 4: Update project records and commit**

Mark completed checks in `tasks.md`, summarize files and evidence in `changes.md` and the QA report, then stage only implementation-owned files and create a focused commit.
