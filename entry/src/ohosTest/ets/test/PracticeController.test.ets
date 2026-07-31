import { describe, expect, it } from '@ohos/hypium';
import { PracticeStatus, ToolType } from '../../../main/ets/models/Enums';
import { PracticeEvent } from '../../../main/ets/models/PracticeModels';
import { IncenseTimer } from '../../../main/ets/services/IncenseTimer';
import { PracticeController } from '../../../main/ets/services/PracticeController';

type DoneCallback = () => void;

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

    it('keepsEveryRapidManualHitAndEmitsTypedEvents', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      const events: PracticeEvent[] = [];
      controller.setEventCallback((event: PracticeEvent): void => {
        events.push(event);
      });
      controller.selectTool(ToolType.WOODEN_FISH);

      for (let index: number = 0; index < 100; index++) {
        controller.recordManual();
      }

      expect(controller.state.manualCount).assertEqual(100);
      expect(controller.state.hitSequence).assertEqual(100);
      expect(events.length).assertEqual(100);
      expect(events[0].automatic).assertFalse();
      expect(events[99].hitSequence).assertEqual(100);
    });

    it('sharesOneIncreasingSequenceForManualAndAutomaticHits', 0, (done: DoneCallback): void => {
      const controller: PracticeController = new PracticeController();
      const events: PracticeEvent[] = [];
      controller.setEventCallback((event: PracticeEvent): void => {
        events.push(event);
        if (events.length === 2) {
          controller.stop();
          expect(events[0].automatic).assertFalse();
          expect(events[0].hitSequence).assertEqual(1);
          expect(events[1].automatic).assertTrue();
          expect(events[1].hitSequence).assertEqual(2);
          done();
        }
      });
      controller.selectTool(ToolType.WOODEN_FISH);
      controller.recordManual();
      controller.startAuto(500, 1);
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
