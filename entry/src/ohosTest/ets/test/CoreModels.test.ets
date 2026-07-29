import { describe, expect, it } from '@ohos/hypium';
import { USER_MODE_CONFIGS } from '../../../main/ets/constants/UserModeConfigs';
import { LayoutSize, ResponsiveLayout } from '../../../main/ets/utils/ResponsiveLayout';
import { TextValidator } from '../../../main/ets/utils/TextValidator';
import { UserMode } from '../../../main/ets/models/Enums';

export default function coreModelsTest(): void {
  describe('CoreModels', (): void => {
    it('providesThreeDistinctUserModeDefaults', 0, (): void => {
      expect(USER_MODE_CONFIGS[UserMode.PROGRAMMER].defaultText).assertEqual('Bug-1');
      expect(USER_MODE_CONFIGS[UserMode.MONK].defaultText).assertEqual('功德+1');
      expect(USER_MODE_CONFIGS[UserMode.GENERAL].defaultText).assertEqual('好运+1');
    });

    it('usesDocumentedResponsiveBreakpoints', 0, (): void => {
      expect(ResponsiveLayout.resolve(599)).assertEqual(LayoutSize.COMPACT);
      expect(ResponsiveLayout.resolve(600)).assertEqual(LayoutSize.MEDIUM);
      expect(ResponsiveLayout.resolve(1024)).assertEqual(LayoutSize.EXPANDED);
    });

    it('trimsAndLimitsCustomTextToTwelveCharacters', 0, (): void => {
      expect(TextValidator.normalize('  保持专注  ')).assertEqual('保持专注');
      expect(TextValidator.normalize('一二三四五六七八九十十一十二十三')).assertEqual('一二三四五六七八九十十一十二');
      expect(TextValidator.isValid('   ')).assertFalse();
    });
  });
}
