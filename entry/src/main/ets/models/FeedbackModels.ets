export class HitFeedbackPlan {
  playSound: boolean = false;
  vibrate: boolean = false;
  floatingText: string = '';

  static create(soundEnabled: boolean, vibrationEnabled: boolean,
    floatingTextEnabled: boolean, text: string): HitFeedbackPlan {
    const plan: HitFeedbackPlan = new HitFeedbackPlan();
    plan.playSound = soundEnabled;
    plan.vibrate = vibrationEnabled;
    plan.floatingText = floatingTextEnabled ? text : '';
    return plan;
  }
}
