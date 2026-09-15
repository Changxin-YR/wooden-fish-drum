import { JsonCodec } from '../data/JsonCodec';
import { LocalStoreAdapter } from '../data/LocalStoreAdapter';
import { AppSettings } from '../models/AppModels';

const SETTINGS_KEY: string = 'settings';

export class SettingsRepository {
  private readonly store: LocalStoreAdapter;
  private mutationQueue: Promise<void> = Promise.resolve();

  constructor(store: LocalStoreAdapter) {
    this.store = store;
  }

  async load(): Promise<AppSettings> {
    return JsonCodec.decodeSettings(await this.store.getString(SETTINGS_KEY, ''));
  }

  async save(settings: AppSettings): Promise<boolean> {
    const snapshot: string = JsonCodec.encodeSettings(settings);
    const operation: Promise<boolean> = this.mutationQueue.then(async (): Promise<boolean> => {
      try {
        await this.store.putString(SETTINGS_KEY, snapshot);
        return true;
      } catch {
        return false;
      }
    });
    this.mutationQueue = operation.then((_saved: boolean): void => {});
    return operation;
  }
}
