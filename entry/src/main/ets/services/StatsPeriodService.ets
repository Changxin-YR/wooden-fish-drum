import { DailyRecord, StatsBucket, StatsPeriodView } from '../models/AppModels';
import { StatsPeriod } from '../models/Enums';
import { PracticeSession } from '../models/PracticeModels';
import { DateUtil } from '../utils/DateUtil';

export class StatsPeriodService {
  static build(records: DailyRecord[], sessions: PracticeSession[], today: string,
    period: StatsPeriod): StatsPeriodView {
    const view: StatsPeriodView = new StatsPeriodView();
    const range: string[] = StatsPeriodService.range(today, period);
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
    if (period === StatsPeriod.TODAY) return '本日';
    if (period === StatsPeriod.CURRENT_WEEK) return '本周';
    if (period === StatsPeriod.CURRENT_MONTH) return '本月';
    if (period === StatsPeriod.CURRENT_YEAR) return '本年';
    if (period === StatsPeriod.LAST_7_DAYS) return '近七日';
    if (period === StatsPeriod.LAST_4_WEEKS) return '近四周';
    if (period === StatsPeriod.LAST_3_MONTHS) return '近三月';
    return '近一年';
  }

  private static title(period: StatsPeriod): string {
    return `${StatsPeriodService.scopeLabel(period)}趋势`;
  }

  private static range(today: string, period: StatsPeriod): string[] {
    if (period === StatsPeriod.TODAY) return [today, today];
    if (period === StatsPeriod.CURRENT_WEEK) return [StatsPeriodService.weekStart(today), today];
    if (period === StatsPeriod.CURRENT_MONTH) return [`${today.slice(0, 7)}-01`, today];
    if (period === StatsPeriod.CURRENT_YEAR) return [`${today.slice(0, 4)}-01-01`, today];
    if (period === StatsPeriod.LAST_7_DAYS) return [DateUtil.addDays(today, -6), today];
    if (period === StatsPeriod.LAST_4_WEEKS) {
      return [DateUtil.addDays(StatsPeriodService.weekStart(today), -21), today];
    }
    if (period === StatsPeriod.LAST_3_MONTHS) {
      return [`${StatsPeriodService.addMonths(today.slice(0, 7), -2)}-01`, today];
    }
    return [`${StatsPeriodService.addMonths(today.slice(0, 7), -11)}-01`, today];
  }

  private static buckets(records: DailyRecord[], today: string, period: StatsPeriod): StatsBucket[] {
    if (period === StatsPeriod.TODAY) return StatsPeriodService.dailyBuckets(records, today, today);
    if (period === StatsPeriod.CURRENT_WEEK) {
      return StatsPeriodService.dailyBuckets(records, StatsPeriodService.weekStart(today), today);
    }
    if (period === StatsPeriod.CURRENT_MONTH) {
      return StatsPeriodService.dailyBuckets(records, `${today.slice(0, 7)}-01`, today);
    }
    if (period === StatsPeriod.CURRENT_YEAR) {
      return StatsPeriodService.monthlyBuckets(records, `${today.slice(0, 4)}-01`, today.slice(0, 7));
    }
    if (period === StatsPeriod.LAST_7_DAYS) {
      return StatsPeriodService.dailyBuckets(records, DateUtil.addDays(today, -6), today);
    }
    if (period === StatsPeriod.LAST_4_WEEKS) {
      return StatsPeriodService.weeklyBuckets(records, DateUtil.addDays(StatsPeriodService.weekStart(today), -21), 4);
    }
    if (period === StatsPeriod.LAST_3_MONTHS) {
      return StatsPeriodService.monthlyBuckets(records, StatsPeriodService.addMonths(today.slice(0, 7), -2),
        today.slice(0, 7));
    }
    return StatsPeriodService.monthlyBuckets(records, StatsPeriodService.addMonths(today.slice(0, 7), -11),
      today.slice(0, 7));
  }

  private static weekStart(today: string): string {
    const parts: string[] = today.split('-');
    const date: Date = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
    const day: number = date.getDay();
    return DateUtil.addDays(today, day === 0 ? -6 : 1 - day);
  }

  private static addMonths(monthKey: string, offset: number): string {
    const parts: string[] = monthKey.split('-');
    const date: Date = new Date(Number(parts[0]), Number(parts[1]) - 1 + offset, 1);
    return DateUtil.toKey(date).slice(0, 7);
  }

  private static dailyBuckets(records: DailyRecord[], start: string, end: string): StatsBucket[] {
    const result: StatsBucket[] = [];
    let current: string = start;
    while (current <= end) {
      result.push(StatsPeriodService.aggregateBucket(records, current, current, DateUtil.shortLabel(current)));
      current = DateUtil.addDays(current, 1);
    }
    return result;
  }

  private static weeklyBuckets(records: DailyRecord[], start: string, count: number): StatsBucket[] {
    const result: StatsBucket[] = [];
    for (let index: number = 0; index < count; index++) {
      const weekStart: string = DateUtil.addDays(start, index * 7);
      const weekEnd: string = DateUtil.addDays(weekStart, 6);
      result.push(StatsPeriodService.aggregateBucket(records, weekStart, weekEnd,
        `${DateUtil.shortLabel(weekStart)}`));
    }
    return result;
  }

  private static monthlyBuckets(records: DailyRecord[], startMonth: string, endMonth: string): StatsBucket[] {
    const result: StatsBucket[] = [];
    let current: string = startMonth;
    while (current <= endMonth) {
      const next: string = StatsPeriodService.addMonths(current, 1);
      const end: string = DateUtil.addDays(`${next}-01`, -1);
      result.push(StatsPeriodService.aggregateBucket(records, `${current}-01`, end, current.slice(5)));
      current = next;
    }
    return result;
  }

  private static aggregateBucket(records: DailyRecord[], start: string, end: string, label: string): StatsBucket {
    const bucket: StatsBucket = new StatsBucket(label);
    records.forEach((record: DailyRecord): void => {
      if (record.date < start || record.date > end) return;
      bucket.manualCount += record.manualCount;
      bucket.autoCount += record.autoCount;
      bucket.totalCount += record.totalCount;
      bucket.durationSeconds += record.durationSeconds;
      bucket.incenseSeconds += record.incenseSeconds;
    });
    return bucket;
  }

  private static applyRecords(view: StatsPeriodView, records: DailyRecord[], start: string, end: string): void {
    records.forEach((record: DailyRecord): void => {
      if (record.date < start || record.date > end) return;
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
    buckets.forEach((bucket: StatsBucket): void => { value = Math.max(value, bucket.totalCount); });
    return value;
  }

  private static maxDuration(buckets: StatsBucket[]): number {
    let value: number = 1;
    buckets.forEach((bucket: StatsBucket): void => { value = Math.max(value, bucket.durationSeconds); });
    return value;
  }
}
