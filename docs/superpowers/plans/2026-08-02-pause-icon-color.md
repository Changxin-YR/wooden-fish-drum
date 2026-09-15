# Pause Icon Color Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the blue system pause Emoji with a theme-aware warm wood ArkUI pause mark.

**Architecture:** Keep the change inside `HomePage`. Add a small builder for the pause mark, compose it with the label in the existing button, and protect the presentation with a focused source-level regression check.

**Tech Stack:** HarmonyOS ArkTS, ArkUI, PowerShell static checks, Hvigor/Hypium

---

### Task 1: Add the visual regression guard

**Files:**
- Create: `scripts/check-pause-icon.ps1`

- [x] **Step 1: Write the failing check**

Read `HomePage.ets`, fail when the source still contains `⏸`, and require a `PauseIcon` builder that uses `DesignTokens.wood` and `DesignTokens.accentDark`.

- [x] **Step 2: Run the check and verify failure**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-pause-icon.ps1`

Expected: FAIL because `HomePage.ets` still contains the system pause Emoji.

### Task 2: Replace the Emoji with an ArkUI mark

**Files:**
- Modify: `entry/src/main/ets/pages/HomePage.ets`

- [x] **Step 1: Add the minimal builder**

Add `PauseIcon()` containing two fixed-size rounded bars whose color resolves to `DesignTokens.wood` in light mode and `DesignTokens.accentDark` in dark mode.

- [x] **Step 2: Compose the running-state button**

Use a builder-form `Button` with a `Row` containing `PauseIcon()` and `Text('暂停')`. Preserve the existing resume label, click handler, dimensions, and accessibility text.

- [x] **Step 3: Run the focused check**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-pause-icon.ps1`

Expected: PASS.

### Task 3: Record and verify the change

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`

- [x] **Step 1: Record task status and result**

Add a task entry and change log entry covering the Emoji root cause, chosen colors, and unchanged interaction behavior.

- [x] **Step 2: Run project verification**

Run the standard check, debug build, debug ohosTest build, release build, and available phone verification commands documented by the project. Record any unavailable device class as `blocked` rather than claiming it passed.
