import { describe, expect, it } from '@ohos/hypium';
import { LocalStoreAdapter } from '../../../main/ets/data/LocalStoreAdapter';
import { DailyStats, IncenseSnapshot, PracticeSession } from '../../../main/ets/models/PracticeModels';
import { PracticeStatus, SceneMode, ToolType } from '../../../main/ets/models/Enums';
import { PracticeSessionRepository } from '../../../main/ets/repositories/PracticeSessionRepository';
import { StatsRepository } from '../../../main/ets/repositories/StatsRepository';
import { StatsMigration } from '../../../main/ets/utils/StatsMigration';

class PracticeMemoryStore implements LocalStoreAdapter {
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

export default function practiceRepositoryTest(): void {
  describe('PracticeRepository', (): void => {
    it('migratesLegacyDailyRecordsIntoWoodenFishStats', 0, (): void => {
      const legacy: string = JSON.stringify([
        { date: '2026-07-30', manualCount: 4, autoCount: 2, durationSeconds: 30 }
      ]);
      const records: DailyStats[] = StatsMigration.decode(legacy);
      expect(records.length).assertEqual(1);
      expect(records[0].woodenFishManualCount).assertEqual(4);
      expect(records[0].woodenFishAutoCount).assertEqual(2);
      expect(records[0].practiceSeconds).assertEqual(30);
      expect(records[0].incenseSeconds).assertEqual(0);
    });

    it('keepsSessionIdsUniqueAndReturnsNewestFirst', 0, async (): Promise<void> => {
      const repository: PracticeSessionRepository =
        new PracticeSessionRepository(new PracticeMemoryStore());
      const older: PracticeSession = new PracticeSession('s1', ToolType.BEADS, SceneMode.DAILY,
        1000, 4000, 3, 0, 3, true);
      const newer: PracticeSession = new PracticeSession('s2', ToolType.INCENSE, SceneMode.MINDFUL,
        5000, 65000, 0, 0, 60, true);
      expect(await repository.append(older)).assertTrue();
      expect(await repository.append(older)).assertFalse();
      expect(await repository.append(newer)).assertTrue();
      const recent: PracticeSession[] = await repository.recent(10);
      expect(recent.length).assertEqual(2);
      expect(recent[0].id).assertEqual('s2');
    });

    it('clearsOnlySessionsFromRequestedDate', 0, async (): Promise<void> => {
      const repository: PracticeSessionRepository =
        new PracticeSessionRepository(new PracticeMemoryStore());
      await repository.append(new PracticeSession('s1', ToolType.WOODEN_FISH, SceneMode.DAILY,
        1000, 2000, 1, 0, 1, true, '2026-07-30'));
      await repository.append(new PracticeSession('s2', ToolType.BEADS, SceneMode.DAILY,
        3000, 4000, 2, 0, 1, true, '2026-07-31'));
      await repository.clearDate('2026-07-31');
      const remaining: PracticeSession[] = await repository.all();
      expect(remaining.length).assertEqual(1);
      expect(remaining[0].id).assertEqual('s1');
    });

    it('appliesEachSessionToDailyStatsOnce', 0, async (): Promise<void> => {
      const repository: StatsRepository = new StatsRepository(new PracticeMemoryStore());
      const session: PracticeSession = new PracticeSession('s1', ToolType.BEADS, SceneMode.DAILY,
        1000, 4000, 3, 2, 3, true, '2026-07-31');
      expect(await repository.applySession(session)).assertTrue();
      expect(await repository.applySession(session)).assertFalse();
      const stats: DailyStats[] = await repository.allStats();
      expect(stats.length).assertEqual(1);
      expect(stats[0].beadsManualCount).assertEqual(3);
      expect(stats[0].beadsAutoCount).assertEqual(2);
      expect(stats[0].sessionCount).assertEqual(1);
    });

    it('incrementsLiveBeadsWithoutChangingWoodenFishTotals', 0, async (): Promise<void> => {
      const repository: StatsRepository = new StatsRepository(new PracticeMemoryStore());
      await repository.incrementTool('2026-07-31', ToolType.BEADS, false);
      await repository.incrementTool('2026-07-31', ToolType.BEADS, true);

      const stats: DailyStats[] = await repository.allStats();
      expect(stats[0].woodenFishCount).assertEqual(0);
      expect(stats[0].beadsManualCount).assertEqual(1);
      expect(stats[0].beadsAutoCount).assertEqual(1);
    });

    it('persistsAndClearsActiveIncenseSnapshot', 0, async (): Promise<void> => {
      const store: PracticeMemoryStore = new PracticeMemoryStore();
      const writer: PracticeSessionRepository = new PracticeSessionRepository(store);
      await writer.saveActiveIncense(new IncenseSnapshot(PracticeStatus.PAUSED,
        1000, 900, 61000, 0, false));
      const reader: PracticeSessionRepository = new PracticeSessionRepository(store);

      const restored: IncenseSnapshot | null = await reader.loadActiveIncense();
      expect(restored === null).assertFalse();
      expect(restored?.targetSeconds).assertEqual(900);
      expect(restored?.status).assertEqual(PracticeStatus.PAUSED);
      await reader.clearActiveIncense();
      expect(await reader.loadActiveIncense() === null).assertTrue();
    });
  });
}
