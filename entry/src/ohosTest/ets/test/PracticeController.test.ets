import { describe, expect, it } from '@ohos/hypium';
import { PracticeStatus, ToolType } from '../../../main/ets/models/Enums';
import { IncenseTimer } from '../../../main/ets/services/IncenseTimer';
import { PracticeController } from '../../../main/ets/services/PracticeController';

export default function practiceControllerTest(): void {
  describe('PracticeController', (): void => {
    it('allowsOnlyOneAutomaticTimer', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      controller.selectTool(ToolType.WOODEN_FISH);
      expect(controller.startAuto(1000, 60)).assertTrue();
      expect(controller.startAuto(1000, 60)).assertFalse();
      expect(controller.hasActiveTimer()).assertTrue();
      controller.stop();
      expect(controller.hasActiveTimer()).assertFalse();
    });

    it('pausesResumesAndStopsAutoOnBackground', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      controller.selectTool(ToolType.BEADS);
      controller.startAuto(2000, 0);
      controller.pause();
      expect(controller.state.status).assertEqual(PracticeStatus.PAUSED);
      expect(controller.hasActiveTimer()).assertFalse();
      controller.resume();
      expect(controller.state.status).assertEqual(PracticeStatus.RUNNING);
      expect(controller.hasActiveTimer()).assertTrue();
      controller.onBackground();
      expect(controller.state.status).assertEqual(PracticeStatus.IDLE);
      expect(controller.hasActiveTimer()).assertFalse();
    });

    it('countsOnlyCountableTools', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      controller.selectTool(ToolType.WOODEN_FISH);
      expect(controller.recordManual()).assertTrue();
      expect(controller.state.manualCount).assertEqual(1);
      controller.selectTool(ToolType.INCENSE);
      expect(controller.recordManual()).assertFalse();
      expect(controller.state.manualCount).assertEqual(0);
    });

    it('usesWallClockForIncensePauseAndSingleCompletion', 0, (): void => {
      const timer: IncenseTimer = new IncenseTimer();
      timer.start(1000, 300);
      expect(timer.remainingAt(61000)).assertEqual(240);
      timer.pause(61000);
      expect(timer.remainingAt(121000)).assertEqual(240);
      timer.resume(121000);
      expect(timer.remainingAt(181000)).assertEqual(180);
      expect(timer.consumeCompletion(361000)).assertTrue();
      expect(timer.consumeCompletion(361000)).assertFalse();
      expect(timer.status).assertEqual(PracticeStatus.COMPLETED);
    });
  });
}
