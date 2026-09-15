import { describe, expect, it } from '@ohos/hypium';
import { JsonCodec } from '../../../main/ets/data/JsonCodec';
import { LocalStoreAdapter } from '../../../main/ets/data/LocalStoreAdapter';
import { AppSettings, DailyRecord, SessionState } from '../../../main/ets/models/AppModels';
import { SessionMode, SoundType, ThemeMode, UserMode } from '../../../main/ets/models/Enums';
import { StatsRepository } from '../../../main/ets/repositories/StatsRepository';
import { SettingsRepository } from '../../../main/ets/repositories/SettingsRepository';
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

class FailingSettingsStore implements LocalStoreAdapter {
  failSettingsWrites: boolean = false;
  private values: Map<string, string> = new Map<string, string>();

  async getString(key: string, fallback: string): Promise<string> {
    return this.values.get(key) ?? fallback;
  }

  async putString(key: string, value: string): Promise<void> {
    if (key === 'settings' && this.failSettingsWrites) {
      throw new Error('settings write failed');
    }
    this.values.set(key, value);
  }

  async remove(key: string): Promise<void> {
    this.values.delete(key);
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

    it('preservesStreakBeforeTodaysFirstHit', 0, async (): Promise<void> => {
      const repository: StatsRepository = new StatsRepository(new MemoryStore());
      await repository.replace([
        new DailyRecord('2026-08-01', 1, 0),
        new DailyRecord('2026-08-02', 1, 0)
      ]);
      expect((await repository.summary('2026-08-03')).streakDays).assertEqual(2);
    });

    it('includesTodayAfterFirstHitAndStopsAtGaps', 0, async (): Promise<void> => {
      const active: StatsRepository = new StatsRepository(new MemoryStore());
      await active.replace([
        new DailyRecord('2026-08-01', 1, 0),
        new DailyRecord('2026-08-02', 1, 0),
        new DailyRecord('2026-08-03', 1, 0)
      ]);
      expect((await active.summary('2026-08-03')).streakDays).assertEqual(3);

      const broken: StatsRepository = new StatsRepository(new MemoryStore());
      await broken.replace([new DailyRecord('2026-08-01', 1, 0)]);
      expect((await broken.summary('2026-08-03')).streakDays).assertEqual(0);
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

    it('persistsLatestSettingsWhenWritesCompleteOutOfOrder', 0, async (): Promise<void> => {
      const memory: ReorderedWriteStore = new ReorderedWriteStore();
      const repository: SettingsRepository = new SettingsRepository(memory);
      const first: AppSettings = JsonCodec.createDefaultSettings();
      first.currentText = '第一次';
      const second: AppSettings = JsonCodec.createDefaultSettings();
      second.currentText = '第二次';

      await Promise.all([repository.save(first), repository.save(second)]);

      expect((await repository.load()).currentText).assertEqual('第二次');
    });

    it('resetsOnlyHomeTextCountWhenTextChanges', 0, async (): Promise<void> => {
      const memory: MemoryStore = new MemoryStore();
      const store: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
      await store.initialize();
      await store.recordHit(false);
      await store.recordHit(false);

      await store.saveCustomText('今日好运');
      expect(store.summary.todayCount).assertEqual(2);
      expect(store.currentTextCount()).assertEqual(0);

      await store.recordHit(false);
      expect(store.currentTextCount()).assertEqual(1);
      await store.saveCustomText('今日好运');
      expect(store.currentTextCount()).assertEqual(1);

      const restored: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
      await restored.initialize();
      expect(restored.settings.currentText).assertEqual('今日好运');
      expect(restored.summary.todayCount).assertEqual(3);
      expect(restored.currentTextCount()).assertEqual(1);

      store.settings.homeCountDate = '2000-01-01';
      expect(store.currentTextCount()).assertEqual(3);

      await restored.clearStats();
      await restored.recordHit(false);
      expect(restored.currentTextCount()).assertEqual(1);
      const afterClear: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
      await afterClear.initialize();
      expect(afterClear.currentTextCount()).assertEqual(1);
    });

    it('reportsAndRepairsFailedBaselineResetAfterClearingStats', 0, async (): Promise<void> => {
      const memory: FailingSettingsStore = new FailingSettingsStore();
      const store: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
      await store.initialize();
      await store.recordHit(false);
      await store.recordHit(false);
      await store.saveCustomText('今日好运');

      memory.failSettingsWrites = true;
      expect(await store.clearStats()).assertFalse();
      memory.failSettingsWrites = false;

      const restored: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
      await restored.initialize();
      await restored.recordHit(false);
      expect(restored.currentTextCount()).assertEqual(1);
    });

    it('createsIndependentSettingsSnapshotsForImmediateUiRefresh', 0, async (): Promise<void> => {
      const memory: MemoryStore = new MemoryStore();
      const store: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
      await store.initialize();

      const before: AppSettings = store.settingsSnapshot();
      store.settings.volume = 0.35;
      store.settings.currentText = '平安喜乐';
      const after: AppSettings = store.settingsSnapshot();

      expect(before === after).assertFalse();
      expect(before.volume).assertEqual(0.7);
      expect(before.currentText).assertEqual('功德+1');
      expect(after.volume).assertEqual(0.35);
      expect(after.currentText).assertEqual('平安喜乐');
    });

    it('updatesRuntimeSettingsBeforePersistenceCompletes', 0, async (): Promise<void> => {
      const memory: ReorderedWriteStore = new ReorderedWriteStore();
      const store: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory));
      await store.initialize();

      const themeSave: Promise<boolean> = store.setThemeMode(ThemeMode.DARK);
      expect(store.settings.themeMode).assertEqual(ThemeMode.DARK);
      expect(store.settingsSnapshot().themeMode).assertEqual(ThemeMode.DARK);
      await themeSave;

      const textSave: Promise<boolean> = store.saveCustomText('诸事顺意');
      expect(store.settings.currentText).assertEqual('诸事顺意');
      expect(store.settingsSnapshot().currentText).assertEqual('诸事顺意');
      await textSave;
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

    it('createsCompleteIndependentSessionSnapshots', 0, (): void => {
      const source: SessionState = new SessionState();
      source.mode = SessionMode.TARGET;
      source.hitSequence = 7;
      source.running = true;
      source.paused = true;
      source.targetCompleted = true;
      source.currentCount = 6;
      source.targetCount = 8;
      source.startedAt = 1234;

      const snapshot: SessionState = source.snapshot();
      source.currentCount = 99;

      expect(snapshot === source).assertFalse();
      expect(snapshot.mode).assertEqual(SessionMode.TARGET);
      expect(snapshot.hitSequence).assertEqual(7);
      expect(snapshot.running).assertTrue();
      expect(snapshot.paused).assertTrue();
      expect(snapshot.targetCompleted).assertTrue();
      expect(snapshot.currentCount).assertEqual(6);
      expect(snapshot.targetCount).assertEqual(8);
      expect(snapshot.startedAt).assertEqual(1234);
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

    it('incrementsOneSharedHitSequenceForManualAndAutoFeedback', 0, (): void => {
      const session: SessionService = new SessionService();
      session.startFree();
      session.recordManualHit();
      expect(session.state.hitSequence).assertEqual(1);
      session.selectMode(SessionMode.AUTO, 108, 2000);
      session.recordAutoHit();
      expect(session.state.hitSequence).assertEqual(2);
      session.stop();
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
