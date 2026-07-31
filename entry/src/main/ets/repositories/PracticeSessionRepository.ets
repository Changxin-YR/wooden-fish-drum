import { LocalStoreAdapter } from '../data/LocalStoreAdapter';
import { PracticeSession } from '../models/PracticeModels';
import { SceneMode, ToolType } from '../models/Enums';

const SESSION_KEY: string = 'practice_sessions_v2';

export class PracticeSessionRepository {
  private readonly store: LocalStoreAdapter;
  private sessions: PracticeSession[] = [];
  private loaded: boolean = false;
  private mutationQueue: Promise<void> = Promise.resolve();

  constructor(store: LocalStoreAdapter) {
    this.store = store;
  }

  async append(session: PracticeSession): Promise<boolean> {
    let inserted: boolean = false;
    const operation: Promise<void> = this.mutationQueue.then(async (): Promise<void> => {
      await this.loadInternal();
      if (this.sessions.some((item: PracticeSession): boolean => item.id === session.id)) {
        return;
      }
      this.sessions.push(this.copy(session));
      await this.persist();
      inserted = true;
    });
    this.mutationQueue = operation.catch((): void => {});
    await operation;
    return inserted;
  }

  async recent(limit: number): Promise<PracticeSession[]> {
    await this.mutationQueue;
    await this.loadInternal();
    return this.sessions.slice().sort((left: PracticeSession, right: PracticeSession): number =>
      right.startTime - left.startTime).slice(0, Math.max(0, limit)).map(
      (item: PracticeSession): PracticeSession => this.copy(item));
  }

  async all(): Promise<PracticeSession[]> {
    await this.mutationQueue;
    await this.loadInternal();
    return this.sessions.map((item: PracticeSession): PracticeSession => this.copy(item));
  }

  async clearDate(date: string): Promise<void> {
    const operation: Promise<void> = this.mutationQueue.then(async (): Promise<void> => {
      await this.loadInternal();
      this.sessions = this.sessions.filter((item: PracticeSession): boolean => item.date !== date);
      await this.persist();
    });
    this.mutationQueue = operation.catch((): void => {});
    await operation;
  }

  async clearAll(): Promise<void> {
    const operation: Promise<void> = this.mutationQueue.then(async (): Promise<void> => {
      this.sessions = [];
      this.loaded = true;
      await this.store.remove(SESSION_KEY);
    });
    this.mutationQueue = operation.catch((): void => {});
    await operation;
  }

  private async loadInternal(): Promise<void> {
    if (this.loaded) {
      return;
    }
    this.sessions = this.decode(await this.store.getString(SESSION_KEY, ''));
    this.loaded = true;
  }

  private decode(snapshot: string): PracticeSession[] {
    if (snapshot.length === 0) {
      return [];
    }
    try {
      const parsed: PracticeSession[] = JSON.parse(snapshot) as PracticeSession[];
      if (!Array.isArray(parsed)) {
        return [];
      }
      const result: PracticeSession[] = [];
      parsed.forEach((item: PracticeSession): void => {
        if (item !== null && typeof item.id === 'string' && item.id.length > 0 &&
          this.isToolType(item.toolType) && this.isSceneMode(item.sceneMode)) {
          result.push(this.copy(item));
        }
      });
      return result;
    } catch {
      return [];
    }
  }

  private async persist(): Promise<void> {
    await this.store.putString(SESSION_KEY, JSON.stringify(this.sessions));
  }

  private copy(item: PracticeSession): PracticeSession {
    return new PracticeSession(item.id, item.toolType, item.sceneMode,
      Math.max(0, item.startTime), Math.max(0, item.endTime),
      Math.max(0, item.manualCount), Math.max(0, item.automaticCount),
      Math.max(0, item.durationSeconds), item.completed === true,
      typeof item.date === 'string' ? item.date : '');
  }

  private isToolType(value: ToolType): boolean {
    return value === ToolType.WOODEN_FISH || value === ToolType.BEADS || value === ToolType.INCENSE;
  }

  private isSceneMode(value: SceneMode): boolean {
    return value === SceneMode.PROGRAMMER || value === SceneMode.MINDFUL || value === SceneMode.DAILY;
  }
}
