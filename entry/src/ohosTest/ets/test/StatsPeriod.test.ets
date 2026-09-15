import { describe, expect, it } from '@ohos/hypium';
import { DailyRecord, StatsPeriodView } from '../../../main/ets/models/AppModels';
import { StatsPeriod } from '../../../main/ets/models/Enums';
import { StatsPeriodService } from '../../../main/ets/services/StatsPeriodService';

export default function statsPeriodTest(): void {
  describe('StatsPeriod', (): void => {
    it('buildsChronologicalDayWeekAndMonthViewsEndingAtCurrentPeriod', 0, (): void => {
      const records: DailyRecord[] = [
        new DailyRecord('2026-07-30', 4, 1),
        new DailyRecord('2026-07-29', 2, 0),
        new DailyRecord('2026-07-20', 3, 0),
        new DailyRecord('2026-06-15', 0, 4),
        new DailyRecord('2025-12-31', 7, 0)
      ];
      const day: StatsPeriodView = StatsPeriodService.build(records, '2026-07-30', StatsPeriod.DAY);
      const week: StatsPeriodView = StatsPeriodService.build(records, '2026-07-30', StatsPeriod.WEEK);
      const month: StatsPeriodView = StatsPeriodService.build(records, '2026-07-30', StatsPeriod.MONTH);
      const supported: StatsPeriod[] = StatsPeriodService.supportedPeriods();

      expect(supported.length).assertEqual(3);
      expect(supported[0]).assertEqual(StatsPeriod.DAY);
      expect(supported[1]).assertEqual(StatsPeriod.WEEK);
      expect(supported[2]).assertEqual(StatsPeriod.MONTH);
      expect(day.totalCount).assertEqual(5);
      expect(day.buckets.length).assertEqual(7);
      expect(day.title).assertEqual('近 7 日每日趋势');
      expect(day.buckets[day.buckets.length - 1].label).assertEqual('07/30');
      expect(day.buckets[day.buckets.length - 1].totalCount).assertEqual(5);
      expect(week.totalCount).assertEqual(7);
      expect(week.buckets.length).assertEqual(8);
      expect(week.title).assertEqual('近 8 周趋势');
      expect(week.buckets[week.buckets.length - 1].totalCount).assertEqual(7);
      expect(month.totalCount).assertEqual(10);
      expect(month.buckets.length).assertEqual(12);
      expect(month.title).assertEqual('近 12 月趋势');
      expect(month.buckets[month.buckets.length - 1].label).assertEqual('07月');
    });
  });
}
