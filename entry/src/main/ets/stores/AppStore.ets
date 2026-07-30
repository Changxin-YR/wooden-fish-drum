import { JsonCodec } from '../data/JsonCodec';
import { AppSettings, DailyRecord, StatsSummary } from '../models/AppModels';
import { ThemeMode } from '../models/Enums';
import { SettingsRepository } from '../repositories/SettingsRepository';
import { StatsRepository } from '../repositories/StatsRepository';
import { DateUtil } from '../utils/DateUtil';
import { TextValidator } from '../utils/TextValidator';

export class AppStore {
  settings: AppSettings = JsonCodec.createDefaultSettings();
  summary: StatsSummary = new StatsSummary();
  recentRecords: DailyRecord[] = [];
  private readonly settingsRepository: SettingsRepository;
  private readonly statsRepository: StatsRepository;

  constructor(settingsRepository: SettingsRepository, statsRepository: StatsRepository) {
    this.settingsRepository = settingsRepository;
    this.statsRepository = statsRepository;
  }

  async initialize(): Promise<void> {
    this.settings = await this.settingsRepository.load();
    await this.refreshStats();
  }

  async setThemeMode(mode: ThemeMode): Promise<boolean> {
    this.settings.themeMode = mode;
    this.settings.themeManuallyChanged = true;
    return this.settingsRepository.save(this.settings);
  }

  async persistSettings(): Promise<boolean> {
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

  async recordHit(automatic: boolean): Promise<void> {
    await this.statsRepository.increment(DateUtil.todayKey(), automatic);
    await this.refreshStats();
  }

  async refreshStats(): Promise<void> {
    const today: string = DateUtil.todayKey();
    this.summary = await this.statsRepository.summary(today);
    this.recentRecords = await this.statsRepository.recentDays(today, 7);
  }

  async clearStats(): Promise<void> {
    await this.statsRepository.clear();
    await this.refreshStats();
  }
}
