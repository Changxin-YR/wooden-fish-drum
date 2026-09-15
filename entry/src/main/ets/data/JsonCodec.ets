import { USER_MODE_CONFIGS } from '../constants/UserModeConfigs';
import { AppSettings, DailyRecord } from '../models/AppModels';
import { SoundType, ThemeMode, UserMode } from '../models/Enums';

export class JsonCodec {
  static createDefaultSettings(): AppSettings {
    return JsonCodec.createSettingsForMode(UserMode.GENERAL, true);
  }

  static createSettingsForMode(mode: UserMode, initialized: boolean = true): AppSettings {
    const settings: AppSettings = new AppSettings();
    settings.initialized = initialized;
    settings.userMode = mode;
    settings.themeMode = USER_MODE_CONFIGS[mode].defaultTheme;
    settings.currentText = USER_MODE_CONFIGS[mode].defaultText;
    settings.soundType = USER_MODE_CONFIGS[mode].defaultSound;
    return settings;
  }

  static encodeSettings(settings: AppSettings): string {
    return JSON.stringify(settings);
  }

  static decodeSettings(snapshot: string): AppSettings {
    const defaults: AppSettings = JsonCodec.createDefaultSettings();
    if (snapshot.length === 0) {
      return defaults;
    }
    try {
      const parsed: AppSettings = JSON.parse(snapshot) as AppSettings;
      if (parsed === null || typeof parsed !== 'object') {
        return defaults;
      }
      const result: AppSettings = new AppSettings();
      result.initialized = true;
      result.userMode = UserMode.GENERAL;
      result.themeMode = JsonCodec.isThemeMode(parsed.themeMode) ? parsed.themeMode : defaults.themeMode;
      result.themeManuallyChanged = typeof parsed.themeManuallyChanged === 'boolean' ?
        parsed.themeManuallyChanged : defaults.themeManuallyChanged;
      result.currentText = typeof parsed.currentText === 'string' && parsed.currentText.length > 0 ?
        parsed.currentText : defaults.currentText;
      result.customTexts = Array.isArray(parsed.customTexts) ? parsed.customTexts : [];
      result.soundEnabled = typeof parsed.soundEnabled === 'boolean' ? parsed.soundEnabled : defaults.soundEnabled;
      result.soundType = JsonCodec.isSoundType(parsed.soundType) ? parsed.soundType : defaults.soundType;
      result.volume = typeof parsed.volume === 'number' ? Math.max(0, Math.min(1, parsed.volume)) : defaults.volume;
      result.vibrationEnabled = typeof parsed.vibrationEnabled === 'boolean' ?
        parsed.vibrationEnabled : defaults.vibrationEnabled;
      result.floatingTextEnabled = typeof parsed.floatingTextEnabled === 'boolean' ?
        parsed.floatingTextEnabled : defaults.floatingTextEnabled;
      result.autoInterval = typeof parsed.autoInterval === 'number' ?
        Math.max(500, Math.min(2000, parsed.autoInterval)) : defaults.autoInterval;
      result.targetCount = typeof parsed.targetCount === 'number' ?
        Math.max(1, Math.min(9999, parsed.targetCount)) : defaults.targetCount;
      result.homeCountBaseline = typeof parsed.homeCountBaseline === 'number' ?
        Math.max(0, parsed.homeCountBaseline) : defaults.homeCountBaseline;
      result.homeCountDate = typeof parsed.homeCountDate === 'string' ?
        parsed.homeCountDate : defaults.homeCountDate;
      return result;
    } catch {
      return defaults;
    }
  }

  static encodeRecords(records: DailyRecord[]): string {
    return JSON.stringify(records);
  }

  static decodeRecords(snapshot: string): DailyRecord[] {
    if (snapshot.length === 0) {
      return [];
    }
    try {
      const parsed: DailyRecord[] = JSON.parse(snapshot) as DailyRecord[];
      if (!Array.isArray(parsed)) {
        return [];
      }
      const records: DailyRecord[] = [];
      parsed.forEach((item: DailyRecord): void => {
        if (item !== null && typeof item.date === 'string' &&
          typeof item.manualCount === 'number' && typeof item.autoCount === 'number') {
          records.push(new DailyRecord(item.date, Math.max(0, item.manualCount),
            Math.max(0, item.autoCount)));
        }
      });
      return records;
    } catch {
      return [];
    }
  }

  private static isThemeMode(value: ThemeMode): boolean {
    return value === ThemeMode.SYSTEM || value === ThemeMode.LIGHT || value === ThemeMode.DARK;
  }

  private static isSoundType(value: SoundType): boolean {
    return value === SoundType.DEEP || value === SoundType.CRISP || value === SoundType.SOFT;
  }
}
