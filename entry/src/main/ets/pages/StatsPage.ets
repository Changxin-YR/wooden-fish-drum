import { StatsBarChart } from '../components/StatsBarChart';
import { DesignTokens } from '../constants/DesignTokens';
import { DailyRecord, StatsPeriodView, StatsSummary } from '../models/AppModels';
import { StatsPeriod, ToolType } from '../models/Enums';
import { PracticeSession } from '../models/PracticeModels';
import { StatsPeriodService } from '../services/StatsPeriodService';
import { appStore } from '../stores/AppRuntime';
import { DateUtil } from '../utils/DateUtil';

@Component
export struct StatsPage {
  @Prop summary: StatsSummary;
  @Prop records: DailyRecord[];
  @Prop dark: boolean;
  @Prop sessions: PracticeSession[] = appStore.recentSessions;
  @State period: StatsPeriod = StatsPeriod.DAY;
  @State viewportWidth: number = 390;

  private pageBackground(): string {
    return this.dark ? DesignTokens.darkBackground : DesignTokens.lightBackground;
  }

  private card(): string {
    return this.dark ? DesignTokens.darkCard : DesignTokens.lightCard;
  }

  private primaryText(): string {
    return this.dark ? DesignTokens.darkText : DesignTokens.lightText;
  }

  private secondaryText(): string {
    return this.dark ? DesignTokens.darkSecondary : DesignTokens.lightSecondary;
  }

  private divider(): string {
    return this.dark ? DesignTokens.darkDivider : DesignTokens.lightDivider;
  }

  private currentView(): StatsPeriodView {
    return StatsPeriodService.build(this.records, this.sessions, DateUtil.todayKey(), this.period);
  }

  private formatDuration(seconds: number): string {
    if (seconds < 60) {
      return `${seconds} 秒`;
    }
    if (seconds < 3600) {
      return `${Math.round(seconds / 60)} 分钟`;
    }
    const hours: number = Math.floor(seconds / 3600);
    const minutes: number = Math.round((seconds % 3600) / 60);
    return minutes === 0 ? `${hours} 小时` : `${hours} 小时 ${minutes} 分`;
  }

  private formatTime(value: number): string {
    const date: Date = new Date(value);
    const hour: string = `${date.getHours()}`.padStart(2, '0');
    const minute: string = `${date.getMinutes()}`.padStart(2, '0');
    return `${hour}:${minute}`;
  }

  private toolName(type: ToolType): string {
    if (type === ToolType.BEADS) {
      return '念珠';
    }
    if (type === ToolType.INCENSE) {
      return '一炷香';
    }
    return '木鱼';
  }

  private sessionDetail(session: PracticeSession): string {
    if (session.toolType === ToolType.INCENSE) {
      return this.formatDuration(session.durationSeconds);
    }
    return `${session.manualCount + session.automaticCount} 次 · ${this.formatDuration(session.durationSeconds)}`;
  }

  @Builder
  PeriodTab(period: StatsPeriod, label: string) {
    Column({ space: 1 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(this.period === period ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.period === period ? (this.dark ? DesignTokens.accentLight : DesignTokens.wood) :
          this.secondaryText())
      Text(this.period === period ? '已选' : ' ')
        .fontSize(9)
        .fontColor(this.period === period ? (this.dark ? DesignTokens.accentLight : DesignTokens.wood) :
          Color.Transparent)
    }
    .layoutWeight(1)
    .height(48)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.period === period ? (this.dark ? '#3B3530' : '#F8F0E5') : Color.Transparent)
    .border({ width: { bottom: this.period === period ? 2 : 0 }, color: DesignTokens.accent })
    .borderRadius(DesignTokens.radiusControl)
    .onClick((): void => {
      this.period = period;
    })
    .accessibilityText(`${label}${this.period === period ? '，已选' : ''}`)
  }

  @Builder
  Metric(label: string, value: string, unit: string, accent: string) {
    Column({ space: 5 }) {
      Text(label).fontSize(12).fontColor(this.secondaryText())
      Text(value)
        .fontSize(this.viewportWidth < 360 ? 20 : 24)
        .fontWeight(FontWeight.Bold)
        .fontColor(accent)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(unit).fontSize(11).fontColor(this.secondaryText())
    }
    .layoutWeight(1)
    .constraintSize({ minWidth: 0, minHeight: 72 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  SummarySection(view: StatsPeriodView) {
    Row() {
      this.Metric('计数', view.totalCount.toLocaleString(), '木鱼与念珠 / 次',
        this.dark ? DesignTokens.accentLight : DesignTokens.wood)
      Divider().vertical(true).height(54).color(this.divider())
      this.Metric('练习时长', this.formatDuration(view.durationSeconds), '全部真实练习',
        this.dark ? '#B9D0BE' : '#637F68')
      Divider().vertical(true).height(54).color(this.divider())
      this.Metric('一炷香', this.formatDuration(view.incenseSeconds), '独立时长',
        this.dark ? '#E3C391' : '#996A35')
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 14, bottom: 14 })
    .backgroundColor(this.card())
    .borderRadius(DesignTokens.radiusCard)
    .border({ width: 1, color: this.divider() })
  }

  @Builder
  RecentSection(view: StatsPeriodView) {
    Column({ space: 12 }) {
      Row() {
        Text('最近练习').fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.primaryText())
        Blank()
        Text(`${view.recentSessions.length} 条`).fontSize(12).fontColor(this.secondaryText())
      }
      if (view.recentSessions.length === 0) {
        Column({ space: 7 }) {
          Text('还没有真实练习记录')
            .fontSize(15)
            .fontColor(this.primaryText())
          Text('完成木鱼、念珠或一炷香练习后，会按开始时间显示在这里')
            .fontSize(12)
            .fontColor(this.secondaryText())
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .constraintSize({ minHeight: 112 })
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(view.recentSessions, (session: PracticeSession, index: number) => {
          Row({ space: 12 }) {
            Text(session.toolType === ToolType.INCENSE ? '香' : (session.toolType === ToolType.BEADS ? '珠' : '木'))
              .width(40)
              .height(40)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.dark ? DesignTokens.accentLight : DesignTokens.wood)
              .textAlign(TextAlign.Center)
              .backgroundColor(this.dark ? '#3B3530' : '#F7EFE4')
              .borderRadius(20)
            Column({ space: 3 }) {
              Text(this.toolName(session.toolType)).fontSize(15).fontColor(this.primaryText())
              Text(this.sessionDetail(session)).fontSize(11).fontColor(this.secondaryText())
            }
            .layoutWeight(1)
            .constraintSize({ minWidth: 0 })
            .alignItems(HorizontalAlign.Start)
            Text(this.formatTime(session.startTime)).fontSize(13).fontColor(this.secondaryText())
          }
          .width('100%')
          .constraintSize({ minHeight: 52 })
          if (index < view.recentSessions.length - 1) {
            Divider().color(this.divider())
          }
        }, (session: PracticeSession): string => session.id)
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(this.card())
    .borderRadius(DesignTokens.radiusCard)
    .border({ width: 1, color: this.divider() })
  }

  @Builder
  LocalSection(view: StatsPeriodView) {
    Column({ space: 14 }) {
      Text('本地统计').width('100%').fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.primaryText())
      Row() {
        this.Metric('木鱼', view.woodenFishCount.toLocaleString(), '次',
          this.dark ? DesignTokens.accentLight : DesignTokens.wood)
        Divider().vertical(true).height(50).color(this.divider())
        this.Metric('念珠', view.beadsCount.toLocaleString(), '次',
          this.dark ? '#B9D0BE' : '#637F68')
        Divider().vertical(true).height(50).color(this.divider())
        this.Metric('会话', `${view.sessionCount}`, '条真实记录',
          this.dark ? '#E3C391' : '#996A35')
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(this.card())
    .borderRadius(DesignTokens.radiusCard)
    .border({ width: 1, color: this.divider() })
  }

  @Builder
  TrendSection(view: StatsPeriodView) {
    Column({ space: 14 }) {
      Text(view.title).width('100%').fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.primaryText())
      Column({ space: 4 }) {
        Row() {
          Text('次数趋势').fontSize(14).fontColor(this.primaryText())
          Blank()
          Text('独立纵轴 · 次').fontSize(11).fontColor(this.secondaryText())
        }
        StatsBarChart({ buckets: view.buckets, dark: this.dark, duration: false })
      }
      Column({ space: 4 }) {
        Row() {
          Text('时长趋势').fontSize(14).fontColor(this.primaryText())
          Blank()
          Text('独立纵轴 · 分钟').fontSize(11).fontColor(this.secondaryText())
        }
        StatsBarChart({ buckets: view.buckets, dark: this.dark, duration: true })
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(this.card())
    .borderRadius(DesignTokens.radiusCard)
    .border({ width: 1, color: this.divider() })
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Column({ space: 3 }) {
            Text('练习记录').fontSize(28).fontWeight(FontWeight.Bold).fontColor(this.primaryText())
            Text('所有数据仅保存在本机').fontSize(12).fontColor(this.secondaryText())
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Text(this.currentView().scopeLabel)
            .fontSize(13)
            .fontColor(this.dark ? DesignTokens.accentLight : DesignTokens.wood)
        }
        .width('100%')

        Row({ space: 2 }) {
          this.PeriodTab(StatsPeriod.DAY, '今日')
          this.PeriodTab(StatsPeriod.WEEK, '本周')
          this.PeriodTab(StatsPeriod.MONTH, '本月')
          this.PeriodTab(StatsPeriod.YEAR, '全部')
        }
        .width('100%')
        .padding(3)
        .backgroundColor(this.card())
        .borderRadius(DesignTokens.radiusControl)
        .border({ width: 1, color: this.divider() })

        this.SummarySection(this.currentView())

        if (this.viewportWidth >= 600) {
          Row({ space: 16 }) {
            Column({ space: 16 }) {
              this.RecentSection(this.currentView())
              this.LocalSection(this.currentView())
            }
            .layoutWeight(this.viewportWidth >= 1024 ? 2 : 1)
            .constraintSize({ minWidth: 0 })
            this.TrendSection(this.currentView())
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        } else {
          this.RecentSection(this.currentView())
          this.LocalSection(this.currentView())
          this.TrendSection(this.currentView())
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(this.pageBackground())
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.viewportWidth = Number(newValue.width);
    })
  }
}
