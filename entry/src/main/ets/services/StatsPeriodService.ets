import { DailyRecord, StatsBucket, StatsPeriodView } from '../models/AppModels';
import { StatsPeriod } from '../models/Enums';
import { DateUtil } from '../utils/DateUtil';

export class StatsPeriodService {
  static build(records: DailyRecord[], today: string, period: StatsPeriod): StatsPeriodView {
    const view: StatsPeriodView = new StatsPeriodView();
    if (period === StatsPeriod.DAY) {
      view.title = '近 7 日每日趋势';
      view.scopeLabel = '今日';
      view.buckets = StatsPeriodService.dailyBuckets(records, today);
      StatsPeriodService.applyRange(view, records, today, today);
    } else if (period === StatsPeriod.WEEK) {
      view.title = '近 8 周趋势';
      view.scopeLabel = '近 7 日';
      view.buckets = StatsPeriodService.weeklyBuckets(records, today);
      StatsPeriodService.applyRange(view, records, DateUtil.addDays(today, -6), today);
    } else if (period === StatsPeriod.MONTH) {
      view.title = '近 12 月趋势';
      view.scopeLabel = '本月';
      view.buckets = StatsPeriodService.monthlyBuckets(records, today);
      StatsPeriodService.applyPrefix(view, records, today.slice(0, 7));
    } else {
      view.title = '近 5 年趋势';
      view.scopeLabel = '本年';
      view.buckets = StatsPeriodService.yearlyBuckets(records, today);
      StatsPeriodService.applyPrefix(view, records, today.slice(0, 4));
    }
    return view;
  }

  private static dailyBuckets(records: DailyRecord[], today: string): StatsBucket[] {
    const buckets: StatsBucket[] = [];
    for (let offset: number = -6; offset <= 0; offset++) {
      const key: string = DateUtil.addDays(today, offset);
      buckets.push(StatsPeriodService.bucketForRange(records, DateUtil.shortLabel(key), key, key));
    }
    return buckets;
  }

  private static weeklyBuckets(records: DailyRecord[], today: string): StatsBucket[] {
    const buckets: StatsBucket[] = [];
    for (let index: number = 7; index >= 0; index--) {
      const end: string = DateUtil.addDays(today, -index * 7);
      const start: string = DateUtil.addDays(end, -6);
      buckets.push(StatsPeriodService.bucketForRange(records, DateUtil.shortLabel(start), start, end));
    }
    return buckets;
  }

  private static monthlyBuckets(records: DailyRecord[], today: string): StatsBucket[] {
    const buckets: StatsBucket[] = [];
    for (let index: number = 11; index >= 0; index--) {
      const key: string = StatsPeriodService.monthKey(today, -index);
      buckets.push(StatsPeriodService.bucketForPrefix(records, `${key.slice(5)}月`, key));
    }
    return buckets;
  }

  private static yearlyBuckets(records: DailyRecord[], today: string): StatsBucket[] {
    const buckets: StatsBucket[] = [];
    const currentYear: number = Number(today.slice(0, 4));
    for (let index: number = 4; index >= 0; index--) {
      const key: string = `${currentYear - index}`;
      buckets.push(StatsPeriodService.bucketForPrefix(records, key, key));
    }
    return buckets;
  }

  private static monthKey(today: string, offset: number): string {
    const parts: string[] = today.split('-');
    const date: Date = new Date(Number(parts[0]), Number(parts[1]) - 1 + offset, 1);
    return DateUtil.toKey(date).slice(0, 7);
  }

  private static bucketForRange(records: DailyRecord[], label: string, start: string, end: string): StatsBucket {
    let manual: number = 0;
    let automatic: number = 0;
    records.forEach((record: DailyRecord): void => {
      if (record.date >= start && record.date <= end) {
        manual += record.manualCount;
        automatic += record.autoCount;
      }
    });
    return new StatsBucket(label, manual, automatic);
  }

  private static bucketForPrefix(records: DailyRecord[], label: string, prefix: string): StatsBucket {
    let manual: number = 0;
    let automatic: number = 0;
    records.forEach((record: DailyRecord): void => {
      if (record.date.startsWith(prefix)) {
        manual += record.manualCount;
        automatic += record.autoCount;
      }
    });
    return new StatsBucket(label, manual, automatic);
  }

  private static applyRange(view: StatsPeriodView, records: DailyRecord[], start: string, end: string): void {
    const bucket: StatsBucket = StatsPeriodService.bucketForRange(records, '', start, end);
    StatsPeriodService.applyBucket(view, bucket);
  }

  private static applyPrefix(view: StatsPeriodView, records: DailyRecord[], prefix: string): void {
    const bucket: StatsBucket = StatsPeriodService.bucketForPrefix(records, '', prefix);
    StatsPeriodService.applyBucket(view, bucket);
  }

  private static applyBucket(view: StatsPeriodView, bucket: StatsBucket): void {
    view.totalCount = bucket.totalCount;
    view.manualCount = bucket.manualCount;
    view.autoCount = bucket.autoCount;
  }
}
