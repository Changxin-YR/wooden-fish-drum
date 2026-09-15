# Realistic Mallet Motion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the geometric mallet with the approved wooden drop-head mallet and make it strike the top of the wooden fish with a weighted four-stage arc.

**Architecture:** Keep hit orchestration inside `WoodenFishView`, replace only the mallet builder with a transparent media image, and drive all motion from absolute keyframe state. Extend the existing PowerShell layout gate before implementation, then verify the visual resource, ArkTS source, builds, and available devices.

**Tech Stack:** HarmonyOS ArkTS/ArkUI, PNG media resources, PowerShell static gates, Hvigor, Hypium.

---

### Task 1: Lock the resource and motion contract

**Files:**
- Modify: `scripts/check-mallet-layout.ps1`

- [ ] **Step 1: Write the failing checks**

Require `$r('app.media.muyu_mallet')`, a `190 x 66` image, `centerX: '90%'`, the four animation durations `110/55/125/170`, contact angle/offset targets, and contact-shadow state.

- [ ] **Step 2: Run the gate and verify RED**

Run: `powershell -ExecutionPolicy Bypass -File scripts/check-mallet-layout.ps1`

Expected: FAIL because `WoodenFishView.ets` still contains the geometric `Row` mallet and three-stage animation.

### Task 2: Create the transparent mallet resource

**Files:**
- Create: `entry/src/main/resources/base/media/muyu_mallet.png`

- [ ] **Step 1: Extract the approved mallet**

Crop the upper mallet from the supplied reference, remove its light background with foreground segmentation, trim transparent margins, and resize onto a compact transparent horizontal canvas while preserving the drop-shaped head, narrow neck, double rings, wood grain, and rounded handle.

- [ ] **Step 2: Validate the asset**

Inspect dimensions and alpha extrema. Expected: PNG in RGBA mode, transparent corner pixels, opaque wooden core, no light rectangular backdrop.

### Task 3: Implement the four-stage strike

**Files:**
- Modify: `entry/src/main/ets/components/WoodenFishView.ets`

- [ ] **Step 1: Replace geometric drawing with the image**

Render `Image($r('app.media.muyu_mallet'))` at stable dimensions with `ImageFit.Contain`, adaptive shadow, and rotation around the right-hand 90% anchor.

- [ ] **Step 2: Implement absolute keyframes**

Use a 110ms accelerated drop, 55ms contact hold, 125ms rebound, and 170ms reset. At contact, align the left mallet head with the fish crown, compress the fish slightly, strengthen the contact shadow, and start the wave. Reset every animated property to its fixed initial value.

- [ ] **Step 3: Run the focused gate and verify GREEN**

Run: `powershell -ExecutionPolicy Bypass -File scripts/check-mallet-layout.ps1`

Expected: `Mallet layout check passed.`

### Task 4: Verify project and device behavior

**Files:**
- Modify if evidence changes: `tasks.md`, `changes.md`, `design-qa.md`
- Create if device capture succeeds: `docs/qa/2026-08-03-mallet-motion.md`

- [ ] **Step 1: Run source and static checks**

Run the repository standard check and all focused PowerShell gates. Expected: PASS with no ArkTS `any`, forbidden capability, or mallet-layout regression.

- [ ] **Step 2: Run tests and builds**

Run Hypium plus debug, release, and ohosTest builds using the repository commands documented in `README.md`. Expected: all commands exit 0.

- [ ] **Step 3: Validate available devices**

Capture idle, contact, and reset states on an available phone. Check connected tablet/2in1 targets and record them as verified or blocked based on actual availability.

- [ ] **Step 4: Review the final diff**

Confirm only the approved mallet resource, component motion, focused test gate, and evidence records changed; preserve all unrelated user edits.
