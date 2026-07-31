import { PracticeStatus, SceneMode, ToolType } from './Enums';

export class PracticeState {
  selectedTool: ToolType = ToolType.WOODEN_FISH;
  status: PracticeStatus = PracticeStatus.IDLE;
  manualCount: number = 0;
  automaticCount: number = 0;
  hitSequence: number = 0;
}

export class PracticeEvent {
  toolType: ToolType;
  automatic: boolean;
  hitSequence: number;

  constructor(toolType: ToolType, automatic: boolean, hitSequence: number) {
    this.toolType = toolType;
    this.automatic = automatic;
    this.hitSequence = hitSequence;
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
