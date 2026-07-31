import { PracticeStatus, ToolType } from '../models/Enums';
import { IncenseSnapshot, PracticeEvent, PracticeSessionDraft, PracticeState } from '../models/PracticeModels';
import { AutoRhythmController } from './AutoRhythmController';
import { IncenseTimer } from './IncenseTimer';

export type PracticeEventCallback = (event: PracticeEvent) => void;
export type PracticeSessionCallback = (draft: PracticeSessionDraft) => void;

export class PracticeController {
  state: PracticeState = new PracticeState();
  private readonly rhythm: AutoRhythmController = new AutoRhythmController();
  private readonly incense: IncenseTimer = new IncenseTimer();
  private onEvent: PracticeEventCallback = (_event: PracticeEvent): void => {};
  private onSession: PracticeSessionCallback = (_draft: PracticeSessionDraft): void => {};
  private lastBeadsGestureId: number = -1;

  setEventCallback(callback: PracticeEventCallback): void {
    this.onEvent = callback;
  }

  setSessionCallback(callback: PracticeSessionCallback): void {
    this.onSession = callback;
  }

  selectTool(toolType: ToolType): void {
    if (this.state.selectedTool === toolType) {
      return;
    }
    this.rhythm.stop();
    if (this.state.selectedTool === ToolType.INCENSE) {
      this.finishIncense(Date.now(), false);
    } else {
      this.finishSession();
    }
    const next: PracticeState = new PracticeState();
    next.selectedTool = toolType;
    this.state = next;
    this.lastBeadsGestureId = -1;
  }

  recordManual(): boolean {
    if (!this.isCountableTool()) {
      return false;
    }
    this.ensureStarted();
    this.state.manualCount++;
    this.state.hitSequence++;
    this.state.lastMilestone = this.currentMilestone();
    this.emitHit(false, this.state.lastMilestone);
    if (this.state.status === PracticeStatus.IDLE) {
      this.state.status = PracticeStatus.RUNNING;
    }
    return true;
  }

  recordBeadsGesture(gestureId: number): boolean {
    if (this.state.selectedTool !== ToolType.BEADS || gestureId === this.lastBeadsGestureId) {
      return false;
    }
    this.lastBeadsGestureId = gestureId;
    return this.recordManual();
  }

  startAuto(intervalMs: number, durationSeconds: number): boolean {
    if (!this.isCountableTool()) {
      return false;
    }
    this.ensureStarted();
    const started: boolean = this.rhythm.start(intervalMs, durationSeconds, (): void => {
      this.state.automaticCount++;
      this.state.hitSequence++;
      this.state.lastMilestone = this.currentMilestone();
      this.emitHit(true, this.state.lastMilestone);
    });
    if (started) {
      this.state.status = PracticeStatus.RUNNING;
    }
    return started;
  }

  startIncense(durationSeconds: number, now: number = Date.now()): boolean {
    if (this.state.selectedTool !== ToolType.INCENSE ||
      ![300, 600, 900, 1200, 1800].includes(durationSeconds)) {
      return false;
    }
    if (!this.incense.start(now, durationSeconds)) {
      return false;
    }
    this.state.status = PracticeStatus.RUNNING;
    this.state.startedAt = now;
    this.state.incenseTargetSeconds = durationSeconds;
    this.state.incenseRemainingSeconds = durationSeconds;
    return true;
  }

  pauseIncense(now: number = Date.now()): boolean {
    const paused: boolean = this.incense.pause(now);
    if (paused) {
      this.state.status = PracticeStatus.PAUSED;
      this.state.incenseRemainingSeconds = this.incense.remainingAt(now);
    }
    return paused;
  }

  resumeIncense(now: number = Date.now()): boolean {
    const resumed: boolean = this.incense.resume(now);
    if (resumed) {
      this.state.status = PracticeStatus.RUNNING;
      this.state.incenseRemainingSeconds = this.incense.remainingAt(now);
    }
    return resumed;
  }

  refreshIncense(now: number = Date.now()): void {
    if (this.state.selectedTool !== ToolType.INCENSE || this.state.incenseTargetSeconds === 0 ||
      this.incense.startTime === 0) {
      return;
    }
    this.state.incenseRemainingSeconds = this.incense.remainingAt(now);
    if (this.incense.consumeCompletion(now)) {
      this.state.status = PracticeStatus.COMPLETED;
      this.finishIncense(now, true);
    }
  }

  stopIncense(now: number = Date.now()): void {
    this.finishIncense(now, false);
    this.incense.stop();
    const next: PracticeState = new PracticeState();
    next.selectedTool = ToolType.INCENSE;
    this.state = next;
  }

  incenseSnapshot(): IncenseSnapshot | null {
    return this.incense.startTime === 0 ? null : this.incense.snapshot();
  }

  restoreIncense(snapshot: IncenseSnapshot, now: number = Date.now()): boolean {
    this.rhythm.stop();
    if (!this.incense.restore(snapshot)) {
      return false;
    }
    const next: PracticeState = new PracticeState();
    next.selectedTool = ToolType.INCENSE;
    next.status = snapshot.status;
    next.startedAt = snapshot.startedAt;
    next.incenseTargetSeconds = snapshot.targetSeconds;
    next.incenseRemainingSeconds = this.incense.remainingAt(now);
    this.state = next;
    this.refreshIncense(now);
    return true;
  }

  pause(): boolean {
    const paused: boolean = this.rhythm.pause();
    if (paused) {
      this.state.status = PracticeStatus.PAUSED;
    }
    return paused;
  }

  resume(): boolean {
    const resumed: boolean = this.rhythm.resume();
    if (resumed) {
      this.state.status = PracticeStatus.RUNNING;
    }
    return resumed;
  }

  stop(): void {
    this.rhythm.stop();
    this.state.status = PracticeStatus.IDLE;
  }

  onBackground(): void {
    if (this.state.selectedTool === ToolType.INCENSE) {
      this.refreshIncense(Date.now());
      return;
    }
    this.rhythm.stop();
    this.finishSession();
    const next: PracticeState = new PracticeState();
    next.selectedTool = this.state.selectedTool;
    this.state = next;
    this.lastBeadsGestureId = -1;
  }

  hasActiveTimer(): boolean {
    return this.rhythm.hasTimer();
  }

  private isCountableTool(): boolean {
    return this.state.selectedTool === ToolType.WOODEN_FISH || this.state.selectedTool === ToolType.BEADS;
  }

  private currentMilestone(): number {
    if (this.state.selectedTool !== ToolType.BEADS) {
      return 0;
    }
    const count: number = this.state.manualCount + this.state.automaticCount;
    return count === 27 || count === 54 || count === 108 ? count : 0;
  }

  private ensureStarted(): void {
    if (this.state.startedAt === 0) {
      this.state.startedAt = Date.now();
    }
  }

  private finishSession(): void {
    if (this.state.startedAt === 0 ||
      this.state.manualCount + this.state.automaticCount === 0) {
      return;
    }
    this.onSession(new PracticeSessionDraft(this.state.selectedTool, this.state.startedAt, Date.now(),
      this.state.manualCount, this.state.automaticCount));
  }

  private finishIncense(now: number, completed: boolean): void {
    if (this.incense.startTime === 0) {
      return;
    }
    const durationSeconds: number = completed ? this.incense.durationSeconds :
      this.incense.elapsedSecondsAt(now);
    this.onSession(new PracticeSessionDraft(ToolType.INCENSE, this.incense.startTime, now,
      0, 0, durationSeconds, completed));
    this.incense.stop();
  }

  private emitHit(automatic: boolean, milestone: number): void {
    this.onEvent(new PracticeEvent(this.state.selectedTool, automatic, this.state.hitSequence, milestone));
  }
}
