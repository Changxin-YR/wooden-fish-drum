import { PracticeStatus, SceneMode, ToolType } from './Enums';

export class PracticeState {
  selectedTool: ToolType = ToolType.WOODEN_FISH;
  status: PracticeStatus = PracticeStatus.IDLE;
  manualCount: number = 0;
  automaticCount: number = 0;
  automaticActive: boolean = false;
  targetActive: boolean = false;
  targetCompleted: boolean = false;
  targetCount: number = 108;
  sessionCount: number = 0;
  hitSequence: number = 0;
  lastMilestone: number = 0;
  startedAt: number = 0;
  incenseTargetSeconds: number = 0;
  incenseRemainingSeconds: number = 0;
}

export class PracticeSessionDraft {
  toolType: ToolType;
  startTime: number;
  endTime: number;
  manualCount: number;
  automaticCount: number;
  durationSeconds: number;
  completed: boolean;

  constructor(toolType: ToolType, startTime: number, endTime: number,
    manualCount: number, automaticCount: number, durationSeconds: number = -1,
    completed: boolean = true) {
    this.toolType = toolType;
    this.startTime = startTime;
    this.endTime = endTime;
    this.manualCount = manualCount;
    this.automaticCount = automaticCount;
    this.durationSeconds = durationSeconds;
    this.completed = completed;
  }
}

export class IncenseSnapshot {
  status: PracticeStatus;
  startedAt: number;
  targetSeconds: number;
  pausedAt: number;
  accumulatedPauseMs: number;
  completionConsumed: boolean;

  constructor(status: PracticeStatus = PracticeStatus.IDLE, startedAt: number = 0,
    targetSeconds: number = 0, pausedAt: number = 0, accumulatedPauseMs: number = 0,
    completionConsumed: boolean = false) {
    this.status = status;
    this.startedAt = startedAt;
    this.targetSeconds = targetSeconds;
    this.pausedAt = pausedAt;
    this.accumulatedPauseMs = accumulatedPauseMs;
    this.completionConsumed = completionConsumed;
  }
}

export class PracticeEvent {
  toolType: ToolType;
  automatic: boolean;
  hitSequence: number;
  milestone: number;

  constructor(toolType: ToolType, automatic: boolean, hitSequence: number, milestone: number = 0) {
    this.toolType = toolType;
    this.automatic = automatic;
    this.hitSequence = hitSequence;
    this.milestone = milestone;
  }
}

export class DailyStats {
  date: string;
  woodenFishManualCount: number;
  woodenFishAutoCount: number;
  beadsManualCount: number;
  beadsAutoCount: number;
  incenseSeconds: number;
  practiceSeconds: number;
  sessionCount: number;

  constructor(date: string, woodenFishManualCount: number = 0, woodenFishAutoCount: number = 0,
    beadsManualCount: number = 0, beadsAutoCount: number = 0, incenseSeconds: number = 0,
    practiceSeconds: number = 0, sessionCount: number = 0) {
    this.date = date;
    this.woodenFishManualCount = woodenFishManualCount;
    this.woodenFishAutoCount = woodenFishAutoCount;
    this.beadsManualCount = beadsManualCount;
    this.beadsAutoCount = beadsAutoCount;
    this.incenseSeconds = incenseSeconds;
    this.practiceSeconds = practiceSeconds;
    this.sessionCount = sessionCount;
  }

  get woodenFishCount(): number {
    return this.woodenFishManualCount + this.woodenFishAutoCount;
  }

  get beadsCount(): number {
    return this.beadsManualCount + this.beadsAutoCount;
  }

  get totalCount(): number {
    return this.woodenFishCount + this.beadsCount;
  }
}

export class PracticeSession {
  id: string;
  toolType: ToolType;
  sceneMode: SceneMode;
  startTime: number;
  endTime: number;
  manualCount: number;
  automaticCount: number;
  durationSeconds: number;
  completed: boolean;
  date: string;

  constructor(id: string, toolType: ToolType, sceneMode: SceneMode, startTime: number, endTime: number,
    manualCount: number, automaticCount: number, durationSeconds: number, completed: boolean,
    date: string = '') {
    this.id = id;
    this.toolType = toolType;
    this.sceneMode = sceneMode;
    this.startTime = startTime;
    this.endTime = endTime;
    this.manualCount = manualCount;
    this.automaticCount = automaticCount;
    this.durationSeconds = durationSeconds;
    this.completed = completed;
    this.date = date;
  }
}
