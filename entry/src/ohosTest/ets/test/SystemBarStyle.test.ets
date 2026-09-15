import { describe, expect, it } from '@ohos/hypium';
import { window } from '@kit.ArkUI';
import { DesignTokens } from '../../../main/ets/constants/DesignTokens';
import { AppTab } from '../../../main/ets/models/Enums';
import { SystemBarStyle } from '../../../main/ets/models/SystemBarModels';
import { WindowChromeService, WindowChromeTarget } from '../../../main/ets/services/WindowChromeService';
import { SystemBarStyleResolver } from '../../../main/ets/utils/SystemBarStyleResolver';

class RecordingWindow extends WindowChromeTarget {
  systemBarWriteCount: number = 0;
  windowBackgroundColor: string = '';

  constructor() {
    super();
  }

  async setWindowLayoutFullScreen(_isLayoutFullScreen: boolean): Promise<void> {
  }

  async setWindowSystemBarProperties(_properties: window.SystemBarProperties): Promise<void> {
    this.systemBarWriteCount += 1;
  }

  setWindowBackgroundColor(color: string): void {
    this.windowBackgroundColor = color;
  }
}

export default function systemBarStyleTest(): void {
  describe('SystemBarStyle', (): void => {
    it('matchesLightHomeAndBottomNavigationSurfaces', 0, (): void => {
      const style: SystemBarStyle = SystemBarStyleResolver.resolve(AppTab.HOME, false);

      expect(style.statusBarColor).assertEqual(DesignTokens.homeLightBackground);
      expect(style.navigationBarColor).assertEqual(DesignTokens.lightCard);
      expect(style.statusBarContentColor).assertEqual('#000000');
      expect(style.navigationBarContentColor).assertEqual('#000000');
      expect(style.isStatusBarLightIcon).assertFalse();
      expect(style.isNavigationBarLightIcon).assertFalse();
    });

    it('matchesLightSecondaryPageAndBottomNavigationSurfaces', 0, (): void => {
      const style: SystemBarStyle = SystemBarStyleResolver.resolve(AppTab.SETTINGS, false);

      expect(style.statusBarColor).assertEqual(DesignTokens.lightBackground);
      expect(style.navigationBarColor).assertEqual(DesignTokens.lightCard);
    });

    it('matchesDarkPageAndBottomNavigationSurfaces', 0, (): void => {
      const style: SystemBarStyle = SystemBarStyleResolver.resolve(AppTab.STATS, true);

      expect(style.statusBarColor).assertEqual(DesignTokens.darkBackground);
      expect(style.navigationBarColor).assertEqual(DesignTokens.darkCard);
      expect(style.statusBarContentColor).assertEqual('#FFFFFF');
      expect(style.navigationBarContentColor).assertEqual('#FFFFFF');
      expect(style.isStatusBarLightIcon).assertTrue();
      expect(style.isNavigationBarLightIcon).assertTrue();
    });

    it('reappliesStyleAfterPageContentLoads', 0, async (): Promise<void> => {
      const target: RecordingWindow = new RecordingWindow();
      const service: WindowChromeService = new WindowChromeService();

      await service.bind(target, AppTab.HOME, false);
      await service.refresh();

      expect(target.systemBarWriteCount).assertEqual(2);
    });

    it('usesNavigationSurfaceAsWindowBackground', 0, async (): Promise<void> => {
      const target: RecordingWindow = new RecordingWindow();
      const service: WindowChromeService = new WindowChromeService();

      await service.bind(target, AppTab.HOME, true);

      expect(target.windowBackgroundColor).assertEqual(DesignTokens.darkCard);
    });
  });
}
