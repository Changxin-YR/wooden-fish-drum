import { StatsBucket } from '../models/AppModels';

@Component
export struct StatsBarChart {
  @Prop buckets: StatsBucket[];
  @Prop dark: boolean;
  @Prop @Watch('onScrollRequestChanged') scrollRequest: number;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.scrollToLatest();
  }

  private onScrollRequestChanged(): void {
    this.scrollToLatest();
  }

  private scrollToLatest(): void {
    setTimeout((): void => {
      this.scroller.scrollEdge(Edge.End);
    }, 0);
  }

  private maxValue(): number {
    let value: number = 1;
    this.buckets.forEach((bucket: StatsBucket): void => {
      value = Math.max(value, bucket.totalCount);
    });
    return value;
  }

  private barHeight(value: number): number {
    return Math.max(3, Math.round(value / this.maxValue() * 150));
  }

  build() {
    Scroll(this.scroller) {
      Row({ space: 8 }) {
        ForEach(this.buckets, (bucket: StatsBucket, index: number) => {
          Column({ space: 5 }) {
            Text(`${bucket.totalCount}`)
              .fontSize(10)
              .fontColor(this.dark ? '#AAA198' : '#817970')
            Blank()
            Row()
              .width(24)
              .height(this.barHeight(bucket.totalCount))
              .backgroundColor(index === this.buckets.length - 1 ? '#8A5635' : '#D4AD7D')
              .borderRadius({ topLeft: 5, topRight: 5 })
            Text(bucket.label)
              .fontSize(10)
              .fontColor(this.dark ? '#AAA198' : '#817970')
              .maxLines(1)
          }
          .width(46)
          .height(195)
          .justifyContent(FlexAlign.End)
        }
        )
      }
      .width(Math.max(320, this.buckets.length * 54))
      .height(205)
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .height(205)
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
  }
}
