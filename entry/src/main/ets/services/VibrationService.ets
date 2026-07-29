import vibrator from '@ohos.vibrator';

export class VibrationService {
  async impact(duration: number = 35): Promise<boolean> {
    try {
      await vibrator.startVibration(
        { type: 'time', duration: Math.max(10, Math.min(100, duration)) },
        { usage: 'physicalFeedback' }
      );
      return true;
    } catch {
      return false;
    }
  }
}

export const vibrationService: VibrationService = new VibrationService();
