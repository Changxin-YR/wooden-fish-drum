import { describe, expect, it } from '@ohos/hypium';
import { PracticeStatus, ToolType } from '../../../main/ets/models/Enums';
import { IncenseSnapshot, PracticeEvent, PracticeSessionDraft } from '../../../main/ets/models/PracticeModels';
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

    it('distinguishesManualSessionsFromAutomaticRhythm', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      controller.recordManual();
      expect(controller.state.automaticActive).assertFalse();
      controller.startAuto(1000, 0);
      expect(controller.state.automaticActive).assertTrue();
      controller.pause();
      expect(controller.state.automaticActive).assertTrue();
      controller.stop();
      expect(controller.state.automaticActive).assertFalse();
    });

    it('completesTargetWithoutCountingExtraHitsAndRestartsOnlyTheRound', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      controller.selectTool(ToolType.WOODEN_FISH);
      expect(controller.configureTarget(3)).assertTrue();
      controller.startTarget();

      expect(controller.recordManual()).assertTrue();
      expect(controller.recordManual()).assertTrue();
      expect(controller.recordManual()).assertTrue();
      expect(controller.state.targetCompleted).assertTrue();
      expect(controller.state.sessionCount).assertEqual(3);
      expect(controller.recordManual()).assertFalse();
      expect(controller.state.sessionCount).assertEqual(3);

      controller.restartTarget();
      expect(controller.state.targetCompleted).assertFalse();
      expect(controller.state.sessionCount).assertEqual(0);
      expect(controller.state.manualCount).assertEqual(3);
    });

    it('rejectsInvalidTargetCounts', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      expect(controller.configureTarget(0)).assertFalse();
      expect(controller.configureTarget(-1)).assertFalse();
      expect(controller.configureTarget(1000000001)).assertFalse();
      expect(controller.state.targetCount).assertEqual(108);
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

    it('countsEachBeadsGestureOnlyOnce', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      controller.selectTool(ToolType.BEADS);

      expect(controller.recordBeadsGesture(101)).assertTrue();
      expect(controller.recordBeadsGesture(101)).assertFalse();
      expect(controller.recordBeadsGesture(102)).assertTrue();
      expect(controller.state.manualCount).assertEqual(2);
    });

    it('emitsEachBeadsMilestoneOnlyAtItsNode', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      const milestones: number[] = [];
      controller.setEventCallback((event: PracticeEvent): void => {
        if (event.milestone > 0) {
          milestones.push(event.milestone);
        }
      });
      controller.selectTool(ToolType.BEADS);

      for (let gestureId: number = 1; gestureId <= 109; gestureId++) {
        controller.recordBeadsGesture(gestureId);
      }

      expect(milestones.length).assertEqual(3);
      expect(milestones[0]).assertEqual(27);
      expect(milestones[1]).assertEqual(54);
      expect(milestones[2]).assertEqual(108);
      expect(controller.state.manualCount).assertEqual(109);
    });

    it('stopsAutoAndSubmitsBeadsSessionWhenSwitchingTool', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      const drafts: PracticeSessionDraft[] = [];
      controller.setSessionCallback((draft: PracticeSessionDraft): void => {
        drafts.push(draft);
      });
      controller.selectTool(ToolType.BEADS);
      controller.recordBeadsGesture(1);
      controller.startAuto(1000, 0);
      expect(controller.hasActiveTimer()).assertTrue();

      controller.selectTool(ToolType.WOODEN_FISH);

      expect(controller.hasActiveTimer()).assertFalse();
      expect(drafts.length).assertEqual(1);
      expect(drafts[0].toolType).assertEqual(ToolType.BEADS);
      expect(drafts[0].manualCount).assertEqual(1);
    });

    it('startsEverySupportedIncensePreset', 0, (): void => {
      const presets: number[] = [300, 600, 900, 1200, 1800];
      presets.forEach((durationSeconds: number): void => {
        const controller: PracticeController = new PracticeController();
        controller.selectTool(ToolType.INCENSE);
        expect(controller.startIncense(durationSeconds, 1000)).assertTrue();
        expect(controller.state.incenseTargetSeconds).assertEqual(durationSeconds);
        expect(controller.state.incenseRemainingSeconds).assertEqual(durationSeconds);
      });
    });

    it('pausesAndResumesIncenseUsingWallClock', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      controller.selectTool(ToolType.INCENSE);
      controller.startIncense(300, 1000);
      controller.refreshIncense(61000);
      expect(controller.state.incenseRemainingSeconds).assertEqual(240);
      controller.pauseIncense(61000);
      controller.refreshIncense(121000);
      expect(controller.state.incenseRemainingSeconds).assertEqual(240);
      controller.resumeIncense(121000);
      controller.refreshIncense(181000);
      expect(controller.state.incenseRemainingSeconds).assertEqual(180);
    });

    it('submitsCompletedIncenseOnlyOnceAcrossRepeatedRefresh', 0, (): void => {
      const controller: PracticeController = new PracticeController();
      const drafts: PracticeSessionDraft[] = [];
      controller.setSessionCallback((draft: PracticeSessionDraft): void => {
        drafts.push(draft);
      });
      controller.selectTool(ToolType.INCENSE);
      controller.startIncense(300, 1000);

      controller.refreshIncense(301000);
      controller.refreshIncense(302000);

      expect(drafts.length).assertEqual(1);
      expect(drafts[0].toolType).assertEqual(ToolType.INCENSE);
      expect(drafts[0].durationSeconds).assertEqual(300);
      expect(controller.state.status).assertEqual(PracticeStatus.COMPLETED);
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

    it('restoresIncenseSnapshotWithAccurateWallClockState', 0, (): void => {
      const source: IncenseTimer = new IncenseTimer();
      source.start(1000, 300);
      source.pause(61000);
      const snapshot: IncenseSnapshot = source.snapshot();
      const restored: IncenseTimer = new IncenseTimer();

      expect(restored.restore(snapshot)).assertTrue();
      expect(restored.remainingAt(121000)).assertEqual(240);
      expect(restored.resume(121000)).assertTrue();
      expect(restored.remainingAt(181000)).assertEqual(180);
    });
  });
}
