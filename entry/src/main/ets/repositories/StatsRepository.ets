import { JsonCodec } from '../data/JsonCodec';
import { LocalStoreAdapter } from '../data/LocalStoreAdapter';
import { DailyRecord, StatsSummary } from '../models/AppModels';
import { DateUtil } from '../utils/DateUtil';

const STATS_KEY: string = 'daily_records';

export class StatsRepository {
  private readonly store: LocalStoreAdapter;
  private records: DailyRecord[] = [];
  private loaded: boolean = false;
  private mutationQueue: Promise<void> = Promise.resolve();

  constructor(store: LocalStoreAdapter) {
    this.store = store;
  }

  async load(): Promise<DailyRecord[]> {
    if (!this.loaded) {
      this.records = JsonCodec.decodeRecords(await this.store.getString(STATS_KEY, ''));
      this.loaded = true;
    }
    return this.copyRecords(this.records);
  }

  async replace(records: DailyRecord[]): Promise<void> {
    const snapshot: DailyRecord[] = this.copyRecords(records);
    const operation: Promise<void> = this.mutationQueue.then(async (): Promise<void> => {
      this.records = snapshot;
      this.loaded = true;
      await this.persist();
    });
    this.mutationQueue = operation.catch((): void => {});
    await operation;
  }

  async increment(date: string, automatic: boolean): Promise<DailyRecord> {
    let result: DailyRecord = new DailyRecord(date);
    const operation: Promise<void> = this.mutationQueue.then(async (): Promise<void> => {
      await this.load();
      let record: DailyRecord | undefined =
        this.records.find((item: DailyRecord): boolean => item.date === date);
      if (record === undefined) {
        record = new DailyRecord(date);
        this.records.push(record);
      }
      if (automatic) {
        record.autoCount++;
      } else {
        record.manualCount++;
      }
      await this.persist();
      result = new DailyRecord(record.date, record.manualCount, record.autoCount);
    });
    this.mutationQueue = operation.catch((): void => {});
    await operation;
    return result;
  }

  async summary(today: string): Promise<StatsSummary> {
    await this.mutationQueue;
    await this.load();
    const result: StatsSummary = new StatsSummary();
    this.records.forEach((record: DailyRecord): void => {
      result.totalCount += record.totalCount;
      result.manualCount += record.manualCount;
      result.autoCount += record.autoCount;
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
    await this.load();
    const result: DailyRecord[] = [];
    for (let offset: number = count - 1; offset >= 0; offset--) {
      const key: string = DateUtil.addDays(today, -offset);
      const record: DailyRecord | undefined =
        this.records.find((item: DailyRecord): boolean => item.date === key);
      result.push(record === undefined ? new DailyRecord(key) :
        new DailyRecord(record.date, record.manualCount, record.autoCount));
    }
    return result;
  }

  async allRecords(): Promise<DailyRecord[]> {
    await this.mutationQueue;
    return this.load();
  }

  async clear(): Promise<void> {
    const operation: Promise<void> = this.mutationQueue.then(async (): Promise<void> => {
      this.records = [];
      this.loaded = true;
      await this.store.remove(STATS_KEY);
    });
    this.mutationQueue = operation.catch((): void => {});
    await operation;
  }

  private streak(today: string): number {
    const todayRecord: DailyRecord | undefined =
      this.records.find((item: DailyRecord): boolean => item.date === today && item.totalCount > 0);
    const initialOffset: number = todayRecord === undefined ? 1 : 0;
    let days: number = 0;
    while (true) {
      const key: string = DateUtil.addDays(today, -(initialOffset + days));
      const record: DailyRecord | undefined =
        this.records.find((item: DailyRecord): boolean => item.date === key && item.totalCount > 0);
      if (record === undefined) {
        break;
      }
      days++;
    }
    return days;
  }

  private async persist(): Promise<void> {
    this.pruneOldRecords();
    await this.store.putString(STATS_KEY, JsonCodec.encodeRecords(this.records));
  }

  private pruneOldRecords(): void {
    const currentYear: number = Number(DateUtil.todayKey().slice(0, 4));
    const cutoff: string = `${currentYear - 5}-01-01`;
    const kept: DailyRecord[] = this.records.filter((record: DailyRecord): boolean =>
      record.date >= cutoff);
    this.records = kept;
  }

  private copyRecords(records: DailyRecord[]): DailyRecord[] {
    return records.map((item: DailyRecord): DailyRecord =>
      new DailyRecord(item.date, item.manualCount, item.autoCount));
  }
}
