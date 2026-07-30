import { describe, expect, it } from '@ohos/hypium';
import { DailyRecord, StatsPeriodView } from '../../../main/ets/models/AppModels';
import { StatsPeriod } from '../../../main/ets/models/Enums';
import { StatsPeriodService } from '../../../main/ets/services/StatsPeriodService';

export default function statsPeriodTest(): void {
  describe('StatsPeriod', (): void => {
    it('buildsDistinctDayWeekMonthAndYearViews', 0, (): void => {
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
      const year: StatsPeriodView = StatsPeriodService.build(records, '2026-07-30', StatsPeriod.YEAR);

      expect(day.totalCount).assertEqual(5);
      expect(day.buckets.length).assertEqual(7);
      expect(day.title).assertEqual('近 7 日每日趋势');
      expect(week.totalCount).assertEqual(7);
      expect(week.buckets.length).assertEqual(8);
      expect(week.title).assertEqual('近 8 周趋势');
      expect(month.totalCount).assertEqual(10);
      expect(month.buckets.length).assertEqual(12);
      expect(month.title).assertEqual('近 12 月趋势');
      expect(year.totalCount).assertEqual(14);
      expect(year.buckets.length).assertEqual(5);
      expect(year.title).assertEqual('近 5 年趋势');
    });
  });
}
