import { PracticeStatus } from '../models/Enums';
import { ThemeColors, ThemePalette } from '../constants/ThemePalette';

@Component
export struct IncenseView {
  @Prop targetSeconds: number = 0;
  @Prop remainingSeconds: number = 0;
  @Prop status: PracticeStatus = PracticeStatus.IDLE;
  @Prop dark: boolean = false;
  @Prop reducedMotion: boolean = false;
  @Prop compact: boolean = false;
  @Prop canvasHeight: number = 330;

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

  private visualHeight(): number {
    return this.compact ? this.canvasHeight - 10 : 286;
  }

  private progressValue(): number {
    if (this.targetSeconds <= 0) {
      return 0;
    }
    return Math.max(0, Math.min(1, 1 - this.remainingSeconds / this.targetSeconds));
  }

  private timeText(): string {
    const seconds: number = Math.max(0, this.remainingSeconds);
    const minutes: number = Math.floor(seconds / 60);
    const remainder: number = seconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${remainder.toString().padStart(2, '0')}`;
  }

  build() {
    Column({ space: this.compact ? 6 : 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.practice_incense'))
          .width('100%')
          .height(this.visualHeight())
          .objectFit(ImageFit.Contain)
          .opacity(this.status === PracticeStatus.COMPLETED ? 0.72 : 1)
          .scale({
            x: this.reducedMotion || this.status !== PracticeStatus.RUNNING ? 1 : 1.008,
            y: this.reducedMotion || this.status !== PracticeStatus.RUNNING ? 1 : 1.008
          })
        if (this.status === PracticeStatus.COMPLETED) {
          Text('本次静心已完成')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors().primary)
            .padding({ left: 18, right: 18, top: 10, bottom: 10 })
            .backgroundColor(this.colors().card)
            .borderRadius(22)
        }
      }
      .width('100%')
      .height(this.visualHeight())
      .accessibilityText('一炷香静心计时画布')
      .accessibilityDescription('点击香体不会增加次数')

      if (this.targetSeconds > 0) {
        Progress({ value: this.progressValue() * 100, total: 100, type: ProgressType.Linear })
          .width('86%')
          .height(8)
          .color(this.colors().accent)
          .backgroundColor(this.colors().divider)
        if (!this.compact) {
          Text(this.timeText())
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors().primary)
        }
      }
    }
    .width('100%')
  }
}
