export class FeedbackText {
  static normalize(value: string): string {
    return value.trim();
  }

  static label(value: string): string {
    const normalized: string = FeedbackText.normalize(value);
    const label: string = normalized.replace(/[+＋]\s*\d+\s*$/, '').trim();
    return label.length > 0 ? label : '功德';
  }

  static todayTitle(value: string): string {
    return `今日${FeedbackText.label(value)}`;
  }

  static isValid(value: string): boolean {
    const normalized: string = FeedbackText.normalize(value);
    return normalized.length > 0 && normalized.length <= 20;
  }
}
