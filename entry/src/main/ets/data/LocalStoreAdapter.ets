export interface LocalStoreAdapter {
  getString(key: string, fallback: string): Promise<string>;
  putString(key: string, value: string): Promise<void>;
  remove(key: string): Promise<void>;
}
