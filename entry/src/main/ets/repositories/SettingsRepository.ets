import { JsonCodec } from '../data/JsonCodec';
import { LocalStoreAdapter } from '../data/LocalStoreAdapter';
import { AppSettings } from '../models/AppModels';

const SETTINGS_KEY: string = 'settings';

export class SettingsRepository {
  private readonly store: LocalStoreAdapter;

  constructor(store: LocalStoreAdapter) {
    this.store = store;
  }

  async load(): Promise<AppSettings> {
    return JsonCodec.decodeSettings(await this.store.getString(SETTINGS_KEY, ''));
  }

  async save(settings: AppSettings): Promise<boolean> {
    try {
      await this.store.putString(SETTINGS_KEY, JsonCodec.encodeSettings(settings));
      return true;
    } catch {
      return false;
    }
  }

  async clear(): Promise<void> {
    await this.store.remove(SETTINGS_KEY);
  }
}
