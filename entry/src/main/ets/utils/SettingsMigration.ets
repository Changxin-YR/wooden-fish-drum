import { AppSettings } from '../models/AppModels';
import { SceneMode, SoundType, ThemeMode, ToolType, UserMode } from '../models/Enums';
import { SCENE_MODE_CONFIGS } from '../constants/UserModeConfigs';

export class SettingsMigration {
  static createDefaults(): AppSettings {
    return new AppSettings();
  }

  static decode(snapshot: string): AppSettings {
    const defaults: AppSettings = SettingsMigration.createDefaults();
    if (snapshot.length === 0) {
      return defaults;
    }
    try {
      const parsed: AppSettings = JSON.parse(snapshot) as AppSettings;
      if (parsed === null || typeof parsed !== 'object') {
        return defaults;
      }
      const result: AppSettings = new AppSettings();
      result.schemaVersion = 2;
      result.initialized = typeof parsed.initialized === 'boolean' ? parsed.initialized : false;
      result.selectedSceneMode = SettingsMigration.resolveSceneMode(parsed);
      result.selectedTool = SettingsMigration.isToolType(parsed.selectedTool) ?
        parsed.selectedTool : ToolType.WOODEN_FISH;
      result.themeMode = SettingsMigration.isThemeMode(parsed.themeMode) ?
        parsed.themeMode : defaults.themeMode;
      result.themeManuallyChanged = typeof parsed.themeManuallyChanged === 'boolean' ?
        parsed.themeManuallyChanged : defaults.themeManuallyChanged;
      result.feedbackText = SettingsMigration.firstText(parsed.feedbackText, parsed.currentText,
        SettingsMigration.defaultFeedback(result.selectedSceneMode));
      result.targetCount = SettingsMigration.validTarget(parsed.targetCount) ?
        Math.floor(parsed.targetCount) : defaults.targetCount;
      result.customTexts = Array.isArray(parsed.customTexts) ? parsed.customTexts : [];
      result.feedbackTextEnabled = SettingsMigration.firstBoolean(parsed.feedbackTextEnabled,
        parsed.floatingTextEnabled, defaults.feedbackTextEnabled);
      result.tapSoundEnabled = SettingsMigration.firstBoolean(parsed.tapSoundEnabled,
        parsed.soundEnabled, defaults.tapSoundEnabled);
      result.selectedSoundId = SettingsMigration.resolveSound(parsed);
      result.tapVolume = SettingsMigration.clamp(SettingsMigration.firstNumber(parsed.tapVolume,
        parsed.volume, defaults.tapVolume), 0, 1);
      result.vibrationEnabled = typeof parsed.vibrationEnabled === 'boolean' ?
        parsed.vibrationEnabled : defaults.vibrationEnabled;
      result.autoIntervalMs = SettingsMigration.clamp(SettingsMigration.firstNumber(parsed.autoIntervalMs,
        parsed.autoInterval, defaults.autoIntervalMs), 500, 3000);
      result.autoDurationSeconds = typeof parsed.autoDurationSeconds === 'number' ?
        Math.max(0, Math.floor(parsed.autoDurationSeconds)) : defaults.autoDurationSeconds;
      result.reducedMotion = typeof parsed.reducedMotion === 'boolean' ?
        parsed.reducedMotion : defaults.reducedMotion;
      result.privacyPolicyVersion = typeof parsed.privacyPolicyVersion === 'string' ?
        parsed.privacyPolicyVersion : defaults.privacyPolicyVersion;
      SettingsMigration.syncCompatibilityAliases(result);
      return result;
    } catch {
      return defaults;
    }
  }

  static syncCompatibilityAliases(settings: AppSettings): void {
    settings.userMode = SettingsMigration.toUserMode(settings.selectedSceneMode);
    settings.currentText = settings.feedbackText;
    settings.floatingTextEnabled = settings.feedbackTextEnabled;
    settings.soundEnabled = settings.tapSoundEnabled;
    settings.soundType = settings.selectedSoundId;
    settings.volume = settings.tapVolume;
    settings.autoInterval = settings.autoIntervalMs;
  }

  static syncV2FieldsFromCompatibilityAliases(settings: AppSettings): void {
    settings.selectedSceneMode = SettingsMigration.sceneModeFromUserMode(settings.userMode);
    settings.feedbackText = settings.currentText;
    settings.feedbackTextEnabled = settings.floatingTextEnabled;
    settings.tapSoundEnabled = settings.soundEnabled;
    settings.selectedSoundId = settings.soundType;
    settings.tapVolume = SettingsMigration.clamp(settings.volume, 0, 1);
    settings.autoIntervalMs = SettingsMigration.clamp(settings.autoInterval, 500, 3000);
  }

  static applyOnboarding(settings: AppSettings, sceneMode: SceneMode, toolType: ToolType): void {
    settings.initialized = true;
    settings.selectedSceneMode = sceneMode;
    settings.selectedTool = toolType;
    settings.themeMode = SCENE_MODE_CONFIGS[sceneMode].defaultTheme;
    settings.themeManuallyChanged = false;
    settings.feedbackText = SCENE_MODE_CONFIGS[sceneMode].defaultText;
    settings.selectedSoundId = SCENE_MODE_CONFIGS[sceneMode].defaultSound;
    SettingsMigration.syncCompatibilityAliases(settings);
  }

  private static resolveSceneMode(parsed: AppSettings): SceneMode {
    if (SettingsMigration.isSceneMode(parsed.selectedSceneMode)) {
      return parsed.selectedSceneMode;
    }
    if (parsed.userMode === UserMode.PROGRAMMER) {
      return SceneMode.PROGRAMMER;
    }
    if (parsed.userMode === UserMode.MONK) {
      return SceneMode.MINDFUL;
    }
    return SceneMode.DAILY;
  }

  private static resolveSound(parsed: AppSettings): SoundType {
    if (SettingsMigration.isSoundType(parsed.selectedSoundId)) {
      return parsed.selectedSoundId;
    }
    if (SettingsMigration.isSoundType(parsed.soundType)) {
      return parsed.soundType;
    }
    return SoundType.SOFT;
  }

  private static defaultFeedback(sceneMode: SceneMode): string {
    if (sceneMode === SceneMode.PROGRAMMER) {
      return '专注+1';
    }
    if (sceneMode === SceneMode.MINDFUL) {
      return '静心+1';
    }
    return '放松+1';
  }

  private static toUserMode(sceneMode: SceneMode): UserMode {
    if (sceneMode === SceneMode.PROGRAMMER) {
      return UserMode.PROGRAMMER;
    }
    if (sceneMode === SceneMode.MINDFUL) {
      return UserMode.MONK;
    }
    return UserMode.GENERAL;
  }

  private static sceneModeFromUserMode(userMode: UserMode): SceneMode {
    if (userMode === UserMode.PROGRAMMER) {
      return SceneMode.PROGRAMMER;
    }
    if (userMode === UserMode.MONK) {
      return SceneMode.MINDFUL;
    }
    return SceneMode.DAILY;
  }

  private static firstText(primary: string, legacy: string, fallback: string): string {
    if (typeof primary === 'string' && primary.length > 0) {
      return primary;
    }
    if (typeof legacy === 'string' && legacy.length > 0) {
      return legacy;
    }
    return fallback;
  }

  private static firstBoolean(primary: boolean, legacy: boolean, fallback: boolean): boolean {
    if (typeof primary === 'boolean') {
      return primary;
    }
    if (typeof legacy === 'boolean') {
      return legacy;
    }
    return fallback;
  }

  private static firstNumber(primary: number, legacy: number, fallback: number): number {
    if (typeof primary === 'number') {
      return primary;
    }
    if (typeof legacy === 'number') {
      return legacy;
    }
    return fallback;
  }

  private static clamp(value: number, minimum: number, maximum: number): number {
    return Math.max(minimum, Math.min(maximum, value));
  }

  private static validTarget(value: number): boolean {
    return typeof value === 'number' && Number.isInteger(value) && value > 0 && value <= 1000000000;
  }

  private static isSceneMode(value: SceneMode): boolean {
    return value === SceneMode.PROGRAMMER || value === SceneMode.MINDFUL || value === SceneMode.DAILY;
  }

  private static isToolType(value: ToolType): boolean {
    return value === ToolType.WOODEN_FISH || value === ToolType.BEADS || value === ToolType.INCENSE;
  }

  private static isThemeMode(value: ThemeMode): boolean {
    return value === ThemeMode.SYSTEM || value === ThemeMode.LIGHT || value === ThemeMode.DARK;
  }

  private static isSoundType(value: SoundType): boolean {
    return value === SoundType.DEEP || value === SoundType.CRISP || value === SoundType.SOFT;
  }
}
