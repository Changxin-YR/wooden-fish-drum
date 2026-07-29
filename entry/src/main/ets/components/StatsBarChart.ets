import { DailyRecord } from '../models/AppModels';
import { DateUtil } from '../utils/DateUtil';

@Component
export struct StatsBarChart {
  @Prop records: DailyRecord[];

  private maxValue(): number {
    let value: number = 1;
    this.records.forEach((record: DailyRecord): void => {
      value = Math.max(value, record.totalCount);
    });
    return value;
  }

  private barHeight(value: number): number {
    return Math.max(3, Math.round(value / this.maxValue() * 150));
  }

  build() {
    Row({ space: 8 }) {
      ForEach(this.records, (record: DailyRecord) => {
        Column({ space: 5 }) {
          Text(`${record.totalCount}`)
            .fontSize(10)
            .fontColor('#817970')
          Blank()
          Row()
            .width(24)
            .height(this.barHeight(record.totalCount))
            .backgroundColor(record === this.records[this.records.length - 1] ? '#8A5635' : '#D4AD7D')
            .borderRadius({ topLeft: 5, topRight: 5 })
          Text(DateUtil.shortLabel(record.date))
            .fontSize(10)
            .fontColor('#817970')
        }
        .height(195)
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
      })
    }
    .width('100%')
    .height(205)
    .alignItems(VerticalAlign.Bottom)
  }
}
