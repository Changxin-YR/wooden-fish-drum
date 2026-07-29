import { StatsBarChart } from '../components/StatsBarChart';
import { DailyRecord, StatsSummary } from '../models/AppModels';

@Component
export struct StatsPage {
  @Prop summary: StatsSummary;
  @Prop records: DailyRecord[];
  @State period: number = 0;

  @Builder
  PeriodTab(index: number, label: string) {
    Text(label)
      .layoutWeight(1)
      .height(46)
      .textAlign(TextAlign.Center)
      .fontSize(16)
      .fontColor(this.period === index ? Color.White : '#817970')
      .backgroundColor(this.period === index ? '#9A612C' : Color.Transparent)
      .borderRadius(23)
      .onClick((): void => {
        this.period = index;
      })
  }

  @Builder
  SummaryItem(icon: string, title: string, value: () => string, detail: string) {
    Column({ space: 7 }) {
      Text(icon)
        .fontSize(24)
      Text(title)
        .fontSize(13)
        .fontColor('#817970')
      Text(value())
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2E2924')
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
          .fontColor('#2E2924')

        Row({ space: 4 }) {
          this.PeriodTab(0, '日')
          this.PeriodTab(1, '周')
          this.PeriodTab(2, '月')
          this.PeriodTab(3, '年')
        }
        .padding(4)
        .width('100%')
        .backgroundColor('#FFFDF8')
        .borderRadius(27)

        Row() {
          this.SummaryItem('▣', '今日功德', (): string => this.summary.todayCount.toLocaleString(), '实时统计')
          this.SummaryItem('◇', '总计功德', (): string => this.summary.totalCount.toLocaleString(), '累计功德')
          this.SummaryItem('♧', '手动敲击', (): string => this.summary.manualCount.toLocaleString(), '手动记录')
          this.SummaryItem('◉', '自动敲击', (): string => this.summary.autoCount.toLocaleString(), '自动记录')
        }
        .width('100%')
        .padding({ top: 22, bottom: 22 })
        .backgroundColor('#FFFDF8')
        .borderRadius(20)
        .shadow({ radius: 12, color: '#128A5635', offsetY: 4 })

        Column({ space: 14 }) {
          Row() {
            Text('近 7 日功德趋势')
              .fontSize(19)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2E2924')
            Blank()
            Text('功德数⌄')
              .fontSize(12)
              .fontColor('#817970')
          }
          StatsBarChart({ records: this.records })
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#FFFDF8')
        .borderRadius(20)

        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Text('连续敲击天数').fontSize(16).fontColor('#2E2924')
            Text(`${this.summary.streakDays} 天`)
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8A5635')
            Text('保持每日一敲，静心自修').fontSize(12).fontColor('#817970')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Column({ space: 8 }) {
            Text('敲击趋势').fontSize(16).fontColor('#2E2924')
            Text(this.summary.todayCount >= this.summary.maxDailyCount ? '今日最佳' : '稳步上升')
              .fontSize(27)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8A5635')
            Text('继续保持哦').fontSize(12).fontColor('#817970')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFDF8')
        .borderRadius(20)
        .margin({ bottom: 20 })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor('#F6F1E8')
  }
}
