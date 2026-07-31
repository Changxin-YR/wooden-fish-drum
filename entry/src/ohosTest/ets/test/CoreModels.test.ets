import { describe, expect, it } from '@ohos/hypium';
import { JsonCodec } from '../../../main/ets/data/JsonCodec';
import { LayoutSize, ResponsiveLayout } from '../../../main/ets/utils/ResponsiveLayout';
import { TextValidator } from '../../../main/ets/utils/TextValidator';
import { SceneMode, ThemeMode, ToolType } from '../../../main/ets/models/Enums';
import { ThemeResolver } from '../../../main/ets/utils/ThemeResolver';

export default function coreModelsTest(): void {
  describe('CoreModels', (): void => {
    it('usesUninitializedDailySceneDefaults', 0, (): void => {
      expect(JsonCodec.createDefaultSettings().initialized).assertFalse();
      expect(JsonCodec.createDefaultSettings().selectedSceneMode).assertEqual(SceneMode.DAILY);
      expect(JsonCodec.createDefaultSettings().selectedTool).assertEqual(ToolType.WOODEN_FISH);
      expect(JsonCodec.createDefaultSettings().feedbackText).assertEqual('放松+1');
      expect(JsonCodec.createDefaultSettings().themeMode).assertEqual(ThemeMode.SYSTEM);
    });

    it('usesDocumentedResponsiveBreakpoints', 0, (): void => {
      expect(ResponsiveLayout.resolve(599)).assertEqual(LayoutSize.COMPACT);
      expect(ResponsiveLayout.resolve(600)).assertEqual(LayoutSize.MEDIUM);
      expect(ResponsiveLayout.resolve(1024)).assertEqual(LayoutSize.EXPANDED);
    });

    it('trimsAndLimitsCustomTextToTwelveCharacters', 0, (): void => {
      expect(TextValidator.normalize('  保持专注  ')).assertEqual('保持专注');
      expect(TextValidator.normalize('一二三四五六七八九十十一十二十三')).assertEqual('一二三四五六七八九十十一');
      expect(TextValidator.isValid('   ')).assertFalse();
    });

    it('resolvesExplicitAndSystemThemeModes', 0, (): void => {
      expect(ThemeResolver.isDark(ThemeMode.DARK, false)).assertTrue();
      expect(ThemeResolver.isDark(ThemeMode.LIGHT, true)).assertFalse();
      expect(ThemeResolver.isDark(ThemeMode.SYSTEM, true)).assertTrue();
      expect(ThemeResolver.isDark(ThemeMode.SYSTEM, false)).assertFalse();
    });
  });
}
