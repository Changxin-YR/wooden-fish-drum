import { JsonCodec } from '../data/JsonCodec';
import { AppSettings, DailyRecord, StatsSummary } from '../models/AppModels';
import { IncenseSnapshot, PracticeSession, PracticeSessionDraft } from '../models/PracticeModels';
import { ThemeMode } from '../models/Enums';
import { SceneMode, ToolType } from '../models/Enums';
import { SettingsRepository } from '../repositories/SettingsRepository';
import { StatsRepository } from '../repositories/StatsRepository';
import { PracticeSessionRepository } from '../repositories/PracticeSessionRepository';
import { DateUtil } from '../utils/DateUtil';
import { TextValidator } from '../utils/TextValidator';
import { SettingsMigration } from '../utils/SettingsMigration';

export class AppStore {
  settings: AppSettings = JsonCodec.createDefaultSettings();
  summary: StatsSummary = new StatsSummary();
  recentRecords: DailyRecord[] = [];
  allRecords: DailyRecord[] = [];
  recentSessions: PracticeSession[] = [];
  private readonly settingsRepository: SettingsRepository;
  private readonly statsRepository: StatsRepository;
  private readonly sessionRepository: PracticeSessionRepository;

  constructor(settingsRepository: SettingsRepository, statsRepository: StatsRepository,
    sessionRepository: PracticeSessionRepository) {
    this.settingsRepository = settingsRepository;
    this.statsRepository = statsRepository;
    this.sessionRepository = sessionRepository;
  }

  async initialize(): Promise<void> {
    this.settings = await this.settingsRepository.load();
    await this.refreshStats();
    this.recentSessions = await this.sessionRepository.recent(20);
  }

  async setThemeMode(mode: ThemeMode): Promise<boolean> {
    this.settings.themeMode = mode;
    this.settings.themeManuallyChanged = true;
    return this.settingsRepository.save(this.settings);
  }

  async persistSettings(): Promise<boolean> {
    return this.settingsRepository.save(this.settings);
  }

  async completeOnboarding(sceneMode: SceneMode, toolType: ToolType): Promise<boolean> {
    SettingsMigration.applyOnboarding(this.settings, sceneMode, toolType);
    return this.settingsRepository.save(this.settings);
  }

  async saveCustomText(value: string): Promise<boolean> {
    const normalized: string = TextValidator.normalize(value);
    if (!TextValidator.isValid(normalized)) {
      return false;
    }
    if (!this.settings.customTexts.includes(normalized)) {
      this.settings.customTexts.push(normalized);
    }
    this.settings.currentText = normalized;
    return this.settingsRepository.save(this.settings);
  }

  async recordHit(toolType: ToolType, automatic: boolean): Promise<void> {
    await this.statsRepository.incrementTool(DateUtil.todayKey(), toolType, automatic);
    await this.refreshStats();
  }

  async savePracticeSession(draft: PracticeSessionDraft): Promise<void> {
    const durationSeconds: number = draft.durationSeconds >= 0 ? draft.durationSeconds :
      Math.max(0, Math.floor((draft.endTime - draft.startTime) / 1000));
    const session: PracticeSession = new PracticeSession(
      `${draft.startTime}-${draft.endTime}-${draft.toolType}`,
      draft.toolType,
      this.settings.selectedSceneMode,
      draft.startTime,
      draft.endTime,
      draft.manualCount,
      draft.automaticCount,
      durationSeconds,
      draft.completed,
      DateUtil.toKey(new Date(draft.startTime))
    );
    const inserted: boolean = await this.sessionRepository.append(session);
    if (inserted && draft.toolType === ToolType.INCENSE) {
      await this.statsRepository.applySession(session);
      await this.refreshStats();
    }
    this.recentSessions = await this.sessionRepository.recent(20);
  }

  async saveActiveIncense(snapshot: IncenseSnapshot): Promise<void> {
    await this.sessionRepository.saveActiveIncense(snapshot);
  }

  async loadActiveIncense(): Promise<IncenseSnapshot | null> {
    return this.sessionRepository.loadActiveIncense();
  }

  async clearActiveIncense(): Promise<void> {
    await this.sessionRepository.clearActiveIncense();
  }

  async refreshStats(): Promise<void> {
    const today: string = DateUtil.todayKey();
    this.summary = await this.statsRepository.summary(today);
    this.recentRecords = await this.statsRepository.recentDays(today, 7);
    this.allRecords = await this.statsRepository.allRecords();
  }

  async clearStats(): Promise<void> {
    await this.statsRepository.clear();
    await this.refreshStats();
  }
}
