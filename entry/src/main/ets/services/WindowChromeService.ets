import { window } from '@kit.ArkUI';
import { AppTab } from '../models/Enums';
import { SystemBarStyle } from '../models/SystemBarModels';
import { SystemBarStyleResolver } from '../utils/SystemBarStyleResolver';

export abstract class WindowChromeTarget {
  abstract setWindowLayoutFullScreen(isLayoutFullScreen: boolean): Promise<void>;
  abstract setWindowSystemBarProperties(properties: window.SystemBarProperties): Promise<void>;
  abstract setWindowBackgroundColor(color: string): void;
}

export class ArkUiWindowChromeTarget extends WindowChromeTarget {
  private appWindow: window.Window;

  constructor(appWindow: window.Window) {
    super();
    this.appWindow = appWindow;
  }

  async setWindowLayoutFullScreen(isLayoutFullScreen: boolean): Promise<void> {
    try {
      await this.appWindow.setWindowLayoutFullScreen(isLayoutFullScreen);
    } catch {
      throw new Error('Unable to update the window layout mode.');
    }
  }

  async setWindowSystemBarProperties(properties: window.SystemBarProperties): Promise<void> {
    try {
      await this.appWindow.setWindowSystemBarProperties(properties);
    } catch {
      throw new Error('Unable to update system bar properties.');
    }
  }

  setWindowBackgroundColor(color: string): void {
    try {
      this.appWindow.setWindowBackgroundColor(color);
    } catch {
      throw new Error('Unable to update the window background color.');
    }
  }
}

export class WindowChromeService {
  private appWindow: WindowChromeTarget | undefined = undefined;
  private appliedStyleKey: string = '';
  private pendingStyleKey: string = '';
  private requestedTab: AppTab = AppTab.HOME;
  private requestedDark: boolean = false;

  async bind(appWindow: WindowChromeTarget, tab: AppTab, dark: boolean): Promise<void> {
    this.appWindow = appWindow;
    this.requestedTab = tab;
    this.requestedDark = dark;
    this.appliedStyleKey = '';
    this.pendingStyleKey = '';
    try {
      await appWindow.setWindowLayoutFullScreen(false);
    } catch {
    }
    await this.apply(tab, dark);
  }

  update(tab: AppTab, dark: boolean): void {
    this.requestedTab = tab;
    this.requestedDark = dark;
    this.apply(tab, dark);
  }

  async refresh(): Promise<void> {
    this.appliedStyleKey = '';
    this.pendingStyleKey = '';
    await this.apply(this.requestedTab, this.requestedDark);
  }

  private async apply(tab: AppTab, dark: boolean): Promise<void> {
    const targetWindow: WindowChromeTarget | undefined = this.appWindow;
    if (targetWindow === undefined) {
      return;
    }
    const styleKey: string = `${tab}:${dark}`;
    if (styleKey === this.appliedStyleKey || styleKey === this.pendingStyleKey) {
      return;
    }
    const style: SystemBarStyle = SystemBarStyleResolver.resolve(tab, dark);
    const properties: window.SystemBarProperties = {
      statusBarColor: style.statusBarColor,
      navigationBarColor: style.navigationBarColor,
      statusBarContentColor: style.statusBarContentColor,
      navigationBarContentColor: style.navigationBarContentColor,
      isStatusBarLightIcon: style.isStatusBarLightIcon,
      isNavigationBarLightIcon: style.isNavigationBarLightIcon
    };
    this.pendingStyleKey = styleKey;
    try {
      targetWindow.setWindowBackgroundColor(style.navigationBarColor);
      await targetWindow.setWindowSystemBarProperties(properties);
      if (this.appWindow === targetWindow) {
        this.appliedStyleKey = styleKey;
      }
    } catch {
    } finally {
      if (this.pendingStyleKey === styleKey) {
        this.pendingStyleKey = '';
      }
    }
  }
}

export const windowChromeService: WindowChromeService = new WindowChromeService();
