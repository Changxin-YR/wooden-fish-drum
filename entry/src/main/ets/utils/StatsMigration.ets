import { DailyStats } from '../models/PracticeModels';

class StoredDailyStats {
  date: string = '';
  woodenFishManualCount?: number;
  woodenFishAutoCount?: number;
  beadsManualCount?: number;
  beadsAutoCount?: number;
  incenseSeconds?: number;
  practiceSeconds?: number;
  sessionCount?: number;
  manualCount?: number;
  autoCount?: number;
  durationSeconds?: number;
}

export class StatsMigration {
  static decode(snapshot: string): DailyStats[] {
    if (snapshot.length === 0) {
      return [];
    }
    try {
      const parsed: StoredDailyStats[] = JSON.parse(snapshot) as StoredDailyStats[];
      if (!Array.isArray(parsed)) {
        return [];
      }
      const records: DailyStats[] = [];
      parsed.forEach((item: StoredDailyStats): void => {
        if (item === null || typeof item.date !== 'string') {
          return;
        }
        if (typeof item.woodenFishManualCount === 'number') {
          records.push(StatsMigration.fromV2(item));
        } else {
          records.push(StatsMigration.fromLegacy(item));
        }
      });
      return records;
    } catch {
      return [];
    }
  }

  static encode(records: DailyStats[]): string {
    return JSON.stringify(records);
  }

  static copy(record: DailyStats): DailyStats {
    return new DailyStats(record.date, record.woodenFishManualCount, record.woodenFishAutoCount,
      record.beadsManualCount, record.beadsAutoCount, record.incenseSeconds,
      record.practiceSeconds, record.sessionCount);
  }

  private static fromV2(item: StoredDailyStats): DailyStats {
    return new DailyStats(item.date,
      StatsMigration.nonNegative(item.woodenFishManualCount),
      StatsMigration.nonNegative(item.woodenFishAutoCount),
      StatsMigration.nonNegative(item.beadsManualCount),
      StatsMigration.nonNegative(item.beadsAutoCount),
      StatsMigration.nonNegative(item.incenseSeconds),
      StatsMigration.nonNegative(item.practiceSeconds),
      StatsMigration.nonNegative(item.sessionCount));
  }

  private static fromLegacy(item: StoredDailyStats): DailyStats {
    const legacyManual: number = StatsMigration.nonNegative(item.manualCount);
    const legacyAutomatic: number = StatsMigration.nonNegative(item.autoCount);
    const legacyDuration: number = StatsMigration.nonNegative(item.durationSeconds);
    return new DailyStats(item.date, legacyManual, legacyAutomatic, 0, 0, 0, legacyDuration, 0);
  }

  private static nonNegative(value: number | undefined): number {
    return typeof value === 'number' ? Math.max(0, Math.floor(value)) : 0;
  }
}
