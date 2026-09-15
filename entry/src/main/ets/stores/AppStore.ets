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
  allRecords: DailyRecord[] = [];
  private readonly settingsRepository: SettingsRepository;
  private readonly statsRepository: StatsRepository;

  constructor(settingsRepository: SettingsRepository, statsRepository: StatsRepository) {
    this.settingsRepository = settingsRepository;
    this.statsRepository = statsRepository;
  }

  async initialize(): Promise<void> {
    this.settings = await this.settingsRepository.load();
    await this.refreshStats();
    const today: string = DateUtil.todayKey();
    if (this.settings.homeCountDate === today && this.settings.homeCountBaseline > this.summary.todayCount) {
      this.settings.homeCountBaseline = 0;
      await this.settingsRepository.save(this.settings);
    }
  }

  async setThemeMode(mode: ThemeMode): Promise<boolean> {
    this.settings.themeMode = mode;
    this.settings.themeManuallyChanged = true;
    return this.settingsRepository.save(this.settings);
  }

  async persistSettings(): Promise<boolean> {
    return this.settingsRepository.save(this.settings);
  }

  settingsSnapshot(): AppSettings {
    return JsonCodec.decodeSettings(JsonCodec.encodeSettings(this.settings));
  }

  async saveCustomText(value: string): Promise<boolean> {
    const normalized: string = TextValidator.normalize(value);
    if (!TextValidator.isValid(normalized)) {
      return false;
    }
    if (!this.settings.customTexts.includes(normalized)) {
      this.settings.customTexts.push(normalized);
    }
    if (normalized !== this.settings.currentText) {
      this.settings.currentText = normalized;
      this.settings.homeCountBaseline = this.summary.todayCount;
      this.settings.homeCountDate = DateUtil.todayKey();
    }
    return this.settingsRepository.save(this.settings);
  }

  currentTextCount(today: string = DateUtil.todayKey()): number {
    if (this.settings.homeCountDate !== today) {
      return this.summary.todayCount;
    }
    return Math.max(0, this.summary.todayCount - this.settings.homeCountBaseline);
  }

  async recordHit(automatic: boolean): Promise<void> {
    await this.statsRepository.increment(DateUtil.todayKey(), automatic);
    await this.refreshStats();
  }

  async refreshStats(): Promise<void> {
    const today: string = DateUtil.todayKey();
    this.summary = await this.statsRepository.summary(today);
    this.recentRecords = await this.statsRepository.recentDays(today, 7);
    this.allRecords = await this.statsRepository.allRecords();
  }

  async clearStats(): Promise<boolean> {
    await this.statsRepository.clear();
    await this.refreshStats();
    this.settings.homeCountBaseline = 0;
    this.settings.homeCountDate = DateUtil.todayKey();
    return this.settingsRepository.save(this.settings);
  }
}
