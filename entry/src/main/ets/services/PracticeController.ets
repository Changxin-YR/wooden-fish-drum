import { PracticeStatus, ToolType } from '../models/Enums';
import { PracticeEvent, PracticeState } from '../models/PracticeModels';
import { AutoRhythmController } from './AutoRhythmController';

export type PracticeEventCallback = (event: PracticeEvent) => void;

export class PracticeController {
  state: PracticeState = new PracticeState();
  private readonly rhythm: AutoRhythmController = new AutoRhythmController();
  private onEvent: PracticeEventCallback = (_event: PracticeEvent): void => {};

  setEventCallback(callback: PracticeEventCallback): void {
    this.onEvent = callback;
  }

  selectTool(toolType: ToolType): void {
    if (this.state.selectedTool === toolType) {
      return;
    }
    this.stop();
    const next: PracticeState = new PracticeState();
    next.selectedTool = toolType;
    this.state = next;
  }

  recordManual(): boolean {
    if (!this.isCountableTool()) {
      return false;
    }
    this.state.manualCount++;
    this.state.hitSequence++;
    this.emitHit(false);
    if (this.state.status === PracticeStatus.IDLE) {
      this.state.status = PracticeStatus.RUNNING;
    }
    return true;
  }

  startAuto(intervalMs: number, durationSeconds: number): boolean {
    if (!this.isCountableTool()) {
      return false;
    }
    const started: boolean = this.rhythm.start(intervalMs, durationSeconds, (): void => {
      this.state.automaticCount++;
      this.state.hitSequence++;
      this.emitHit(true);
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
    this.stop();
  }

  hasActiveTimer(): boolean {
    return this.rhythm.hasTimer();
  }

  private isCountableTool(): boolean {
    return this.state.selectedTool === ToolType.WOODEN_FISH || this.state.selectedTool === ToolType.BEADS;
  }

  private emitHit(automatic: boolean): void {
    this.onEvent(new PracticeEvent(this.state.selectedTool, automatic, this.state.hitSequence));
  }
}
