import { LocalStoreAdapter } from '../data/LocalStoreAdapter';
import { DailyRecord, StatsSummary } from '../models/AppModels';
import { DailyStats, PracticeSession } from '../models/PracticeModels';
import { ToolType } from '../models/Enums';
import { DateUtil } from '../utils/DateUtil';
import { StatsMigration } from '../utils/StatsMigration';

const STATS_KEY: string = 'daily_records';
const APPLIED_SESSION_IDS_KEY: string = 'applied_session_ids_v2';

export class StatsRepository {
  private readonly store: LocalStoreAdapter;
  private records: DailyStats[] = [];
  private appliedSessionIds: string[] = [];
  private loaded: boolean = false;
  private appliedIdsLoaded: boolean = false;
  private mutationQueue: Promise<void> = Promise.resolve();

  constructor(store: LocalStoreAdapter) {
    this.store = store;
  }

  async replace(records: DailyRecord[]): Promise<void> {
    const snapshot: DailyStats[] = records.map((item: DailyRecord): DailyStats =>
      new DailyStats(item.date, item.manualCount, item.autoCount, 0, 0, 0, item.durationSeconds, 0));
    const operation: Promise<void> = this.mutationQueue.then(async (): Promise<void> => {
      this.records = snapshot;
      this.loaded = true;
      await this.persist();
    });
    this.mutationQueue = operation.catch((): void => {});
    await operation;
  }

  async increment(date: string, automatic: boolean): Promise<DailyRecord> {
    return this.incrementTool(date, ToolType.WOODEN_FISH, automatic);
  }

  async incrementTool(date: string, toolType: ToolType, automatic: boolean): Promise<DailyRecord> {
    let result: DailyRecord = new DailyRecord(date);
    const operation: Promise<void> = this.mutationQueue.then(async (): Promise<void> => {
      await this.loadStats();
      const record: DailyStats = this.findOrCreate(date);
      if (toolType === ToolType.BEADS && automatic) {
        record.beadsAutoCount++;
      } else if (toolType === ToolType.BEADS) {
        record.beadsManualCount++;
      } else if (automatic) {
        record.woodenFishAutoCount++;
      } else {
        record.woodenFishManualCount++;
      }
      await this.persist();
      result = this.toLegacy(record);
    });
    this.mutationQueue = operation.catch((): void => {});
    await operation;
    return result;
  }

  async applySession(session: PracticeSession): Promise<boolean> {
    let applied: boolean = false;
    const operation: Promise<void> = this.mutationQueue.then(async (): Promise<void> => {
      await this.loadStats();
      await this.loadAppliedSessionIds();
      if (this.appliedSessionIds.includes(session.id)) {
        return;
      }
      const date: string = session.date.length > 0 ? session.date : DateUtil.toKey(new Date(session.startTime));
      const record: DailyStats = this.findOrCreate(date);
      if (session.toolType === ToolType.WOODEN_FISH) {
        record.woodenFishManualCount += Math.max(0, session.manualCount);
        record.woodenFishAutoCount += Math.max(0, session.automaticCount);
      } else if (session.toolType === ToolType.BEADS) {
        record.beadsManualCount += Math.max(0, session.manualCount);
        record.beadsAutoCount += Math.max(0, session.automaticCount);
      } else {
        record.incenseSeconds += Math.max(0, session.durationSeconds);
      }
      record.practiceSeconds += Math.max(0, session.durationSeconds);
      record.sessionCount++;
      this.appliedSessionIds.push(session.id);
      await this.persist();
      await this.persistAppliedSessionIds();
      applied = true;
    });
    this.mutationQueue = operation.catch((): void => {});
    await operation;
    return applied;
  }

  async allStats(): Promise<DailyStats[]> {
    await this.mutationQueue;
    await this.loadStats();
    return this.records.map((item: DailyStats): DailyStats => StatsMigration.copy(item));
  }

  async summary(today: string): Promise<StatsSummary> {
    await this.mutationQueue;
    await this.loadStats();
    const result: StatsSummary = new StatsSummary();
    this.records.forEach((record: DailyStats): void => {
      result.totalCount += record.totalCount;
      result.manualCount += record.woodenFishManualCount + record.beadsManualCount;
      result.autoCount += record.woodenFishAutoCount + record.beadsAutoCount;
      result.maxDailyCount = Math.max(result.maxDailyCount, record.totalCount);
      if (record.date === today) {
        result.todayCount = record.totalCount;
      }
    });
    result.streakDays = this.streak(today);
    return result;
  }

  async recentDays(today: string, count: number): Promise<DailyRecord[]> {
    await this.mutationQueue;
    await this.loadStats();
    const result: DailyRecord[] = [];
    for (let offset: number = count - 1; offset >= 0; offset--) {
      const key: string = DateUtil.addDays(today, -offset);
      const record: DailyStats | undefined =
        this.records.find((item: DailyStats): boolean => item.date === key);
      result.push(record === undefined ? new DailyRecord(key) : this.toLegacy(record));
    }
    return result;
  }

  async allRecords(): Promise<DailyRecord[]> {
    await this.mutationQueue;
    await this.loadStats();
    return this.records.map((item: DailyStats): DailyRecord => this.toLegacy(item));
  }

  async clearDate(date: string): Promise<void> {
    const operation: Promise<void> = this.mutationQueue.then(async (): Promise<void> => {
      await this.loadStats();
      this.records = this.records.filter((item: DailyStats): boolean => item.date !== date);
      await this.persist();
    });
    this.mutationQueue = operation.catch((): void => {});
    await operation;
  }

  async clear(): Promise<void> {
    const operation: Promise<void> = this.mutationQueue.then(async (): Promise<void> => {
      this.records = [];
      this.appliedSessionIds = [];
      this.loaded = true;
      this.appliedIdsLoaded = true;
      await this.store.remove(STATS_KEY);
      await this.store.remove(APPLIED_SESSION_IDS_KEY);
    });
    this.mutationQueue = operation.catch((): void => {});
    await operation;
  }

  private async loadStats(): Promise<void> {
    if (!this.loaded) {
      this.records = StatsMigration.decode(await this.store.getString(STATS_KEY, ''));
      this.loaded = true;
    }
  }

  private async loadAppliedSessionIds(): Promise<void> {
    if (this.appliedIdsLoaded) {
      return;
    }
    const snapshot: string = await this.store.getString(APPLIED_SESSION_IDS_KEY, '');
    try {
      const parsed: string[] = JSON.parse(snapshot) as string[];
      this.appliedSessionIds = Array.isArray(parsed) ? parsed : [];
    } catch {
      this.appliedSessionIds = [];
    }
    this.appliedIdsLoaded = true;
  }

  private findOrCreate(date: string): DailyStats {
    let record: DailyStats | undefined =
      this.records.find((item: DailyStats): boolean => item.date === date);
    if (record === undefined) {
      record = new DailyStats(date);
      this.records.push(record);
    }
    return record;
  }

  private streak(today: string): number {
    let days: number = 0;
    while (true) {
      const key: string = DateUtil.addDays(today, -days);
      const record: DailyStats | undefined =
        this.records.find((item: DailyStats): boolean => item.date === key && item.totalCount > 0);
      if (record === undefined) {
        break;
      }
      days++;
    }
    return days;
  }

  private async persist(): Promise<void> {
    await this.store.putString(STATS_KEY, StatsMigration.encode(this.records));
  }

  private async persistAppliedSessionIds(): Promise<void> {
    await this.store.putString(APPLIED_SESSION_IDS_KEY, JSON.stringify(this.appliedSessionIds));
  }

  private toLegacy(item: DailyStats): DailyRecord {
    return new DailyRecord(item.date,
      item.woodenFishManualCount + item.beadsManualCount,
      item.woodenFishAutoCount + item.beadsAutoCount,
      item.practiceSeconds);
  }
}
