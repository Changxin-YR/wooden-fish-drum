import { StatsBucket } from '../models/AppModels';

@Component
export struct StatsBarChart {
  @Prop buckets: StatsBucket[];
  @Prop dark: boolean;
  @Prop duration: boolean = false;

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
    return Math.max(6, Math.round(value / this.maxValue() * 96));
  }

  build() {
    if (this.buckets.length === 0) {
      Column({ space: 6 }) {
        Text('暂无趋势数据')
          .fontSize(14)
          .fontColor(this.dark ? '#AAA198' : '#817970')
        Text('完成一次练习后，这里会显示本地趋势')
          .fontSize(12)
          .fontColor(this.dark ? '#7F7770' : '#A0968C')
      }
      .width('100%')
      .height(146)
      .justifyContent(FlexAlign.Center)
    } else {
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.buckets, (bucket: StatsBucket, index: number) => {
            Column({ space: 5 }) {
              Text(this.valueLabel(bucket))
                .fontSize(10)
                .fontColor(this.dark ? '#AAA198' : '#817970')
                .maxLines(1)
              Blank()
              Row()
                .width(22)
                .height(this.barHeight(bucket))
                .backgroundColor(this.duration ? '#8FA995' :
                  (index === this.buckets.length - 1 ? '#8A5635' : '#D4AD7D'))
                .borderRadius({ topLeft: 4, topRight: 4 })
              Text(bucket.label)
                .fontSize(9)
                .fontColor(this.dark ? '#AAA198' : '#817970')
                .maxLines(1)
            }
            .width(44)
            .height(142)
            .justifyContent(FlexAlign.End)
          })
        }
        .width(Math.max(300, this.buckets.length * 52))
        .height(146)
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .height(146)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
  }
}
