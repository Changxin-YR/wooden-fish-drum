import { JsonCodec } from '../data/JsonCodec';
import { LocalStoreAdapter } from '../data/LocalStoreAdapter';
import { DailyRecord, StatsSummary } from '../models/AppModels';
import { DateUtil } from '../utils/DateUtil';

const STATS_KEY: string = 'daily_records';

export class StatsRepository {
  private readonly store: LocalStoreAdapter;
  private records: DailyRecord[] = [];
  private loaded: boolean = false;

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
    this.records = this.copyRecords(records);
    this.loaded = true;
    await this.persist();
  }

  async increment(date: string, automatic: boolean): Promise<DailyRecord> {
    await this.load();
    let record: DailyRecord | undefined = this.records.find((item: DailyRecord): boolean => item.date === date);
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
    return new DailyRecord(record.date, record.manualCount, record.autoCount, record.durationSeconds);
  }

  async summary(today: string): Promise<StatsSummary> {
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
    await this.load();
    const result: DailyRecord[] = [];
    for (let offset: number = count - 1; offset >= 0; offset--) {
      const key: string = DateUtil.addDays(today, -offset);
      const record: DailyRecord | undefined =
        this.records.find((item: DailyRecord): boolean => item.date === key);
      result.push(record === undefined ? new DailyRecord(key) :
        new DailyRecord(record.date, record.manualCount, record.autoCount, record.durationSeconds));
    }
    return result;
  }

  async clear(): Promise<void> {
    this.records = [];
    this.loaded = true;
    await this.store.remove(STATS_KEY);
  }

  private streak(today: string): number {
    let days: number = 0;
    while (true) {
      const key: string = DateUtil.addDays(today, -days);
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
    await this.store.putString(STATS_KEY, JsonCodec.encodeRecords(this.records));
  }

  private copyRecords(records: DailyRecord[]): DailyRecord[] {
    return records.map((item: DailyRecord): DailyRecord =>
      new DailyRecord(item.date, item.manualCount, item.autoCount, item.durationSeconds));
  }
}
