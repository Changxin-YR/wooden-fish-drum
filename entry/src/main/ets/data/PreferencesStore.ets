import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { LocalStoreAdapter } from './LocalStoreAdapter';

export class PreferencesStore implements LocalStoreAdapter {
  private data: preferences.Preferences | null = null;

  async initialize(context: common.Context): Promise<void> {
    this.data = await preferences.getPreferences(context, 'muyu_local_data');
  }

  async getString(key: string, fallback: string): Promise<string> {
    if (this.data === null) {
      return fallback;
    }
    try {
      const value: preferences.ValueType = await this.data.get(key, fallback);
      return typeof value === 'string' ? value : fallback;
    } catch {
      return fallback;
    }
  }

  async putString(key: string, value: string): Promise<void> {
    if (this.data === null) {
      throw new Error('本地存储尚未初始化');
    }
    await this.data.put(key, value);
    await this.data.flush();
  }

  async remove(key: string): Promise<void> {
    if (this.data === null) {
      return;
    }
    await this.data.delete(key);
    await this.data.flush();
  }
}
