import { describe, expect, it } from '@ohos/hypium';
import { JsonCodec } from '../../../main/ets/data/JsonCodec';
import { AppSettings } from '../../../main/ets/models/AppModels';
import { SceneMode, SoundType, ThemeMode, ToolType } from '../../../main/ets/models/Enums';

export default function migrationTest(): void {
  describe('Migration', (): void => {
    it('createsV2DefaultsThatRequireOnboarding', 0, (): void => {
      const settings: AppSettings = JsonCodec.createDefaultSettings();
      expect(settings.schemaVersion).assertEqual(2);
      expect(settings.initialized).assertFalse();
      expect(settings.selectedSceneMode).assertEqual(SceneMode.DAILY);
      expect(settings.selectedTool).assertEqual(ToolType.WOODEN_FISH);
      expect(settings.feedbackText).assertEqual('放松+1');
    });

    it('migratesLegacyGeneralSettingsWithoutReplayingOnboarding', 0, (): void => {
      const legacy: string = JSON.stringify({
        initialized: true,
        userMode: 'general',
        themeMode: 'dark',
        currentText: '保持专注',
        soundEnabled: true,
        soundType: 'deep',
        volume: 0.35,
        vibrationEnabled: false,
        floatingTextEnabled: false,
        autoInterval: 1500
      });
      const settings: AppSettings = JsonCodec.decodeSettings(legacy);
      expect(settings.schemaVersion).assertEqual(2);
      expect(settings.initialized).assertTrue();
      expect(settings.selectedSceneMode).assertEqual(SceneMode.DAILY);
      expect(settings.selectedTool).assertEqual(ToolType.WOODEN_FISH);
      expect(settings.themeMode).assertEqual(ThemeMode.DARK);
      expect(settings.feedbackText).assertEqual('保持专注');
      expect(settings.selectedSoundId).assertEqual(SoundType.DEEP);
      expect(settings.tapVolume).assertEqual(0.35);
      expect(settings.vibrationEnabled).assertFalse();
      expect(settings.feedbackTextEnabled).assertFalse();
      expect(settings.autoIntervalMs).assertEqual(1500);
    });

    it('keepsV2MigrationIdempotent', 0, (): void => {
      const migrated: AppSettings = JsonCodec.decodeSettings(JSON.stringify({
        initialized: true,
        userMode: 'programmer',
        themeMode: 'light',
        currentText: '专注+1',
        soundType: 'crisp'
      }));
      const first: string = JsonCodec.encodeSettings(migrated);
      const second: string = JsonCodec.encodeSettings(JsonCodec.decodeSettings(first));
      expect(second).assertEqual(first);
      expect(migrated.selectedSceneMode).assertEqual(SceneMode.PROGRAMMER);
    });

    it('persistsCompatibilityFieldChangesDuringPageMigration', 0, (): void => {
      const settings: AppSettings = JsonCodec.createDefaultSettings();
      settings.currentText = '休息一下';
      settings.soundType = SoundType.CRISP;
      settings.volume = 0.2;
      settings.floatingTextEnabled = false;
      settings.autoInterval = 2000;
      const restored: AppSettings = JsonCodec.decodeSettings(JsonCodec.encodeSettings(settings));
      expect(restored.feedbackText).assertEqual('休息一下');
      expect(restored.selectedSoundId).assertEqual(SoundType.CRISP);
      expect(restored.tapVolume).assertEqual(0.2);
      expect(restored.feedbackTextEnabled).assertFalse();
      expect(restored.autoIntervalMs).assertEqual(2000);
    });

    it('usesSafeUninitializedDefaultsForBrokenJson', 0, (): void => {
      const settings: AppSettings = JsonCodec.decodeSettings('{broken');
      expect(settings.schemaVersion).assertEqual(2);
      expect(settings.initialized).assertFalse();
      expect(settings.selectedSceneMode).assertEqual(SceneMode.DAILY);
    });
  });
}
