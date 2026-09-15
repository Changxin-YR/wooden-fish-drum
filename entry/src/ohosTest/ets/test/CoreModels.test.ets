import { describe, expect, it } from '@ohos/hypium';
import { JsonCodec } from '../../../main/ets/data/JsonCodec';
import { DesignTokens } from '../../../main/ets/constants/DesignTokens';
import { TextValidator } from '../../../main/ets/utils/TextValidator';
import { ThemeMode, UserMode } from '../../../main/ets/models/Enums';
import { ThemeResolver } from '../../../main/ets/utils/ThemeResolver';
import { InitializationSlot } from '../../../main/ets/services/InitializationSlot';

export default function coreModelsTest(): void {
  describe('CoreModels', (): void => {
    it('usesOneReadyGeneralUserDefault', 0, (): void => {
      expect(JsonCodec.createDefaultSettings().initialized).assertTrue();
      expect(JsonCodec.createDefaultSettings().userMode).assertEqual(UserMode.GENERAL);
      expect(JsonCodec.createDefaultSettings().currentText).assertEqual('功德+1');
      expect(JsonCodec.createDefaultSettings().themeMode).assertEqual(ThemeMode.SYSTEM);
    });

    it('usesDocumentedResponsiveBreakpoints', 0, (): void => {
      expect(DesignTokens.compactMax).assertEqual(599);
      expect(DesignTokens.mediumMax).assertEqual(1023);
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

    it('discardsStaleResourcesAndReturnsCurrentResourceOnCancel', 0, (): void => {
      const slot: InitializationSlot<string> = new InitializationSlot<string>();
      const first: number = slot.begin();
      const second: number = slot.begin();

      expect(slot.publish(first, 'stale')).assertEqual('stale');
      expect(slot.current()).assertNull();
      expect(slot.publish(second, 'active')).assertNull();
      expect(slot.current()).assertEqual('active');

      expect(slot.cancel()).assertEqual('active');
      expect(slot.current()).assertNull();
    });
  });
}
