export class PracticeLayoutMetrics {
  compact: boolean;
  minimumTouchTarget: number;
  pageSpacing: number;
  canvasHeight: number;
  consoleSliderMinWidth: number;
  messageInControlDock: boolean;

  constructor(compact: boolean, pageSpacing: number, canvasHeight: number) {
    this.compact = compact;
    this.minimumTouchTarget = 48;
    this.pageSpacing = pageSpacing;
    this.canvasHeight = canvasHeight;
    this.consoleSliderMinWidth = compact ? 64 : 96;
    this.messageInControlDock = compact;
  }
}

export class PracticeLayout {
  static resolve(width: number): PracticeLayoutMetrics {
    if (width < 600) {
      return new PracticeLayoutMetrics(true, 4, 150);
    }
    return new PracticeLayoutMetrics(false, 18, 330);
  }
}
