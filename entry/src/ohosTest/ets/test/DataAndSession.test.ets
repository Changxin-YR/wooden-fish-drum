import { describe, expect, it } from '@ohos/hypium';
import { JsonCodec } from '../../../main/ets/data/JsonCodec';
import { LocalStoreAdapter } from '../../../main/ets/data/LocalStoreAdapter';
import { DailyRecord } from '../../../main/ets/models/AppModels';
import { SessionMode, SoundType, ThemeMode, UserMode } from '../../../main/ets/models/Enums';
import { StatsRepository } from '../../../main/ets/repositories/StatsRepository';
import { SessionService } from '../../../main/ets/services/SessionService';

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

class ReorderedWriteStore implements LocalStoreAdapter {
  private value: string = '';
  private writeIndex: number = 0;

  async getString(_key: string, fallback: string): Promise<string> {
    return this.value.length > 0 ? this.value : fallback;
  }

  async putString(_key: string, value: string): Promise<void> {
    const delay: number = Math.max(0, 40 - this.writeIndex * 15);
    this.writeIndex++;
    await new Promise<void>((resolve: () => void): void => {
      setTimeout(resolve, delay);
    });
    this.value = value;
  }

  async remove(_key: string): Promise<void> {
    this.value = '';
  }
}

export default function dataAndSessionTest(): void {
  describe('DataAndSession', (): void => {
    it('loadsSafeDefaultsFromInvalidSettings', 0, (): void => {
      expect(JsonCodec.decodeSettings('{broken').initialized).assertTrue();
      expect(JsonCodec.decodeSettings('{broken').userMode).assertEqual(UserMode.GENERAL);
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

    it('persistsRapidHitsInOrder', 0, async (): Promise<void> => {
      const memory: ReorderedWriteStore = new ReorderedWriteStore();
      const repository: StatsRepository = new StatsRepository(memory);
      await Promise.all([
        repository.increment('2026-07-30', false),
        repository.increment('2026-07-30', false),
        repository.increment('2026-07-30', false)
      ]);
      const restored: StatsRepository = new StatsRepository(memory);
      expect((await restored.summary('2026-07-30')).totalCount).assertEqual(3);
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
      expect(session.state.targetCompleted).assertTrue();
      expect(session.state.currentCount).assertEqual(3);
      expect(session.recordManualHit()).assertFalse();
      expect(session.state.currentCount).assertEqual(3);
    });

    it('stopsAutoImmediatelyWhenAnotherModeIsSelected', 0, (): void => {
      const session: SessionService = new SessionService();
      session.selectMode(SessionMode.AUTO, 108, 1000);
      expect(session.hasTimer()).assertTrue();
      session.selectMode(SessionMode.TARGET, 3, 1000);
      expect(session.hasTimer()).assertFalse();
      expect(session.state.mode).assertEqual(SessionMode.TARGET);
      expect(session.state.targetCount).assertEqual(3);
    });

    it('togglesAutoOffIntoFreeMode', 0, (): void => {
      const session: SessionService = new SessionService();
      session.selectMode(SessionMode.AUTO, 108, 1000);
      session.selectMode(SessionMode.AUTO, 108, 1000);
      expect(session.hasTimer()).assertFalse();
      expect(session.state.mode).assertEqual(SessionMode.FREE);
    });

    it('migratesLegacyModeAndPreservesPreferences', 0, (): void => {
      const legacy: string = JSON.stringify({
        initialized: true,
        userMode: UserMode.PROGRAMMER,
        themeMode: ThemeMode.DARK,
        currentText: '保持专注',
        soundType: SoundType.DEEP,
        volume: 0.35
      });
      expect(JsonCodec.decodeSettings(legacy).userMode).assertEqual(UserMode.GENERAL);
      expect(JsonCodec.decodeSettings(legacy).currentText).assertEqual('保持专注');
      expect(JsonCodec.decodeSettings(legacy).themeMode).assertEqual(ThemeMode.DARK);
      expect(JsonCodec.decodeSettings(legacy).soundType).assertEqual(SoundType.DEEP);
      expect(JsonCodec.decodeSettings(legacy).volume).assertEqual(0.35);
    });
  });
}
