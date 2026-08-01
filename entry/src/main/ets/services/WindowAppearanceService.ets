import { window } from '@kit.ArkUI';
import { ThemePalette } from '../constants/ThemePalette';

export class WindowAppearanceService {
  private static mainWindow: window.Window | undefined;
  private static systemBottomPx: number = 0;
  private static navigationBottomPx: number = 0;

  static background(dark: boolean): string {
    return ThemePalette.resolve(dark).page;
  }

  static contentColor(dark: boolean): string {
    return dark ? '#F1ECE4' : '#2E2924';
  }

  static async initialize(windowStage: window.WindowStage, dark: boolean): Promise<void> {
    let mainWindow: window.Window;
    try {
      mainWindow = windowStage.getMainWindowSync();
    } catch {
      return;
    }
    WindowAppearanceService.mainWindow = mainWindow;
    try {
      await mainWindow.setWindowLayoutFullScreen(true);
    } catch {
    }
    await WindowAppearanceService.applyTheme(dark);
    WindowAppearanceService.refreshAvoidAreas(mainWindow);
    try {
      mainWindow.on('avoidAreaChange', (data: window.AvoidAreaOptions): void => {
        WindowAppearanceService.handleAvoidAreaChange(data);
      });
    } catch {
    }
  }

  static async applyTheme(dark: boolean): Promise<void> {
    if (WindowAppearanceService.mainWindow === undefined) {
      return;
    }
    const background: string = WindowAppearanceService.background(dark);
    const content: string = WindowAppearanceService.contentColor(dark);
    try {
      await WindowAppearanceService.mainWindow.setWindowSystemBarProperties({
        statusBarColor: background,
        navigationBarColor: background,
        statusBarContentColor: content,
        navigationBarContentColor: content,
        isStatusBarLightIcon: dark,
        isNavigationBarLightIcon: dark
      });
    } catch {
    }
  }

  static release(): void {
    if (WindowAppearanceService.mainWindow !== undefined) {
      try {
        WindowAppearanceService.mainWindow.off('avoidAreaChange');
      } catch {
      }
    }
    WindowAppearanceService.mainWindow = undefined;
  }

  private static refreshAvoidAreas(mainWindow: window.Window): void {
    let topPx: number = 0;
    try {
      const system: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      topPx = system.topRect.height;
      WindowAppearanceService.systemBottomPx = system.bottomRect.height;
    } catch {
    }
    try {
      const navigation: window.AvoidArea = mainWindow.getWindowAvoidArea(
        window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      WindowAppearanceService.navigationBottomPx = navigation.bottomRect.height;
    } catch {
    }
    WindowAppearanceService.publishAvoidAreas(topPx);
  }

  private static handleAvoidAreaChange(data: window.AvoidAreaOptions): void {
    let topPx: number = AppStorage.get<number>('topSafeAreaPx') ?? 0;
    if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
      topPx = data.area.topRect.height;
      WindowAppearanceService.systemBottomPx = data.area.bottomRect.height;
    } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      WindowAppearanceService.navigationBottomPx = data.area.bottomRect.height;
    }
    WindowAppearanceService.publishAvoidAreas(topPx);
  }

  private static publishAvoidAreas(topPx: number): void {
    AppStorage.setOrCreate('topSafeAreaPx', Math.max(0, topPx));
    AppStorage.setOrCreate('bottomSafeAreaPx',
      Math.max(0, WindowAppearanceService.systemBottomPx, WindowAppearanceService.navigationBottomPx));
  }
}
