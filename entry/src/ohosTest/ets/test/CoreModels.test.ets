import { describe, expect, it } from '@ohos/hypium';
import { JsonCodec } from '../../../main/ets/data/JsonCodec';
import { LayoutSize, ResponsiveLayout } from '../../../main/ets/utils/ResponsiveLayout';
import { TextValidator } from '../../../main/ets/utils/TextValidator';
import { SceneMode, ThemeMode, ToolType } from '../../../main/ets/models/Enums';
import { ThemeResolver } from '../../../main/ets/utils/ThemeResolver';
import { PracticeLayout } from '../../../main/ets/utils/PracticeLayout';
import { DesignTokens } from '../../../main/ets/constants/DesignTokens';
import { ThemePalette } from '../../../main/ets/constants/ThemePalette';

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

    it('usesCompactPhonePracticeMetrics', 0, (): void => {
      const phone = PracticeLayout.resolve(390);
      expect(phone.compact).assertTrue();
      expect(phone.minimumTouchTarget).assertLargerOrEqual(48);
      expect(phone.canvasHeight).assertEqual(150);
      expect(phone.pageSpacing).assertEqual(10);
      expect(phone.consoleSliderMinWidth).assertLargerOrEqual(64);
      expect(phone.messageInControlDock).assertTrue();
      const wide = PracticeLayout.resolve(600);
      expect(wide.compact).assertFalse();
      expect(wide.messageInControlDock).assertFalse();
      expect(wide.canvasHeight).assertEqual(330);
    });

    it('trimsAndLimitsCustomTextToTwelveCharacters', 0, (): void => {
      expect(TextValidator.normalize('  保持专注  ')).assertEqual('保持专注');
      expect(TextValidator.normalize('一二三四五六七八九十十一十二十三')).assertEqual('一二三四五六七八九十十一');
      expect(TextValidator.isValid('   ')).assertFalse();
      expect(TextValidator.validationMessage('   ')).assertEqual('请输入至少 1 个有效字符');
      expect(TextValidator.validationMessage('保持专注')).assertEqual('');
    });

    it('resolvesExplicitAndSystemThemeModes', 0, (): void => {
      expect(ThemeResolver.isDark(ThemeMode.DARK, false)).assertTrue();
      expect(ThemeResolver.isDark(ThemeMode.LIGHT, true)).assertFalse();
      expect(ThemeResolver.isDark(ThemeMode.SYSTEM, true)).assertTrue();
      expect(ThemeResolver.isDark(ThemeMode.SYSTEM, false)).assertFalse();
    });

    it('resolvesApprovedIvoryAndBlackGoldPalettes', 0, (): void => {
      expect(ThemePalette.resolve(false).page).assertEqual('#F8F5EF');
      expect(ThemePalette.resolve(false).primary).assertEqual('#44352B');
      expect(ThemePalette.resolve(true).page).assertEqual('#0D0E0D');
      expect(ThemePalette.resolve(true).accent).assertEqual('#CE914A');
    });

    it('usesDiscreteReferenceLayoutMetrics', 0, (): void => {
      expect(DesignTokens.pageInset(390)).assertEqual(20);
      expect(DesignTokens.pageInset(800)).assertEqual(24);
      expect(DesignTokens.titleSize(390)).assertEqual(32);
      expect(DesignTokens.titleSize(1100)).assertEqual(34);
    });

    it('usesStableReferenceComponentHeights', 0, (): void => {
      expect(DesignTokens.summaryHeight(390)).assertEqual(76);
      expect(DesignTokens.toolBarHeight(390)).assertEqual(52);
      expect(DesignTokens.bottomNavHeight(390)).assertEqual(76);
    });
  });
}
