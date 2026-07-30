import { ThemeMode } from '../models/Enums';

export class ThemeResolver {
  static isDark(mode: ThemeMode, systemDark: boolean): boolean {
    if (mode === ThemeMode.DARK) {
      return true;
    }
    if (mode === ThemeMode.LIGHT) {
      return false;
    }
    return systemDark;
  }
}
