import { StatsBarChart } from '../components/StatsBarChart';
import { DesignTokens } from '../constants/DesignTokens';
import { ThemeColors, ThemePalette } from '../constants/ThemePalette';
import { DailyRecord, StatsPeriodView, StatsSummary } from '../models/AppModels';
import { StatsPeriod, ToolType } from '../models/Enums';
import { PracticeSession } from '../models/PracticeModels';
import { StatsPeriodService } from '../services/StatsPeriodService';
import { DateUtil } from '../utils/DateUtil';

@Component
export struct StatsPage {
  @Prop summary: StatsSummary;
  @Prop records: DailyRecord[];
  @Prop dark: boolean;
  @Prop sessions: PracticeSession[] = [];
  @State period: StatsPeriod = StatsPeriod.DAY;
  @State viewportWidth: number = 390;

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

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

  private durationValue(seconds: number): string {
    if (seconds < 60) {
      return `${seconds}`;
    }
    if (seconds < 3600) {
      return `${Math.round(seconds / 60)}`;
    }
    return `${Math.round(seconds / 3600)}`;
  }

  private durationUnit(seconds: number): string {
    if (seconds < 60) {
      return '秒';
    }
    if (seconds < 3600) {
      return '分钟';
    }
    return '小时';
  }

  private toolImage(type: ToolType): Resource {
    if (type === ToolType.BEADS) {
      return $r('app.media.practice_beads');
    }
    if (type === ToolType.INCENSE) {
      return $r('app.media.practice_incense');
    }
    return $r('app.media.practice_wooden_fish');
  }

  private trendTitle(): string {
    if (this.period === StatsPeriod.DAY) {
      return '最近 7 日趋势';
    }
    if (this.period === StatsPeriod.WEEK) {
      return '最近 8 周趋势';
    }
    if (this.period === StatsPeriod.MONTH) {
      return '最近 12 月趋势';
    }
    return '近 5 年趋势';
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
    Column() {
      Text(label)
        .fontSize(14)
        .fontWeight(this.period === period ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.period === period ? this.colors().accent : this.colors().secondary)
    }
    .layoutWeight(1)
    .height(48)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.period === period ? this.colors().accentSoft : Color.Transparent)
    .border({ width: { bottom: this.period === period ? 2 : 0 }, color: this.colors().accent })
    .borderRadius(DesignTokens.radiusControl)
    .onClick((): void => {
      this.period = period;
    })
    .accessibilityText(`${label}${this.period === period ? '，已选' : ''}`)
  }

  @Builder
  LocalMetric(label: string, type: ToolType, value: string, unit: string, accent: string) {
    Column({ space: 3 }) {
      Row({ space: 5 }) {
        Image(this.toolImage(type)).width(24).height(24).objectFit(ImageFit.Contain)
        Text(label).fontSize(12).fontColor(this.colors().secondary)
      }
      Row({ space: 4 }) {
        Text(value).fontSize(22).fontWeight(FontWeight.Bold).fontColor(accent)
        Text(unit).fontSize(10).fontColor(this.colors().secondary).margin({ top: 8 })
      }
    }
    .layoutWeight(1)
    .constraintSize({ minWidth: 0, minHeight: 48 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  Metric(label: string, value: string, unit: string, accent: string, minimumHeight: number) {
    Column({ space: 5 }) {
      Text(label).fontSize(12).fontColor(this.colors().secondary)
      Text(value)
        .fontSize(this.viewportWidth < 360 ? 20 : 24)
        .fontWeight(FontWeight.Bold)
        .fontColor(accent)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(unit).fontSize(11).fontColor(this.colors().secondary)
    }
    .layoutWeight(1)
    .constraintSize({ minWidth: 0, minHeight: minimumHeight })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  SummarySection(view: StatsPeriodView) {
    Row() {
      this.Metric('计数', view.totalCount.toLocaleString(), '木鱼与念珠 / 次',
        this.colors().accent, 72)
      Divider().vertical(true).height(54).color(this.colors().divider)
      this.Metric('练习时长', this.durationValue(view.durationSeconds), this.durationUnit(view.durationSeconds),
        this.colors().success, 72)
      Divider().vertical(true).height(54).color(this.colors().divider)
      this.Metric('一炷香', this.durationValue(view.incenseSeconds), this.durationUnit(view.incenseSeconds),
        this.colors().accent, 72)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 14, bottom: 14 })
    .backgroundColor(this.colors().card)
    .borderRadius(8)
    .border({ width: 1, color: this.colors().divider })
  }

  @Builder
  RecentSection(view: StatsPeriodView) {
    Column({ space: 6 }) {
      Row() {
        Text('最近练习').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.colors().primary)
        Blank()
        Text(`${view.recentSessions.length} 条`).fontSize(12).fontColor(this.colors().secondary)
      }
      .width('100%')
      if (view.recentSessions.length === 0) {
        Column({ space: 7 }) {
          Text('还没有真实练习记录')
            .fontSize(15)
            .fontColor(this.colors().primary)
          Text('完成木鱼、念珠或一炷香练习后，会按开始时间显示在这里')
            .fontSize(12)
            .fontColor(this.colors().secondary)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .constraintSize({ minHeight: 80 })
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(view.recentSessions, (session: PracticeSession, index: number) => {
          Row({ space: 12 }) {
            Image(this.toolImage(session.toolType))
              .width(40)
              .height(40)
              .objectFit(ImageFit.Contain)
              .backgroundColor(this.colors().accentSoft)
              .borderRadius(20)
            Column({ space: 3 }) {
              Text(this.toolName(session.toolType)).fontSize(15).fontColor(this.colors().primary)
              Text(this.sessionDetail(session)).fontSize(11).fontColor(this.colors().secondary)
            }
            .layoutWeight(1)
            .constraintSize({ minWidth: 0 })
            .alignItems(HorizontalAlign.Start)
            Text(this.formatTime(session.startTime)).fontSize(13).fontColor(this.colors().secondary)
          }
          .width('100%')
          .constraintSize({ minHeight: 44 })
          if (index < view.recentSessions.length - 1) {
            Divider().color(this.colors().divider)
          }
        }, (session: PracticeSession): string => session.id)
      }
    }
    .width('100%')
    .padding(8)
    .backgroundColor(this.colors().card)
    .borderRadius(8)
    .border({ width: 1, color: this.colors().divider })
  }

  @Builder
  LocalSection(view: StatsPeriodView) {
    Column({ space: 5 }) {
      Text('本地统计').width('100%').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.colors().primary)
      Row() {
        this.LocalMetric('木鱼', ToolType.WOODEN_FISH, view.woodenFishCount.toLocaleString(), '次',
          this.colors().accent)
        Divider().vertical(true).height(42).color(this.colors().divider)
        this.LocalMetric('念珠', ToolType.BEADS, view.beadsCount.toLocaleString(), '次',
          this.colors().success)
        Divider().vertical(true).height(42).color(this.colors().divider)
        this.LocalMetric('会话', ToolType.INCENSE, `${view.sessionCount}`, '条', this.colors().accent)
      }
    }
    .width('100%')
    .padding(8)
    .backgroundColor(this.colors().card)
    .borderRadius(8)
    .border({ width: 1, color: this.colors().divider })
  }

  @Builder
  TrendSection(view: StatsPeriodView) {
    Column({ space: 6 }) {
      Text(this.trendTitle()).width('100%').fontSize(16).fontWeight(FontWeight.Medium)
        .fontColor(this.colors().primary)
      Column({ space: 2 }) {
        Row() {
          Text('次数趋势').fontSize(11).fontColor(this.colors().primary)
          Blank()
          Text('独立纵轴 · 次').fontSize(10).fontColor(this.colors().secondary)
        }
        .width('100%')
        StatsBarChart({ buckets: view.buckets, dark: this.dark, duration: false })
      }
      Column({ space: 2 }) {
        Row() {
          Text('时长趋势').fontSize(11).fontColor(this.colors().primary)
          Blank()
          Text('独立纵轴 · 分钟').fontSize(10).fontColor(this.colors().secondary)
        }
        .width('100%')
        StatsBarChart({ buckets: view.buckets, dark: this.dark, duration: true })
      }
    }
    .width('100%')
    .padding(6)
    .backgroundColor(this.colors().card)
    .borderRadius(8)
    .border({ width: 1, color: this.colors().divider })
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Row() {
          Column({ space: 3 }) {
            Text('练习记录').fontSize(DesignTokens.titleSize(this.viewportWidth)).fontWeight(FontWeight.Bold)
              .fontColor(this.colors().primary)
            Text('所有数据仅保存在本机').fontSize(12).fontColor(this.colors().secondary)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Image(this.dark ? $r('app.media.theme_mountain_dark') : $r('app.media.theme_mountain_light'))
            .width(132)
            .height(48)
            .objectFit(ImageFit.Cover)
            .opacity(this.dark ? 0.42 : 0.18)
            .borderRadius(8)
        }
        .width('100%')

        Row({ space: 2 }) {
          this.PeriodTab(StatsPeriod.DAY, '今日')
          this.PeriodTab(StatsPeriod.WEEK, '本周')
          this.PeriodTab(StatsPeriod.MONTH, '本月')
          this.PeriodTab(StatsPeriod.YEAR, '全部')
        }
        .width('100%')
        .height(52)
        .padding(2)
        .backgroundColor(this.colors().card)
        .borderRadius(8)
        .border({ width: 1, color: this.colors().divider })

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
      .padding({ left: DesignTokens.pageInset(this.viewportWidth), right: DesignTokens.pageInset(this.viewportWidth),
        top: 14, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(this.colors().page)
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.viewportWidth = Number(newValue.width);
    })
  }
}
