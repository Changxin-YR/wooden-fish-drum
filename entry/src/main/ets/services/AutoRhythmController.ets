import { PracticeStatus } from '../models/Enums';

export type RhythmTickCallback = () => void;

export class AutoRhythmController {
  status: PracticeStatus = PracticeStatus.IDLE;
  private timerId: number = -1;
  private intervalMs: number = 1000;
  private durationSeconds: number = 0;
  private elapsedSeconds: number = 0;
  private onTick: RhythmTickCallback = (): void => {};

  start(intervalMs: number, durationSeconds: number, onTick: RhythmTickCallback): boolean {
    if (this.timerId !== -1 || this.status === PracticeStatus.RUNNING) {
      return false;
    }
    this.intervalMs = Math.max(500, Math.min(3000, intervalMs));
    this.durationSeconds = Math.max(0, durationSeconds);
    this.elapsedSeconds = 0;
    this.onTick = onTick;
    this.status = PracticeStatus.RUNNING;
    this.schedule();
    return true;
  }

  pause(): boolean {
    if (this.status !== PracticeStatus.RUNNING) {
      return false;
    }
    this.clearTimer();
    this.status = PracticeStatus.PAUSED;
    return true;
  }

  resume(): boolean {
    if (this.status !== PracticeStatus.PAUSED || this.timerId !== -1) {
      return false;
    }
    this.status = PracticeStatus.RUNNING;
    this.schedule();
    return true;
  }

  stop(): void {
    this.clearTimer();
    this.status = PracticeStatus.IDLE;
    this.elapsedSeconds = 0;
  }

  hasTimer(): boolean {
    return this.timerId !== -1;
  }

  private schedule(): void {
    this.timerId = setInterval((): void => {
      this.onTick();
      this.elapsedSeconds += this.intervalMs / 1000;
      if (this.durationSeconds > 0 && this.elapsedSeconds >= this.durationSeconds) {
        this.clearTimer();
        this.status = PracticeStatus.COMPLETED;
      }
    }, this.intervalMs);
  }

  private clearTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }
}
