import { Configuration, ConfigurationConstant, UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { audioService } from '../services/AudioService';
import { practiceController } from '../stores/AppRuntime';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    AppStorage.setOrCreate('systemDark',
      this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    AppStorage.setOrCreate('systemDark',
      newConfig.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index').catch((): void => {
    });
  }

  onBackground(): void {
    practiceController.onBackground();
    audioService.release();
  }
}
