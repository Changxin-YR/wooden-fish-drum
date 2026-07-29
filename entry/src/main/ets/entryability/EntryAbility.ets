import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { audioService } from '../services/AudioService';
import { sessionService } from '../stores/AppRuntime';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index').catch((): void => {
    });
  }

  onBackground(): void {
    sessionService.onBackground();
    audioService.release();
  }
}
