import { StatsBucket } from '../models/AppModels';
import { ThemeColors, ThemePalette } from '../constants/ThemePalette';

@Component
export struct StatsBarChart {
  @Prop buckets: StatsBucket[];
  @Prop dark: boolean;
  @Prop duration: boolean = false;

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

  private chartHeight(): number { return this.duration ? 28 : 48; }

  private maximumBarHeight(): number { return this.duration ? 6 : 20; }

  private maxValue(): number {
    let value: number = 1;
    this.buckets.forEach((bucket: StatsBucket): void => {
      value = Math.max(value, this.duration ? bucket.durationSeconds : bucket.totalCount);
    });
    return value;
  }

  private value(bucket: StatsBucket): number {
    return this.duration ? bucket.durationSeconds : bucket.totalCount;
  }

  private valueLabel(bucket: StatsBucket): string {
    if (!this.duration) {
      return `${bucket.totalCount}`;
    }
    if (bucket.durationSeconds < 60) {
      return `${bucket.durationSeconds}秒`;
    }
    return `${Math.round(bucket.durationSeconds / 60)}分`;
  }

  private barHeight(bucket: StatsBucket): number {
    const value: number = this.value(bucket);
    if (value === 0) {
      return 3;
    }
    return Math.max(4, Math.round(value / this.maxValue() * this.maximumBarHeight()));
  }

  build() {
    if (this.buckets.length === 0) {
      Column({ space: 6 }) {
        Text('暂无趋势数据')
          .fontSize(14)
          .fontColor(this.colors().secondary)
        Text('完成一次练习后，这里会显示本地趋势')
          .fontSize(12)
          .fontColor(this.colors().secondary)
      }
      .width('100%')
      .height(this.chartHeight())
      .justifyContent(FlexAlign.Center)
    } else {
      Scroll() {
        Row({ space: 6 }) {
          ForEach(this.buckets, (bucket: StatsBucket, index: number) => {
            Column({ space: 5 }) {
              Text(this.valueLabel(bucket))
                .fontSize(8)
                .fontColor(this.colors().secondary)
                .maxLines(1)
              Blank()
              Row()
                .width(22)
                .height(this.barHeight(bucket))
                .backgroundColor(this.duration ? this.colors().success :
                  (index === this.buckets.length - 1 ? this.colors().accent : this.colors().accentSoft))
                .borderRadius({ topLeft: 4, topRight: 4 })
              Text(bucket.label)
                .fontSize(8)
                .fontColor(this.colors().secondary)
                .maxLines(1)
            }
            .width(40)
            .height(this.chartHeight() - 4)
            .justifyContent(FlexAlign.End)
          })
        }
        .width(Math.max(300, this.buckets.length * 46))
        .height(this.chartHeight())
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .height(this.chartHeight())
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
  }
}
