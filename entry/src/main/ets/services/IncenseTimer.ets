import { PracticeStatus } from '../models/Enums';
import { IncenseSnapshot } from '../models/PracticeModels';

export class IncenseTimer {
  status: PracticeStatus = PracticeStatus.IDLE;
  private startedAt: number = 0;
  private targetSeconds: number = 0;
  private pausedAt: number = 0;
  private accumulatedPauseMs: number = 0;
  private completionConsumed: boolean = false;

  start(now: number, durationSeconds: number): boolean {
    if (durationSeconds <= 0 || this.status === PracticeStatus.RUNNING) {
      return false;
    }
    this.startedAt = now;
    this.targetSeconds = Math.floor(durationSeconds);
    this.pausedAt = 0;
    this.accumulatedPauseMs = 0;
    this.completionConsumed = false;
    this.status = PracticeStatus.RUNNING;
    return true;
  }

  pause(now: number): boolean {
    if (this.status !== PracticeStatus.RUNNING) {
      return false;
    }
    this.pausedAt = now;
    this.status = PracticeStatus.PAUSED;
    return true;
  }

  resume(now: number): boolean {
    if (this.status !== PracticeStatus.PAUSED) {
      return false;
    }
    this.accumulatedPauseMs += Math.max(0, now - this.pausedAt);
    this.pausedAt = 0;
    this.status = PracticeStatus.RUNNING;
    return true;
  }

  remainingAt(now: number): number {
    if (this.status === PracticeStatus.IDLE) {
      return this.targetSeconds;
    }
    const effectiveNow: number = this.status === PracticeStatus.PAUSED ? this.pausedAt : now;
    const elapsedMs: number = Math.max(0, effectiveNow - this.startedAt - this.accumulatedPauseMs);
    return Math.max(0, this.targetSeconds - Math.floor(elapsedMs / 1000));
  }

  elapsedSecondsAt(now: number): number {
    if (this.startedAt === 0) {
      return 0;
    }
    const effectiveNow: number = this.status === PracticeStatus.PAUSED ? this.pausedAt : now;
    const elapsedMs: number = Math.max(0, effectiveNow - this.startedAt - this.accumulatedPauseMs);
    return Math.min(this.targetSeconds, Math.floor(elapsedMs / 1000));
  }

  get startTime(): number {
    return this.startedAt;
  }

  get durationSeconds(): number {
    return this.targetSeconds;
  }

  snapshot(): IncenseSnapshot {
    return new IncenseSnapshot(this.status, this.startedAt, this.targetSeconds, this.pausedAt,
      this.accumulatedPauseMs, this.completionConsumed);
  }

  restore(snapshot: IncenseSnapshot): boolean {
    if ((snapshot.status !== PracticeStatus.RUNNING && snapshot.status !== PracticeStatus.PAUSED) ||
      snapshot.startedAt <= 0 || snapshot.targetSeconds <= 0 || snapshot.accumulatedPauseMs < 0 ||
      (snapshot.status === PracticeStatus.PAUSED && snapshot.pausedAt < snapshot.startedAt)) {
      return false;
    }
    this.status = snapshot.status;
    this.startedAt = snapshot.startedAt;
    this.targetSeconds = Math.floor(snapshot.targetSeconds);
    this.pausedAt = snapshot.status === PracticeStatus.PAUSED ? snapshot.pausedAt : 0;
    this.accumulatedPauseMs = snapshot.accumulatedPauseMs;
    this.completionConsumed = snapshot.completionConsumed;
    return true;
  }

  consumeCompletion(now: number): boolean {
    if (this.completionConsumed || this.remainingAt(now) > 0) {
      return false;
    }
    this.completionConsumed = true;
    this.status = PracticeStatus.COMPLETED;
    return true;
  }

  stop(): void {
    this.status = PracticeStatus.IDLE;
    this.startedAt = 0;
    this.targetSeconds = 0;
    this.pausedAt = 0;
    this.accumulatedPauseMs = 0;
    this.completionConsumed = false;
  }
}
