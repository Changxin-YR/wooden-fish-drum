import { WoodenFishView } from '../components/WoodenFishView';
import { AppSettings, SessionState, StatsSummary } from '../models/AppModels';
import { SessionMode } from '../models/Enums';
import { DesignTokens } from '../constants/DesignTokens';
import { USER_MODE_CONFIGS } from '../constants/UserModeConfigs';

@Component
export struct HomePage {
  @Prop settings: AppSettings;
  @Prop summary: StatsSummary;
  @Prop session: SessionState;
  @Prop homeTextCount: number;
  @Prop dark: boolean;
  onHit: () => void = (): void => {};
  onSessionChange: (mode: SessionMode) => void = (): void => {};
  onTargetChange: (count: number) => void = (): void => {};
  onAutoPause: () => void = (): void => {};
  private isDark(): boolean {
    return this.dark;
  }

  private pageBackground(): string {
    return this.isDark() ? DesignTokens.darkBackground : DesignTokens.homeLightBackground;
  }

  private card(): string {
    return this.isDark() ? DesignTokens.darkCard : DesignTokens.lightCard;
  }

  private primaryText(): string {
    return this.isDark() ? DesignTokens.darkText : DesignTokens.lightText;
  }

  private secondaryText(): string {
    return this.isDark() ? DesignTokens.darkSecondary : DesignTokens.lightSecondary;
  }

  private pauseForeground(): string {
    return this.isDark() ? DesignTokens.accentDark : DesignTokens.wood;
  }

  @Builder
  PauseIcon() {
    Row({ space: 3 }) {
      Blank()
        .width(3)
        .height(12)
        .backgroundColor(this.pauseForeground())
        .borderRadius(1.5)
      Blank()
        .width(3)
        .height(12)
        .backgroundColor(this.pauseForeground())
        .borderRadius(1.5)
    }
    .width(9)
    .height(14)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
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
      .accessibilityText(`${label}敲击模式`)
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text(`${this.settings.currentText}  ${this.homeTextCount.toLocaleString()}`)
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
          disabled: this.session.targetCompleted && this.session.mode === SessionMode.TARGET,
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
            Row({ space: 8 }) {
              ForEach(USER_MODE_CONFIGS[this.settings.userMode].recommendedTargets,
                (target: number) => {
                  Text(`${target}`)
                    .fontSize(13)
                    .fontColor(this.settings.targetCount === target ? '#FFFFFF' : this.secondaryText())
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.settings.targetCount === target ? '#9A612C' : Color.Transparent)
                    .border({
                      width: this.settings.targetCount === target ? 0 : 1,
                      color: this.isDark() ? '#4DD8B28C' : '#CCA9824B'
                    })
                    .borderRadius(16)
                    .onClick((): void => this.onTargetChange(target))
                }, (target: number): string => `target_${target}`)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.card())
          .borderRadius(18)
          .margin({ bottom: 18 })
        } else if (this.session.mode === SessionMode.AUTO) {
          Column({ space: 10 }) {
            Text(this.session.running && !this.session.paused ? '自动敲击运行中' :
              (this.session.paused ? '自动敲击已暂停' : '自动模式已停止'))
              .fontSize(14)
              .fontColor(this.secondaryText())
            if (this.session.running) {
              Text(`已敲 ${this.session.currentCount} 次`)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.primaryText())
              Button() {
                Row({ space: 6 }) {
                  if (this.session.paused) {
                    Text('▶')
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                  } else {
                    this.PauseIcon()
                  }
                  Text(this.session.paused ? '继续' : '暂停')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.session.paused ? '#FFFFFF' : this.pauseForeground())
                }
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }
                .backgroundColor(this.session.paused ? '#9A612C' : (this.isDark() ? '#3B3530' : '#F7EFE4'))
                .height(40)
                .borderRadius(20)
                .onClick((): void => this.onAutoPause())
                .accessibilityText(this.session.paused ? '继续自动敲击' : '暂停自动敲击')
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.card())
          .borderRadius(18)
          .margin({ bottom: 18 })
        } else {
          Column({ space: 4 }) {
            Text('自由模式 · 无拘无束，随心而敲')
              .fontSize(13)
              .fontColor(this.secondaryText())
            Text(`本次已敲 ${this.session.currentCount} 次`)
              .fontSize(12)
              .fontColor(this.secondaryText())
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.card())
          .borderRadius(18)
          .margin({ bottom: 18 })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24 })
      .backgroundColor(this.pageBackground())
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(this.pageBackground())
  }
}
