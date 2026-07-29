import { USER_MODE_CONFIGS } from '../constants/UserModeConfigs';
import { JsonCodec } from '../data/JsonCodec';
import { AppSettings, DailyRecord, StatsSummary } from '../models/AppModels';
import { ThemeMode, UserMode } from '../models/Enums';
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

  async selectInitialMode(mode: UserMode): Promise<boolean> {
    this.settings = JsonCodec.createSettingsForMode(mode);
    return this.settingsRepository.save(this.settings);
  }

  async switchMode(mode: UserMode): Promise<boolean> {
    const currentPreset: boolean =
      USER_MODE_CONFIGS[this.settings.userMode].availableTexts.includes(this.settings.currentText);
    const next: AppSettings = JsonCodec.decodeSettings(JsonCodec.encodeSettings(this.settings));
    next.userMode = mode;
    if (currentPreset) {
      next.currentText = USER_MODE_CONFIGS[mode].defaultText;
    }
    if (!next.themeManuallyChanged) {
      next.themeMode = USER_MODE_CONFIGS[mode].defaultTheme;
    }
    next.soundType = USER_MODE_CONFIGS[mode].defaultSound;
    this.settings = next;
    return this.settingsRepository.save(next);
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
