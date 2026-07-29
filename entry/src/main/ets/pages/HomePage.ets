import { WoodenFishView } from '../components/WoodenFishView';
import { USER_MODE_CONFIGS } from '../constants/UserModeConfigs';
import { AppSettings, SessionState, StatsSummary } from '../models/AppModels';
import { SessionMode, ThemeMode } from '../models/Enums';

@Component
export struct HomePage {
  @Prop settings: AppSettings;
  @Prop summary: StatsSummary;
  @Prop session: SessionState;
  onHit: () => void = (): void => {};
  onSessionChange: (mode: SessionMode) => void = (): void => {};
  @State selectedSession: SessionMode = SessionMode.FREE;

  private isDark(): boolean {
    return this.settings.themeMode === ThemeMode.DARK;
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
      .fontColor(this.selectedSession === mode ? '#FFFFFF' : this.secondaryText())
      .backgroundColor(this.selectedSession === mode ? '#9A612C' : Color.Transparent)
      .borderRadius(24)
      .onClick((): void => {
        this.selectedSession = mode;
        this.onSessionChange(mode);
      })
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Text(`◉ ${USER_MODE_CONFIGS[this.settings.userMode].title}模式`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.primaryText())
            .padding({ left: 18, right: 18, top: 12, bottom: 12 })
            .backgroundColor(this.card())
            .borderRadius(24)
          Blank()
          Text(`今日功德  ${this.summary.todayCount.toLocaleString()}`)
            .fontSize(15)
            .fontColor(this.secondaryText())
        }
        .width('100%')

        Text(this.settings.currentText)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())

        WoodenFishView({
          dark: this.isDark(),
          label: this.settings.currentText,
          floatingEnabled: this.settings.floatingTextEnabled,
          onHit: (): void => this.onHit()
        })

        Column({ space: 3 }) {
          Text('今日功德')
            .fontSize(16)
            .fontColor(this.secondaryText())
          Text(this.summary.todayCount.toLocaleString())
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
        }

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
          this.SessionTab(SessionMode.TIMER, '限时')
          this.SessionTab(SessionMode.AUTO, '自动')
        }
        .width('100%')
        .padding(4)
        .backgroundColor(this.card())
        .borderRadius(28)

        Text(this.selectedSession === SessionMode.FREE ? '自由模式 · 无拘无束，随心而敲' :
          this.selectedSession === SessionMode.TARGET ? '目标模式 · 完成 108 次功德' :
            this.selectedSession === SessionMode.TIMER ? '限时模式 · 专注 5 分钟' :
              (this.session.running ? '自动敲击运行中 · 点击切换可停止' : '自动模式 · 每秒自动敲击'))
          .fontSize(13)
          .fontColor(this.secondaryText())
          .margin({ bottom: 18 })
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
