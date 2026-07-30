import { StatsBarChart } from '../components/StatsBarChart';
import { DailyRecord, StatsPeriodView, StatsSummary } from '../models/AppModels';
import { StatsPeriod } from '../models/Enums';
import { StatsPeriodService } from '../services/StatsPeriodService';
import { DateUtil } from '../utils/DateUtil';
import { DesignTokens } from '../constants/DesignTokens';

@Component
export struct StatsPage {
  @Prop summary: StatsSummary;
  @Prop records: DailyRecord[];
  @Prop dark: boolean;
  @State period: StatsPeriod = StatsPeriod.DAY;

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

  private currentView(): StatsPeriodView {
    return StatsPeriodService.build(this.records, DateUtil.todayKey(), this.period);
  }

  @Builder
  PeriodTab(period: StatsPeriod, label: string) {
    Text(label)
      .layoutWeight(1)
      .height(46)
      .textAlign(TextAlign.Center)
      .fontSize(16)
      .fontColor(this.period === period ? Color.White : this.secondaryText())
      .backgroundColor(this.period === period ? '#9A612C' : Color.Transparent)
      .borderRadius(23)
      .onClick((): void => {
        this.period = period;
      })
      .accessibilityText(`切换${label}统计`)
  }

  @Builder
  SummaryItem(icon: string, title: string, value: () => string, detail: string) {
    Column({ space: 7 }) {
      Text(icon)
        .fontSize(24)
      Text(title)
        .fontSize(13)
        .fontColor(this.secondaryText())
      Text(value())
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text(detail)
        .fontSize(11)
        .fontColor('#A9824B')
    }
    .layoutWeight(1)
  }

  build() {
    Scroll() {
      Column({ space: 22 }) {
        Text('功德统计')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

        Row({ space: 4 }) {
          this.PeriodTab(StatsPeriod.DAY, '日')
          this.PeriodTab(StatsPeriod.WEEK, '周')
          this.PeriodTab(StatsPeriod.MONTH, '月')
          this.PeriodTab(StatsPeriod.YEAR, '年')
        }
        .padding(4)
        .width('100%')
        .backgroundColor(this.card())
        .borderRadius(27)

        Row() {
          this.SummaryItem('▣', this.currentView().scopeLabel,
            (): string => this.currentView().totalCount.toLocaleString(), '当前口径')
          this.SummaryItem('◇', '总计功德', (): string => this.summary.totalCount.toLocaleString(), '累计功德')
          this.SummaryItem('♧', '手动敲击',
            (): string => this.currentView().manualCount.toLocaleString(), '当前口径')
          this.SummaryItem('◉', '自动敲击',
            (): string => this.currentView().autoCount.toLocaleString(), '当前口径')
        }
        .width('100%')
        .padding({ top: 22, bottom: 22 })
        .backgroundColor(this.card())
        .borderRadius(20)
        .shadow({ radius: 12, color: '#128A5635', offsetY: 4 })

        Column({ space: 14 }) {
          Row() {
            Text(this.currentView().title)
              .fontSize(19)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.primaryText())
            Blank()
            Text('功德数⌄')
              .fontSize(12)
              .fontColor(this.secondaryText())
          }
          StatsBarChart({ buckets: this.currentView().buckets, dark: this.dark })
        }
        .width('100%')
        .padding(18)
        .backgroundColor(this.card())
        .borderRadius(20)

        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Text('连续敲击天数').fontSize(16).fontColor(this.primaryText())
            Text(`${this.summary.streakDays} 天`)
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8A5635')
            Text('保持每日一敲，静心自修').fontSize(12).fontColor(this.secondaryText())
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Column({ space: 8 }) {
            Text('敲击趋势').fontSize(16).fontColor(this.primaryText())
            Text(this.summary.todayCount >= this.summary.maxDailyCount ? '今日最佳' : '稳步上升')
              .fontSize(27)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8A5635')
            Text('继续保持哦').fontSize(12).fontColor(this.secondaryText())
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(20)
        .backgroundColor(this.card())
        .borderRadius(20)
        .margin({ bottom: 20 })
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
