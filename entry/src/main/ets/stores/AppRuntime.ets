import { PreferencesStore } from '../data/PreferencesStore';
import { SettingsRepository } from '../repositories/SettingsRepository';
import { StatsRepository } from '../repositories/StatsRepository';
import { SessionService } from '../services/SessionService';
import { AppStore } from './AppStore';

export const preferencesStore: PreferencesStore = new PreferencesStore();
export const appStore: AppStore =
  new AppStore(new SettingsRepository(preferencesStore), new StatsRepository(preferencesStore));
export const sessionService: SessionService = new SessionService();
