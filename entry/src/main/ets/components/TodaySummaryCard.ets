import { StatsSummary } from '../models/AppModels';
import { DesignTokens } from '../constants/DesignTokens';

@Component
export struct TodaySummaryCard {
  @Prop summary: StatsSummary;
  @Prop dark: boolean = false;

  private primaryText(): string {
    return this.dark ? DesignTokens.darkText : '#56371F';
  }

  private secondaryText(): string {
    return this.dark ? DesignTokens.darkSecondary : '#8C7C6D';
  }

  @Builder
  Metric(symbol: string, label: string, value: string, unit: string) {
    Row({ space: 10 }) {
      Text(symbol)
        .width(42)
        .height(42)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#A86B37')
        .textAlign(TextAlign.Center)
        .backgroundColor(this.dark ? '#3A3028' : '#F8F1E8')
        .borderRadius(21)
      Column({ space: 2 }) {
        Text(label).fontSize(12).fontColor(this.secondaryText())
        Row({ space: 4 }) {
          Text(value).fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.primaryText())
          Text(unit).fontSize(12).fontColor(this.secondaryText())
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .constraintSize({ minHeight: 64 })
  }

  build() {
    Row() {
      this.Metric('今', '今日次数', this.summary.todayCount.toLocaleString(), '次')
      Divider().vertical(true).height(44).color(this.dark ? DesignTokens.darkDivider : '#E9DED0')
      this.Metric('累', '累计次数', this.summary.totalCount.toLocaleString(), '次')
      Divider().vertical(true).height(44).color(this.dark ? DesignTokens.darkDivider : '#E9DED0')
      this.Metric('续', '连续天数', `${this.summary.streakDays}`, '天')
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor(this.dark ? DesignTokens.darkCard : '#FFFEFC')
    .borderRadius(DesignTokens.radiusCard)
    .border({ width: 1, color: this.dark ? DesignTokens.darkDivider : '#EFE5D9' })
    .shadow({ radius: 14, color: this.dark ? '#22000000' : '#1F6E4A2D', offsetY: 5 })
  }
}
