import { ThemeMode } from '../models/Enums';

export class ThemeResolver {
  static toggle(currentDark: boolean): ThemeMode {
    return currentDark ? ThemeMode.LIGHT : ThemeMode.DARK;
  }

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
