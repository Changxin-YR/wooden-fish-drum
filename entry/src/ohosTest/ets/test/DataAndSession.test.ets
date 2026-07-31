import { describe, expect, it } from '@ohos/hypium';
import { JsonCodec } from '../../../main/ets/data/JsonCodec';
import { LocalStoreAdapter } from '../../../main/ets/data/LocalStoreAdapter';
import { DailyRecord } from '../../../main/ets/models/AppModels';
import { SceneMode, SessionMode, SoundType, ThemeMode, ToolType, UserMode } from '../../../main/ets/models/Enums';
import { PracticeSession } from '../../../main/ets/models/PracticeModels';
import { PracticeSessionRepository } from '../../../main/ets/repositories/PracticeSessionRepository';
import { SettingsRepository } from '../../../main/ets/repositories/SettingsRepository';
import { StatsRepository } from '../../../main/ets/repositories/StatsRepository';
import { SessionService } from '../../../main/ets/services/SessionService';
import { AppStore } from '../../../main/ets/stores/AppStore';
import { DateUtil } from '../../../main/ets/utils/DateUtil';

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
      expect(JsonCodec.decodeSettings('{broken').initialized).assertFalse();
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
      expect(JsonCodec.decodeSettings(legacy).userMode).assertEqual(UserMode.PROGRAMMER);
      expect(JsonCodec.decodeSettings(legacy).currentText).assertEqual('保持专注');
      expect(JsonCodec.decodeSettings(legacy).themeMode).assertEqual(ThemeMode.DARK);
      expect(JsonCodec.decodeSettings(legacy).soundType).assertEqual(SoundType.DEEP);
      expect(JsonCodec.decodeSettings(legacy).volume).assertEqual(0.35);
    });

    it('clearsOnlyTodayStatsAndSessionsWhileKeepingSettings', 0, async (): Promise<void> => {
      const memory: MemoryStore = new MemoryStore();
      const settingsRepository: SettingsRepository = new SettingsRepository(memory);
      const statsRepository: StatsRepository = new StatsRepository(memory);
      const sessionRepository: PracticeSessionRepository = new PracticeSessionRepository(memory);
      const store: AppStore = new AppStore(settingsRepository, statsRepository, sessionRepository);
      const today: string = DateUtil.todayKey();
      const yesterday: string = DateUtil.addDays(today, -1);
      store.settings.initialized = true;
      await settingsRepository.save(store.settings);
      await statsRepository.increment(today, false);
      await statsRepository.increment(yesterday, false);
      await sessionRepository.append(new PracticeSession('today', ToolType.WOODEN_FISH, SceneMode.DAILY,
        Date.now(), Date.now(), 1, 0, 0, true, today));
      await sessionRepository.append(new PracticeSession('yesterday', ToolType.BEADS, SceneMode.DAILY,
        Date.now() - 86400000, Date.now() - 86400000, 1, 0, 0, true, yesterday));
      await store.initialize();

      await store.clearToday();

      expect(store.settings.initialized).assertTrue();
      expect(store.summary.todayCount).assertEqual(0);
      expect(store.allRecords.length).assertEqual(1);
      expect(store.allRecords[0].date).assertEqual(yesterday);
      expect(store.recentSessions.length).assertEqual(1);
      expect(store.recentSessions[0].id).assertEqual('yesterday');
    });

    it('clearsAllLocalDataAndRestoresFirstLaunchDefaults', 0, async (): Promise<void> => {
      const memory: MemoryStore = new MemoryStore();
      const settingsRepository: SettingsRepository = new SettingsRepository(memory);
      const statsRepository: StatsRepository = new StatsRepository(memory);
      const sessionRepository: PracticeSessionRepository = new PracticeSessionRepository(memory);
      const store: AppStore = new AppStore(settingsRepository, statsRepository, sessionRepository);
      store.settings.initialized = true;
      await settingsRepository.save(store.settings);
      await statsRepository.increment(DateUtil.todayKey(), false);
      await sessionRepository.append(new PracticeSession('session', ToolType.WOODEN_FISH, SceneMode.DAILY,
        Date.now(), Date.now(), 1, 0, 0, true, DateUtil.todayKey()));
      await store.initialize();

      await store.clearAll();

      const restored: AppStore = new AppStore(new SettingsRepository(memory), new StatsRepository(memory),
        new PracticeSessionRepository(memory));
      await restored.initialize();
      expect(restored.settings.initialized).assertFalse();
      expect(restored.summary.totalCount).assertEqual(0);
      expect(restored.allRecords.length).assertEqual(0);
      expect(restored.recentSessions.length).assertEqual(0);
    });
  });
}
