import { PracticeStatus } from '../models/Enums';

@Component
export struct IncenseView {
  @Prop targetSeconds: number = 0;
  @Prop remainingSeconds: number = 0;
  @Prop status: PracticeStatus = PracticeStatus.IDLE;
  @Prop dark: boolean = false;
  @Prop reducedMotion: boolean = false;

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
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.practice_incense'))
          .width('100%')
          .height(286)
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
            .fontColor(this.dark ? '#F1D0AD' : '#6D4428')
            .padding({ left: 18, right: 18, top: 10, bottom: 10 })
            .backgroundColor(this.dark ? '#E62A2724' : '#F2FFFDF8')
            .borderRadius(22)
        }
      }
      .width('100%')
      .height(286)
      .accessibilityText('一炷香静心计时画布')
      .accessibilityDescription('点击香体不会增加次数')

      if (this.targetSeconds > 0) {
        Progress({ value: this.progressValue() * 100, total: 100, type: ProgressType.Linear })
          .width('86%')
          .height(8)
          .color('#A66C39')
          .backgroundColor(this.dark ? '#4A433D' : '#EDE3D7')
        Text(this.timeText())
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.dark ? '#F1ECE4' : '#56371F')
      }
    }
    .width('100%')
  }
}
