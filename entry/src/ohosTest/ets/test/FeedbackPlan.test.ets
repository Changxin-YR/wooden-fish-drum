import { describe, expect, it } from '@ohos/hypium';
import { HitFeedbackPlan } from '../../../main/ets/models/FeedbackModels';

export default function feedbackPlanTest(): void {
  describe('HitFeedbackPlan', (): void => {
    it('createsExactlyOnePlanForEveryHit', 0, (): void => {
      const plan: HitFeedbackPlan = HitFeedbackPlan.create(true, true, true, '功德+1');
      expect(plan.playSound).assertTrue();
      expect(plan.vibrate).assertTrue();
      expect(plan.floatingText).assertEqual('功德+1');
    });
  });
}
