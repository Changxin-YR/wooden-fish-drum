import { DesignTokens } from '../constants/DesignTokens';
import { AppTab } from '../models/Enums';
import { SystemBarStyle } from '../models/SystemBarModels';

export class SystemBarStyleResolver {
  static resolve(tab: AppTab, dark: boolean): SystemBarStyle {
    const style: SystemBarStyle = new SystemBarStyle();
    style.statusBarColor = dark ? DesignTokens.darkBackground :
      (tab === AppTab.HOME ? DesignTokens.homeLightBackground : DesignTokens.lightBackground);
    style.navigationBarColor = dark ? DesignTokens.darkCard : DesignTokens.lightCard;
    style.statusBarContentColor = dark ? '#FFFFFF' : '#000000';
    style.navigationBarContentColor = dark ? '#FFFFFF' : '#000000';
    style.isStatusBarLightIcon = dark;
    style.isNavigationBarLightIcon = dark;
    return style;
  }
}
