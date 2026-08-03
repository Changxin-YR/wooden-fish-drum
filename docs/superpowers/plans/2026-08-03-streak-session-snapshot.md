# Streak And Session Snapshot Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve an active streak before today's first hit and centralize complete, independent `SessionState` snapshots.

**Architecture:** `StatsRepository` remains the sole owner of streak calculation and chooses today or yesterday as the starting date based on whether today has a positive record. `SessionState` owns its explicit copy operation, while `Index` only assigns the returned snapshot to ArkUI state.

**Tech Stack:** HarmonyOS API 24, ArkTS, ArkUI, Hypium, PowerShell build scripts

---

### Task 1: Add failing regression tests

**Files:**
- Modify: `entry/src/ohosTest/ets/test/DataAndSession.test.ets`

- [ ] **Step 1: Add streak tests**

Add three repository assertions: records on `2026-08-01` and `2026-08-02` produce streak 2 for `2026-08-03`; adding a record on `2026-08-03` produces streak 3; records ending on `2026-08-01` produce streak 0 for `2026-08-03`.

```typescript
it('preservesStreakBeforeTodaysFirstHit', 0, async (): Promise<void> => {
  const repository: StatsRepository = new StatsRepository(new MemoryStore());
  await repository.replace([
    new DailyRecord('2026-08-01', 1, 0),
    new DailyRecord('2026-08-02', 1, 0)
  ]);
  expect((await repository.summary('2026-08-03')).streakDays).assertEqual(2);
});

it('includesTodayAfterFirstHitAndStopsAtGaps', 0, async (): Promise<void> => {
  const active: StatsRepository = new StatsRepository(new MemoryStore());
  await active.replace([
    new DailyRecord('2026-08-01', 1, 0),
    new DailyRecord('2026-08-02', 1, 0),
    new DailyRecord('2026-08-03', 1, 0)
  ]);
  expect((await active.summary('2026-08-03')).streakDays).assertEqual(3);

  const broken: StatsRepository = new StatsRepository(new MemoryStore());
  await broken.replace([new DailyRecord('2026-08-01', 1, 0)]);
  expect((await broken.summary('2026-08-03')).streakDays).assertEqual(0);
});
```

- [ ] **Step 2: Add snapshot test**

```typescript
it('createsCompleteIndependentSessionSnapshots', 0, (): void => {
  const source: SessionState = new SessionState();
  source.mode = SessionMode.TARGET;
  source.hitSequence = 7;
  source.running = true;
  source.paused = true;
  source.targetCompleted = true;
  source.currentCount = 6;
  source.targetCount = 8;
  source.startedAt = 1234;

  const snapshot: SessionState = source.snapshot();
  source.currentCount = 99;

  expect(snapshot === source).assertFalse();
  expect(snapshot.mode).assertEqual(SessionMode.TARGET);
  expect(snapshot.hitSequence).assertEqual(7);
  expect(snapshot.running).assertTrue();
  expect(snapshot.paused).assertTrue();
  expect(snapshot.targetCompleted).assertTrue();
  expect(snapshot.currentCount).assertEqual(6);
  expect(snapshot.targetCount).assertEqual(8);
  expect(snapshot.startedAt).assertEqual(1234);
});
```

Also add `SessionState` to the existing `AppModels` import.

- [ ] **Step 3: Verify the tests fail before implementation**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
```

Expected: build fails because `SessionState.snapshot()` does not exist. If a device is available, temporarily run Hypium without the snapshot test to confirm `preservesStreakBeforeTodaysFirstHit` reports expected 2 but receives 0.

### Task 2: Implement the minimal fixes

**Files:**
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/repositories/StatsRepository.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: Add the model-owned snapshot**

Add to `SessionState`:

```typescript
snapshot(): SessionState {
  const copy: SessionState = new SessionState();
  copy.mode = this.mode;
  copy.hitSequence = this.hitSequence;
  copy.running = this.running;
  copy.paused = this.paused;
  copy.targetCompleted = this.targetCompleted;
  copy.currentCount = this.currentCount;
  copy.targetCount = this.targetCount;
  copy.startedAt = this.startedAt;
  return copy;
}
```

- [ ] **Step 2: Start an idle-day streak from yesterday**

Replace `StatsRepository.streak()` with:

```typescript
private streak(today: string): number {
  const todayRecord: DailyRecord | undefined =
    this.records.find((item: DailyRecord): boolean => item.date === today && item.totalCount > 0);
  const initialOffset: number = todayRecord === undefined ? 1 : 0;
  let days: number = 0;
  while (true) {
    const key: string = DateUtil.addDays(today, -(initialOffset + days));
    const record: DailyRecord | undefined =
      this.records.find((item: DailyRecord): boolean => item.date === key && item.totalCount > 0);
    if (record === undefined) {
      break;
    }
    days++;
  }
  return days;
}
```

- [ ] **Step 3: Use the snapshot in Index**

Replace the manual field-copy block in `refreshSessionState()` with:

```typescript
private refreshSessionState(): void {
  this.session = sessionService.state.snapshot();
}
```

- [ ] **Step 4: Verify focused tests compile and pass**

Run the ohosTest build, install the main and test HAPs on an available device, then run Hypium. Expected: all registered tests pass with zero failures and errors.

### Task 3: Project verification and records

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`
- Create: `docs/qa/2026-08-03-streak-session-snapshot.md`

- [ ] **Step 1: Run static checks**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
git diff --check
```

Expected: both commands exit 0.

- [ ] **Step 2: Run all builds**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode release
```

Expected: all three commands exit 0 and produce HAP artifacts.

- [ ] **Step 3: Run device verification**

List targets with `hdc list targets`. For each available phone, tablet, or 2in1 target, install current HAPs and run Hypium. Record exact pass/fail counts; unavailable device classes remain `blocked`.

- [ ] **Step 4: Update project records**

Add an `in_progress` task before implementation, then mark it `done` only after required automated checks pass. Record commands, outcomes, artifact sizes, device coverage, and any blocked device classes in `changes.md` and the QA evidence file.

- [ ] **Step 5: Review the scoped diff**

```powershell
git diff -- entry/src/main/ets/models/AppModels.ets entry/src/main/ets/repositories/StatsRepository.ets entry/src/main/ets/pages/Index.ets entry/src/ohosTest/ets/test/DataAndSession.test.ets tasks.md changes.md docs/qa/2026-08-03-streak-session-snapshot.md
```

Expected: only the approved behavior, tests, and project records are present; unrelated working-tree changes remain untouched.
