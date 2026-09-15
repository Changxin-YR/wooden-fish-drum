import { SessionMode, SoundType, ThemeMode, UserMode } from './Enums';

export class AppSettings {
  initialized: boolean = true;
  userMode: UserMode = UserMode.GENERAL;
  themeMode: ThemeMode = ThemeMode.SYSTEM;
  themeManuallyChanged: boolean = false;
  currentText: string = '功德+1';
  customTexts: string[] = [];
  soundEnabled: boolean = true;
  soundType: SoundType = SoundType.SOFT;
  volume: number = 0.7;
  vibrationEnabled: boolean = true;
  floatingTextEnabled: boolean = true;
  autoInterval: number = 1000;
  targetCount: number = 108;
  homeCountBaseline: number = 0;
  homeCountDate: string = '';
}

export class DailyRecord {
  date: string;
  manualCount: number;
  autoCount: number;

  constructor(date: string, manualCount: number = 0, autoCount: number = 0) {
    this.date = date;
    this.manualCount = manualCount;
    this.autoCount = autoCount;
  }

  get totalCount(): number {
    return this.manualCount + this.autoCount;
  }
}

export class StatsSummary {
  todayCount: number = 0;
  totalCount: number = 0;
  manualCount: number = 0;
  autoCount: number = 0;
  streakDays: number = 0;
  maxDailyCount: number = 0;
}

export class StatsBucket {
  label: string;
  totalCount: number;
  manualCount: number;
  autoCount: number;

  constructor(label: string, manualCount: number = 0, autoCount: number = 0) {
    this.label = label;
    this.manualCount = manualCount;
    this.autoCount = autoCount;
    this.totalCount = manualCount + autoCount;
  }
}

export class StatsPeriodView {
  title: string = '';
  scopeLabel: string = '';
  totalCount: number = 0;
  manualCount: number = 0;
  autoCount: number = 0;
  buckets: StatsBucket[] = [];
}

export class SessionState {
  mode: SessionMode = SessionMode.FREE;
  hitSequence: number = 0;
  running: boolean = false;
  paused: boolean = false;
  targetCompleted: boolean = false;
  currentCount: number = 0;
  targetCount: number = 0;
  startedAt: number = 0;

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
}

export interface UserModeConfig {
  mode: UserMode;
  title: string;
  description: string;
  detail: string;
  defaultText: string;
  availableTexts: string[];
  recommendedTargets: number[];
  defaultTheme: ThemeMode;
  defaultSound: SoundType;
  featureOrder: SessionMode[];
}
