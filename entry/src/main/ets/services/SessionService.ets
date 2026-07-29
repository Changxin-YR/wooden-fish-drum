import { SessionState } from '../models/AppModels';
import { SessionMode } from '../models/Enums';

export type HitCallback = (automatic: boolean) => void;
export type TickCallback = (remainingSeconds: number) => void;

export class SessionService {
  state: SessionState = new SessionState();
  private timerId: number = -1;
  private onHit: HitCallback | null = null;
  private onTick: TickCallback | null = null;

  setCallbacks(onHit: HitCallback, onTick: TickCallback): void {
    this.onHit = onHit;
    this.onTick = onTick;
  }

  recordManualHit(): boolean {
    if (this.state.mode === SessionMode.AUTO) {
      return false;
    }
    return this.recordHit(false);
  }

  recordAutoHit(): boolean {
    if (this.state.mode !== SessionMode.AUTO || !this.state.running || this.state.paused) {
      return false;
    }
    return this.recordHit(true);
  }

  startFree(): void {
    this.resetState(SessionMode.FREE);
    this.state.running = true;
  }

  startTarget(target: number): void {
    this.clearTimer();
    this.resetState(SessionMode.TARGET);
    this.state.running = true;
    this.state.targetCount = Math.max(1, target);
  }

  startTimer(seconds: number): boolean {
    if (this.timerId !== -1) {
      return false;
    }
    this.resetState(SessionMode.TIMER);
    this.state.running = true;
    this.state.remainingSeconds = Math.max(1, seconds);
    this.timerId = setInterval((): void => {
      this.state.remainingSeconds--;
      if (this.onTick !== null) {
        this.onTick(this.state.remainingSeconds);
      }
      if (this.state.remainingSeconds <= 0) {
        this.stopTimerOnly();
        this.state.running = false;
      }
    }, 1000);
    return true;
  }

  startAuto(intervalMs: number): boolean {
    if (this.timerId !== -1 || this.state.running) {
      return false;
    }
    this.resetState(SessionMode.AUTO);
    this.state.running = true;
    this.timerId = setInterval((): void => {
      this.recordAutoHit();
    }, Math.max(500, Math.min(2000, intervalMs)));
    return true;
  }

  pause(): void {
    if (this.state.mode === SessionMode.AUTO && this.state.running) {
      this.state.paused = true;
    }
  }

  resume(): void {
    if (this.state.mode === SessionMode.AUTO && this.state.running) {
      this.state.paused = false;
    }
  }

  stop(): void {
    this.clearTimer();
    this.state.running = false;
    this.state.paused = false;
  }

  onBackground(): void {
    this.stop();
  }

  hasTimer(): boolean {
    return this.timerId !== -1;
  }

  private recordHit(automatic: boolean): boolean {
    if (this.state.mode === SessionMode.TARGET && !this.state.running) {
      return false;
    }
    this.state.currentCount++;
    if (this.onHit !== null) {
      this.onHit(automatic);
    }
    if (this.state.mode === SessionMode.TARGET && this.state.currentCount >= this.state.targetCount) {
      this.state.running = false;
    }
    return true;
  }

  private resetState(mode: SessionMode): void {
    this.state = new SessionState();
    this.state.mode = mode;
    this.state.startedAt = Date.now();
  }

  private stopTimerOnly(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private clearTimer(): void {
    this.stopTimerOnly();
  }
}
