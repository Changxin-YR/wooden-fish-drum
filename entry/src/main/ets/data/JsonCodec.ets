import { USER_MODE_CONFIGS } from '../constants/UserModeConfigs';
import { AppSettings, DailyRecord } from '../models/AppModels';
import { SceneMode, UserMode } from '../models/Enums';
import { SettingsMigration } from '../utils/SettingsMigration';

export class JsonCodec {
  static createDefaultSettings(): AppSettings {
    return SettingsMigration.createDefaults();
  }

  static createSettingsForMode(mode: UserMode, initialized: boolean = true): AppSettings {
    const settings: AppSettings = new AppSettings();
    settings.initialized = initialized;
    settings.userMode = mode;
    settings.selectedSceneMode = JsonCodec.sceneModeForUserMode(mode);
    settings.themeMode = USER_MODE_CONFIGS[mode].defaultTheme;
    settings.feedbackText = USER_MODE_CONFIGS[mode].defaultText;
    settings.selectedSoundId = USER_MODE_CONFIGS[mode].defaultSound;
    SettingsMigration.syncCompatibilityAliases(settings);
    return settings;
  }

  static encodeSettings(settings: AppSettings): string {
    SettingsMigration.syncV2FieldsFromCompatibilityAliases(settings);
    return JSON.stringify(settings);
  }

  static decodeSettings(snapshot: string): AppSettings {
    return SettingsMigration.decode(snapshot);
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
            Math.max(0, item.autoCount), Math.max(0, item.durationSeconds ?? 0)));
        }
      });
      return records;
    } catch {
      return [];
    }
  }

  private static sceneModeForUserMode(mode: UserMode): SceneMode {
    if (mode === UserMode.PROGRAMMER) {
      return SceneMode.PROGRAMMER;
    }
    if (mode === UserMode.MONK) {
      return SceneMode.MINDFUL;
    }
    return SceneMode.DAILY;
  }
}
