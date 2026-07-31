import { SceneMode, SessionMode, SoundType, ThemeMode, ToolType, UserMode } from './Enums';

export class AppSettings {
  schemaVersion: number = 2;
  initialized: boolean = false;
  selectedSceneMode: SceneMode = SceneMode.DAILY;
  selectedTool: ToolType = ToolType.WOODEN_FISH;
  feedbackText: string = '放松+1';
  feedbackTextEnabled: boolean = true;
  tapSoundEnabled: boolean = true;
  tapVolume: number = 0.7;
  selectedSoundId: SoundType = SoundType.SOFT;
  autoIntervalMs: number = 1000;
  autoDurationSeconds: number = 0;
  reducedMotion: boolean = false;
  privacyPolicyVersion: string = '';

  // Compatibility aliases remain until all V1 pages consume the V2 fields.
  userMode: UserMode = UserMode.GENERAL;
  themeMode: ThemeMode = ThemeMode.SYSTEM;
  themeManuallyChanged: boolean = false;
  currentText: string = '放松+1';
  customTexts: string[] = [];
  soundEnabled: boolean = true;
  soundType: SoundType = SoundType.SOFT;
  volume: number = 0.7;
  vibrationEnabled: boolean = true;
  floatingTextEnabled: boolean = true;
  autoInterval: number = 1000;
}

export class DailyRecord {
  date: string;
  manualCount: number;
  autoCount: number;
  durationSeconds: number;

  constructor(date: string, manualCount: number = 0, autoCount: number = 0,
    durationSeconds: number = 0) {
    this.date = date;
    this.manualCount = manualCount;
    this.autoCount = autoCount;
    this.durationSeconds = durationSeconds;
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
