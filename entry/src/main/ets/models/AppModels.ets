import { SceneMode, SoundType, ThemeMode, ToolType, UserMode } from './Enums';
import { PracticeSession } from './PracticeModels';

export class AppSettings {
  schemaVersion: number = 2;
  initialized: boolean = false;
  selectedSceneMode: SceneMode = SceneMode.DAILY;
  selectedTool: ToolType = ToolType.WOODEN_FISH;
  feedbackText: string = '放松+1';
  feedbackTextEnabled: boolean = true;
  targetCount: number = 108;
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
  woodenFishCount: number;
  beadsCount: number;
  incenseSeconds: number;
  sessionCount: number;

  constructor(date: string, manualCount: number = 0, autoCount: number = 0,
    durationSeconds: number = 0) {
    this.date = date;
    this.manualCount = manualCount;
    this.autoCount = autoCount;
    this.durationSeconds = durationSeconds;
    this.woodenFishCount = manualCount + autoCount;
    this.beadsCount = 0;
    this.incenseSeconds = 0;
    this.sessionCount = 0;
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
  durationSeconds: number;
  incenseSeconds: number;

  constructor(label: string, manualCount: number = 0, autoCount: number = 0,
    durationSeconds: number = 0, incenseSeconds: number = 0) {
    this.label = label;
    this.manualCount = manualCount;
    this.autoCount = autoCount;
    this.totalCount = manualCount + autoCount;
    this.durationSeconds = durationSeconds;
    this.incenseSeconds = incenseSeconds;
  }
}

export class StatsPeriodView {
  title: string = '';
  scopeLabel: string = '';
  totalCount: number = 0;
  manualCount: number = 0;
  autoCount: number = 0;
  durationSeconds: number = 0;
  incenseSeconds: number = 0;
  woodenFishCount: number = 0;
  beadsCount: number = 0;
  sessionCount: number = 0;
  countMax: number = 1;
  durationMaxSeconds: number = 1;
  buckets: StatsBucket[] = [];
  recentSessions: PracticeSession[] = [];
}

export interface UserModeConfig {
  mode: UserMode;
  title: string;
  description: string;
  detail: string;
  defaultText: string;
  availableTexts: string[];
  defaultTheme: ThemeMode;
  defaultSound: SoundType;
}

export interface SceneModeConfig {
  mode: SceneMode;
  title: string;
  description: string;
  defaultText: string;
  defaultTheme: ThemeMode;
  defaultSound: SoundType;
  recommendedTool: ToolType;
}
