# Cold Startup Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the duplicate in-app startup icon and keep audio loading off the first-frame critical path.

**Architecture:** Keep the HarmonyOS `startWindowIcon` as the only branded startup surface. `Index` waits only for persisted application state, swaps to the normal page, and then starts the existing failure-tolerant audio initialization asynchronously.

**Tech Stack:** HarmonyOS Stage model, ArkTS/ArkUI, PowerShell static checks, Hypium

---

### Task 1: Add the startup regression check

**Files:**
- Create: `scripts/check-startup-flow.ps1`
- Modify: `scripts/check-standard.ps1`

- [x] Write a check that requires the system start-window settings, rejects in-app `app_icon` rendering, and rejects awaited audio initialization.
- [x] Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-startup-flow.ps1` and confirm it fails for the duplicate icon and blocking audio load.
- [x] Register the check in `scripts/check-standard.ps1`.

### Task 2: Minimize the ArkUI startup transition

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`

- [x] Replace the icon, progress indicator, and loading text with a full-size page background.
- [x] Move `audioService.initialize(hostContext)` after `ready=true` and remove `await`.
- [x] Re-run the startup regression check and confirm it passes.

### Task 3: Verify and document

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`
- Create: `docs/qa/2026-08-03-startup-flow.md`

- [x] Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1`.
- [x] Run debug, ohosTest, and release builds with `scripts/build-harmony.ps1`.
- [x] Install the debug HAP, execute Hypium, and cold-start the app on available phone and 2in1 devices.
- [x] Record exact results and mark task `done` only after all available checks pass.

### Task 4: Guard asynchronous audio lifecycle

**Files:**
- Create: `entry/src/main/ets/services/InitializationSlot.ets`
- Modify: `entry/src/main/ets/services/AudioService.ets`
- Modify: `entry/src/ohosTest/ets/test/CoreModels.test.ets`

- [x] Add a failing test for stale resource rejection, active resource publication, and cancellation.
- [x] Load audio into a local candidate resource bundle and publish only through the current generation.
- [x] Invalidate pending candidates on release and dispose every rejected or replaced pool.
- [x] Re-run debug, ohosTest, release, Hypium, and rapid background/re-entry verification.
