import { StatsSummary } from '../models/AppModels';
import { DesignTokens } from '../constants/DesignTokens';
import { ThemeColors, ThemePalette } from '../constants/ThemePalette';

@Component
export struct TodaySummaryCard {
  @Prop summary: StatsSummary;
  @Prop dark: boolean = false;
  @Prop compact: boolean = false;

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

  @Builder
  Metric(label: string, value: string, unit: string) {
    Column({ space: 6 }) {
      Text(label).fontSize(this.compact ? 13 : 14).fontColor(this.colors().secondary)
      Row({ space: 5 }) {
        Text(value).fontSize(this.compact ? 25 : 28).fontWeight(FontWeight.Medium).fontColor(this.colors().primary)
        Text(unit).fontSize(12).fontColor(this.colors().secondary).margin({ top: 10 })
      }
    }
    .layoutWeight(1)
    .height(DesignTokens.summaryHeight(390))
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Row() {
      this.Metric('今日次数', this.summary.todayCount.toLocaleString(), '次')
      Divider().vertical(true).height(38).color(this.colors().divider)
      this.Metric('累计次数', this.summary.totalCount.toLocaleString(), '次')
      Divider().vertical(true).height(38).color(this.colors().divider)
      this.Metric('连续天数', `${this.summary.streakDays}`, '天')
    }
    .width('100%')
    .height(DesignTokens.summaryHeight(390))
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.colors().card)
    .borderRadius(DesignTokens.radiusCard)
    .border({ width: 1, color: this.colors().divider })
    .shadow({ radius: this.dark ? 8 : 16, color: this.dark ? '#2BCE914A' : '#185C4129', offsetY: 5 })
  }
}
