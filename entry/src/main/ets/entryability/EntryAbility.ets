import { Configuration, ConfigurationConstant, UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { AppTab } from '../models/Enums';
import { audioService } from '../services/AudioService';
import { ArkUiWindowChromeTarget, windowChromeService } from '../services/WindowChromeService';
import { sessionService } from '../stores/AppRuntime';

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
    const systemDark: boolean =
      this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    windowStage.getMainWindow().then((mainWindow: window.Window): void => {
      const target: ArkUiWindowChromeTarget = new ArkUiWindowChromeTarget(mainWindow);
      windowChromeService.bind(target, AppTab.HOME, systemDark).then((): void => {
        this.loadContent(windowStage);
      });
    }).catch((): void => {
      this.loadContent(windowStage);
    });
  }

  private loadContent(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index').then((): void => {
      windowChromeService.refresh();
    }).catch((): void => {
    });
  }

  onBackground(): void {
    sessionService.onBackground();
    audioService.release();
  }
}
