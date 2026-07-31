import { describe, expect, it } from '@ohos/hypium';
import { DailyRecord, StatsPeriodView } from '../../../main/ets/models/AppModels';
import { LocalStoreAdapter } from '../../../main/ets/data/LocalStoreAdapter';
import { SceneMode, StatsPeriod, ToolType } from '../../../main/ets/models/Enums';
import { PracticeSession, PracticeSessionDraft } from '../../../main/ets/models/PracticeModels';
import { PracticeSessionRepository } from '../../../main/ets/repositories/PracticeSessionRepository';
import { SettingsRepository } from '../../../main/ets/repositories/SettingsRepository';
import { StatsRepository } from '../../../main/ets/repositories/StatsRepository';
import { StatsPeriodService } from '../../../main/ets/services/StatsPeriodService';
import { AppStore } from '../../../main/ets/stores/AppStore';
import { DateUtil } from '../../../main/ets/utils/DateUtil';

class StatsMemoryStore implements LocalStoreAdapter {
  private values: Map<string, string> = new Map<string, string>();

  async getString(key: string, fallback: string): Promise<string> {
    return this.values.get(key) ?? fallback;
  }

  async putString(key: string, value: string): Promise<void> {
    this.values.set(key, value);
  }

  async remove(key: string): Promise<void> {
    this.values.delete(key);
  }
}

function record(date: string, woodenFishCount: number, beadsCount: number,
  durationSeconds: number, incenseSeconds: number): DailyRecord {
  const value: DailyRecord = new DailyRecord(date, woodenFishCount, beadsCount, durationSeconds);
  value.woodenFishCount = woodenFishCount;
  value.beadsCount = beadsCount;
  value.incenseSeconds = incenseSeconds;
  return value;
}

export default function statsPeriodTest(): void {
  describe('StatsPeriod', (): void => {
    it('keepsCountPracticeDurationAndIncenseDurationIndependent', 0, (): void => {
      const records: DailyRecord[] = [record('2026-07-30', 4, 3, 900, 600)];
      const view: StatsPeriodView = StatsPeriodService.build(records, [], '2026-07-30', StatsPeriod.DAY);

      expect(view.totalCount).assertEqual(7);
      expect(view.durationSeconds).assertEqual(900);
      expect(view.incenseSeconds).assertEqual(600);
      expect(view.woodenFishCount).assertEqual(4);
      expect(view.beadsCount).assertEqual(3);
      expect(view.countMax).assertEqual(7);
      expect(view.durationMaxSeconds).assertEqual(900);
    });

    it('buildsTodayCurrentWeekCurrentMonthAndAllViews', 0, (): void => {
      const records: DailyRecord[] = [
        record('2026-07-30', 4, 1, 300, 0),
        record('2026-07-27', 2, 0, 120, 0),
        record('2026-07-20', 3, 0, 180, 0),
        record('2026-06-15', 0, 4, 240, 120),
        record('2025-12-31', 7, 0, 420, 0)
      ];
      const day: StatsPeriodView = StatsPeriodService.build(records, [], '2026-07-30', StatsPeriod.DAY);
      const week: StatsPeriodView = StatsPeriodService.build(records, [], '2026-07-30', StatsPeriod.WEEK);
      const month: StatsPeriodView = StatsPeriodService.build(records, [], '2026-07-30', StatsPeriod.MONTH);
      const all: StatsPeriodView = StatsPeriodService.build(records, [], '2026-07-30', StatsPeriod.YEAR);

      expect(day.scopeLabel).assertEqual('今日');
      expect(day.totalCount).assertEqual(5);
      expect(week.scopeLabel).assertEqual('本周');
      expect(week.totalCount).assertEqual(7);
      expect(month.scopeLabel).assertEqual('本月');
      expect(month.totalCount).assertEqual(10);
      expect(all.scopeLabel).assertEqual('全部');
      expect(all.totalCount).assertEqual(21);
    });

    it('keepsLegacyDailyTotalsInTrendWithoutInventingSessions', 0, (): void => {
      const legacy: DailyRecord[] = [new DailyRecord('2026-07-30', 2, 1, 90)];
      const view: StatsPeriodView = StatsPeriodService.build(legacy, [], '2026-07-30', StatsPeriod.DAY);

      expect(view.buckets.length).assertEqual(7);
      expect(view.buckets[6].totalCount).assertEqual(3);
      expect(view.recentSessions.length).assertEqual(0);
    });

    it('keepsReferenceSummaryUnitsAndRealRecentSessionsIndependent', 0, (): void => {
      const records: DailyRecord[] = [record('2026-07-30', 19, 40, 38, 0)];
      const session: PracticeSession = new PracticeSession('today-beads', ToolType.BEADS, SceneMode.DAILY,
        1000, 39000, 40, 0, 38, true, '2026-07-30');
      const today: StatsPeriodView = StatsPeriodService.build(records, [session],
        '2026-07-30', StatsPeriod.DAY);

      expect(today.totalCount).assertEqual(59);
      expect(today.durationSeconds).assertEqual(38);
      expect(today.incenseSeconds).assertEqual(0);
      expect(today.recentSessions.length).assertEqual(1);
    });

    it('sortsOnlyRealRecentSessionsByStartTimeDescending', 0, (): void => {
      const older: PracticeSession = new PracticeSession('older', ToolType.WOODEN_FISH, SceneMode.DAILY,
        1000, 2000, 2, 0, 1, true, '2026-07-30');
      const newer: PracticeSession = new PracticeSession('newer', ToolType.INCENSE, SceneMode.MINDFUL,
        3000, 5000, 0, 0, 2, true, '2026-07-30');
      const view: StatsPeriodView = StatsPeriodService.build([], [older, newer], '2026-07-30', StatsPeriod.DAY);

      expect(view.recentSessions.length).assertEqual(2);
      expect(view.recentSessions[0].id).assertEqual('newer');
      expect(view.recentSessions[1].id).assertEqual('older');
    });

    it('addsRealWoodenFishAndBeadsSessionDurationWithoutRepeatingCounts', 0, async (): Promise<void> => {
      const memory: StatsMemoryStore = new StatsMemoryStore();
      const store: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory),
        new PracticeSessionRepository(memory));
      await store.initialize();
      await store.recordHit(ToolType.BEADS, false);
      const startTime: number = Date.now() - 120000;
      await store.savePracticeSession(new PracticeSessionDraft(ToolType.BEADS, startTime,
        startTime + 120000, 1, 0, 120, true));

      const today: DailyRecord | undefined = store.allRecords.find((item: DailyRecord): boolean =>
        item.date === DateUtil.toKey(new Date(startTime)));
      expect(today === undefined).assertFalse();
      expect(today?.totalCount).assertEqual(1);
      expect(today?.durationSeconds).assertEqual(120);
      expect(today?.incenseSeconds).assertEqual(0);
      expect(today?.sessionCount).assertEqual(1);
    });
  });
}
