import { describe, expect, it } from '@ohos/hypium';
import { JsonCodec } from '../../../main/ets/data/JsonCodec';
import { LocalStoreAdapter } from '../../../main/ets/data/LocalStoreAdapter';
import { DailyRecord } from '../../../main/ets/models/AppModels';
import { UserMode } from '../../../main/ets/models/Enums';
import { SettingsRepository } from '../../../main/ets/repositories/SettingsRepository';
import { StatsRepository } from '../../../main/ets/repositories/StatsRepository';
import { SessionService } from '../../../main/ets/services/SessionService';
import { AppStore } from '../../../main/ets/stores/AppStore';

class MemoryStore implements LocalStoreAdapter {
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

export default function dataAndSessionTest(): void {
  describe('DataAndSession', (): void => {
    it('loadsSafeDefaultsFromInvalidSettings', 0, (): void => {
      expect(JsonCodec.decodeSettings('{broken').initialized).assertFalse();
      expect(JsonCodec.decodeSettings('{broken').userMode).assertEqual(UserMode.PROGRAMMER);
    });

    it('derivesTotalsAndSevenOrderedDays', 0, async (): Promise<void> => {
      const repository: StatsRepository = new StatsRepository(new MemoryStore());
      await repository.replace([
        new DailyRecord('2026-07-28', 2, 3),
        new DailyRecord('2026-07-29', 4, 1)
      ]);
      expect((await repository.summary('2026-07-29')).totalCount).assertEqual(10);
      const recent: DailyRecord[] = await repository.recentDays('2026-07-29', 7);
      expect(recent.length).assertEqual(7);
      expect(recent[6].date).assertEqual('2026-07-29');
    });

    it('countsRapidHitsAndStopsExactlyAtTarget', 0, (): void => {
      const session: SessionService = new SessionService();
      for (let index: number = 0; index < 100; index++) {
        session.recordManualHit();
      }
      expect(session.state.currentCount).assertEqual(100);
      session.startTarget(3);
      session.recordManualHit();
      session.recordManualHit();
      session.recordManualHit();
      expect(session.state.running).assertFalse();
      expect(session.state.currentCount).assertEqual(3);
    });

    it('rejectsASecondAutoTimer', 0, (): void => {
      const session: SessionService = new SessionService();
      expect(session.startAuto(1000)).assertTrue();
      expect(session.startAuto(1000)).assertFalse();
      session.stop();
    });

    it('initializesSelectedMode', 0, async (): Promise<void> => {
      const memory: MemoryStore = new MemoryStore();
      const store: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
      await store.selectInitialMode(UserMode.MONK);
      expect(store.settings.initialized).assertTrue();
      expect(store.settings.currentText).assertEqual('功德+1');
    });
  });
}
