import { JsonCodec } from '../data/JsonCodec';
import { AppSettings, DailyRecord, StatsSummary } from '../models/AppModels';
import { PracticeSession, PracticeSessionDraft } from '../models/PracticeModels';
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
    const durationSeconds: number = Math.max(0, Math.floor((draft.endTime - draft.startTime) / 1000));
    const session: PracticeSession = new PracticeSession(
      `${draft.startTime}-${draft.endTime}-${draft.toolType}`,
      draft.toolType,
      this.settings.selectedSceneMode,
      draft.startTime,
      draft.endTime,
      draft.manualCount,
      draft.automaticCount,
      durationSeconds,
      true,
      DateUtil.toKey(new Date(draft.startTime))
    );
    await this.sessionRepository.append(session);
    this.recentSessions = await this.sessionRepository.recent(20);
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
