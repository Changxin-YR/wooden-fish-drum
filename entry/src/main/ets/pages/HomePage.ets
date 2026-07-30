import { WoodenFishView } from '../components/WoodenFishView';
import { AppSettings, SessionState, StatsSummary } from '../models/AppModels';
import { SessionMode } from '../models/Enums';

@Component
export struct HomePage {
  @Prop settings: AppSettings;
  @Prop summary: StatsSummary;
  @Prop session: SessionState;
  @Prop dark: boolean;
  onHit: () => void = (): void => {};
  onSessionChange: (mode: SessionMode) => void = (): void => {};
  private isDark(): boolean {
    return this.dark;
  }

  private pageBackground(): string {
    return this.isDark() ? '#171513' : '#F6F1E8';
  }

  private card(): string {
    return this.isDark() ? '#24211E' : '#FFFDF8';
  }

  private primaryText(): string {
    return this.isDark() ? '#F1ECE4' : '#2E2924';
  }

  private secondaryText(): string {
    return this.isDark() ? '#AAA198' : '#817970';
  }

  @Builder
  Metric(value: () => string, label: string) {
    Column({ space: 4 }) {
      Text(value())
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text(label)
        .fontSize(12)
        .fontColor(this.secondaryText())
    }
    .layoutWeight(1)
  }

  @Builder
  SessionTab(mode: SessionMode, label: string) {
    Text(label)
      .layoutWeight(1)
      .height(48)
      .textAlign(TextAlign.Center)
      .fontSize(15)
      .fontColor(this.session.mode === mode ? '#FFFFFF' : this.secondaryText())
      .backgroundColor(this.session.mode === mode ? '#9A612C' : Color.Transparent)
      .borderRadius(24)
      .onClick((): void => {
        this.onSessionChange(mode);
      })
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text(`今日功德  ${this.summary.todayCount.toLocaleString()}`)
          .width('100%')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.primaryText())
          .textAlign(TextAlign.End)
        .width('100%')

        WoodenFishView({
          dark: this.isDark(),
          hitSequence: this.session.hitSequence,
          label: this.settings.currentText,
          floatingEnabled: this.settings.floatingTextEnabled,
          onHit: (): void => this.onHit()
        })

        Row() {
          this.Metric((): string => this.summary.totalCount.toLocaleString(), '累计功德')
          Divider().vertical(true).height(38).color(this.secondaryText())
          this.Metric((): string => `${this.summary.streakDays}`, '连续天数')
          Divider().vertical(true).height(38).color(this.secondaryText())
          this.Metric((): string => `${this.summary.maxDailyCount}`, '最大单日')
        }
        .width('100%')
        .padding({ top: 16, bottom: 16 })
        .backgroundColor(this.card())
        .borderRadius(18)

        Row({ space: 4 }) {
          this.SessionTab(SessionMode.FREE, '自由')
          this.SessionTab(SessionMode.TARGET, '目标')
          this.SessionTab(SessionMode.AUTO, '自动')
        }
        .width('100%')
        .padding(4)
        .backgroundColor(this.card())
        .borderRadius(28)

        if (this.session.mode === SessionMode.TARGET) {
          Column({ space: 8 }) {
            Row() {
              Text(this.session.targetCompleted ? '目标达成 · 功德圆满' : '目标进度')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.session.targetCompleted ? '#A9824B' : this.secondaryText())
              Blank()
              Text(`${this.session.currentCount} / ${this.session.targetCount}`)
                .fontSize(14)
                .fontColor(this.primaryText())
            }
            Progress({
              value: this.session.currentCount,
              total: Math.max(1, this.session.targetCount),
              type: ProgressType.Linear
            })
              .height(8)
              .color('#A9824B')
              .backgroundColor(this.isDark() ? '#3B3530' : '#E8E2D8')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.card())
          .borderRadius(18)
          .margin({ bottom: 18 })
        } else {
          Text(this.session.mode === SessionMode.FREE ? '自由模式 · 无拘无束，随心而敲' :
            (this.session.running ? '自动敲击运行中 · 再次点击自动可关闭' : '自动模式 · 每秒自动敲击'))
            .fontSize(13)
            .fontColor(this.secondaryText())
            .margin({ bottom: 18 })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(this.pageBackground())
  }
}
