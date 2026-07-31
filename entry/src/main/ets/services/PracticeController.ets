import { PracticeStatus, ToolType } from '../models/Enums';
import { PracticeEvent, PracticeSessionDraft, PracticeState } from '../models/PracticeModels';
import { AutoRhythmController } from './AutoRhythmController';

export type PracticeEventCallback = (event: PracticeEvent) => void;
export type PracticeSessionCallback = (draft: PracticeSessionDraft) => void;

export class PracticeController {
  state: PracticeState = new PracticeState();
  private readonly rhythm: AutoRhythmController = new AutoRhythmController();
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
    this.finishSession();
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

  private emitHit(automatic: boolean, milestone: number): void {
    this.onEvent(new PracticeEvent(this.state.selectedTool, automatic, this.state.hitSequence, milestone));
  }
}
