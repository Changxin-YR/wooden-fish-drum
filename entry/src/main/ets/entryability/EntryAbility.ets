import { Configuration, ConfigurationConstant, UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { audioService } from '../services/AudioService';
import { practiceController } from '../stores/AppRuntime';
import { WindowAppearanceService } from '../services/WindowAppearanceService';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    AppStorage.setOrCreate('topSafeAreaPx', 0);
    AppStorage.setOrCreate('bottomSafeAreaPx', 0);
    AppStorage.setOrCreate('statsPeriod', 'today');
    AppStorage.setOrCreate('systemDark',
      this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    AppStorage.setOrCreate('systemDark',
      newConfig.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    WindowAppearanceService.initialize(windowStage,
      this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
      .catch((): void => {})
      .finally((): void => {
        windowStage.loadContent('pages/Index').catch((): void => {});
      });
  }

  onWindowStageDestroy(): void {
    WindowAppearanceService.release();
  }

  onBackground(): void {
    practiceController.onBackground();
    audioService.release();
  }
}
