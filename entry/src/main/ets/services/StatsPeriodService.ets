import { DailyRecord, StatsBucket, StatsPeriodView } from '../models/AppModels';
import { StatsPeriod } from '../models/Enums';
import { PracticeSession } from '../models/PracticeModels';
import { DateUtil } from '../utils/DateUtil';

export class StatsPeriodService {
  static build(records: DailyRecord[], sessions: PracticeSession[], today: string,
    period: StatsPeriod): StatsPeriodView {
    const view: StatsPeriodView = new StatsPeriodView();
    const range: string[] = StatsPeriodService.range(today, period, records);
    view.scopeLabel = StatsPeriodService.scopeLabel(period);
    view.title = StatsPeriodService.title(period);
    view.buckets = StatsPeriodService.buckets(records, today, period);
    StatsPeriodService.applyRecords(view, records, range[0], range[1]);
    view.recentSessions = StatsPeriodService.filterSessions(sessions, range[0], range[1]);
    view.countMax = StatsPeriodService.maxCount(view.buckets);
    view.durationMaxSeconds = StatsPeriodService.maxDuration(view.buckets);
    return view;
  }

  private static scopeLabel(period: StatsPeriod): string {
    if (period === StatsPeriod.DAY) {
      return '今日';
    }
    if (period === StatsPeriod.WEEK) {
      return '本周';
    }
    if (period === StatsPeriod.MONTH) {
      return '本月';
    }
    return '全部';
  }

  private static title(period: StatsPeriod): string {
    if (period === StatsPeriod.DAY) {
      return '最近 7 日趋势';
    }
    if (period === StatsPeriod.WEEK) {
      return '本周每日趋势';
    }
    if (period === StatsPeriod.MONTH) {
      return '本月每日趋势';
    }
    return '全部本地趋势';
  }

  private static range(today: string, period: StatsPeriod, records: DailyRecord[]): string[] {
    if (period === StatsPeriod.DAY) {
      return [today, today];
    }
    if (period === StatsPeriod.WEEK) {
      return [StatsPeriodService.weekStart(today), today];
    }
    if (period === StatsPeriod.MONTH) {
      return [`${today.slice(0, 7)}-01`, today];
    }
    let start: string = today;
    records.forEach((record: DailyRecord): void => {
      if (record.date < start) {
        start = record.date;
      }
    });
    return [start, today];
  }

  private static weekStart(today: string): string {
    const parts: string[] = today.split('-');
    const date: Date = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
    const day: number = date.getDay();
    return DateUtil.addDays(today, day === 0 ? -6 : 1 - day);
  }

  private static buckets(records: DailyRecord[], today: string, period: StatsPeriod): StatsBucket[] {
    if (period === StatsPeriod.DAY) {
      return StatsPeriodService.dailyBuckets(records, DateUtil.addDays(today, -6), today);
    }
    if (period === StatsPeriod.WEEK) {
      return StatsPeriodService.dailyBuckets(records, StatsPeriodService.weekStart(today), today);
    }
    if (period === StatsPeriod.MONTH) {
      return StatsPeriodService.dailyBuckets(records, `${today.slice(0, 7)}-01`, today);
    }
    return StatsPeriodService.allBuckets(records);
  }

  private static dailyBuckets(records: DailyRecord[], start: string, end: string): StatsBucket[] {
    const result: StatsBucket[] = [];
    let current: string = start;
    while (current <= end) {
      result.push(StatsPeriodService.bucketForDate(records, current));
      current = DateUtil.addDays(current, 1);
    }
    return result;
  }

  private static allBuckets(records: DailyRecord[]): StatsBucket[] {
    const sorted: DailyRecord[] = records.slice().sort((left: DailyRecord, right: DailyRecord): number =>
      left.date.localeCompare(right.date));
    return sorted.map((record: DailyRecord): StatsBucket => StatsPeriodService.toBucket(record));
  }

  private static bucketForDate(records: DailyRecord[], date: string): StatsBucket {
    const found: DailyRecord | undefined = records.find((record: DailyRecord): boolean => record.date === date);
    if (found === undefined) {
      return new StatsBucket(DateUtil.shortLabel(date));
    }
    return StatsPeriodService.toBucket(found);
  }

  private static toBucket(record: DailyRecord): StatsBucket {
    return new StatsBucket(DateUtil.shortLabel(record.date), record.manualCount, record.autoCount,
      record.durationSeconds, record.incenseSeconds);
  }

  private static applyRecords(view: StatsPeriodView, records: DailyRecord[], start: string, end: string): void {
    records.forEach((record: DailyRecord): void => {
      if (record.date < start || record.date > end) {
        return;
      }
      view.totalCount += record.totalCount;
      view.manualCount += record.manualCount;
      view.autoCount += record.autoCount;
      view.durationSeconds += record.durationSeconds;
      view.incenseSeconds += record.incenseSeconds;
      view.woodenFishCount += record.woodenFishCount;
      view.beadsCount += record.beadsCount;
      view.sessionCount += record.sessionCount;
    });
  }

  private static filterSessions(sessions: PracticeSession[], start: string, end: string): PracticeSession[] {
    return sessions.filter((session: PracticeSession): boolean => {
      const date: string = session.date.length > 0 ? session.date : DateUtil.toKey(new Date(session.startTime));
      return date >= start && date <= end;
    }).slice().sort((left: PracticeSession, right: PracticeSession): number => right.startTime - left.startTime);
  }

  private static maxCount(buckets: StatsBucket[]): number {
    let value: number = 1;
    buckets.forEach((bucket: StatsBucket): void => {
      value = Math.max(value, bucket.totalCount);
    });
    return value;
  }

  private static maxDuration(buckets: StatsBucket[]): number {
    let value: number = 1;
    buckets.forEach((bucket: StatsBucket): void => {
      value = Math.max(value, bucket.durationSeconds);
    });
    return value;
  }
}
