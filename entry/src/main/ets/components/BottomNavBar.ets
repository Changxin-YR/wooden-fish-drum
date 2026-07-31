import { AppTab } from '../models/Enums';
import { DesignTokens } from '../constants/DesignTokens';
import { ThemeColors, ThemePalette } from '../constants/ThemePalette';

@Component
export struct BottomNavBar {
  @Prop selected: AppTab;
  @Prop dark: boolean;
  @Prop interactionEnabled: boolean = true;
  onChange: (tab: AppTab) => void = (): void => {};

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

  @Builder
  TabItem(tab: AppTab, icon: Resource, label: string) {
    Column({ space: 2 }) {
      Image(icon)
        .width(30)
        .height(34)
        .objectFit(ImageFit.Cover)
        .borderRadius(9)
        .opacity(this.selected === tab ? 1 : 0.58)
      Text(label)
        .fontSize(13)
        .fontWeight(this.selected === tab ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.selected === tab ? this.colors().accent : this.colors().secondary)
    }
    .layoutWeight(1)
    .height(DesignTokens.bottomNavHeight(390) - 8)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.selected === tab ? this.colors().accentSoft : Color.Transparent)
    .border({ width: this.selected === tab ? 1 : 0,
      color: this.selected === tab ? this.colors().accent : Color.Transparent })
    .borderRadius(12)
    .enabled(this.interactionEnabled)
    .onClick((): void => {
      if (this.interactionEnabled) {
        this.onChange(tab);
      }
    })
    .accessibilityText(`${label}${this.selected === tab ? '，已选' : ''}`)
  }

  build() {
    Row() {
      this.TabItem(AppTab.HOME, $r('app.media.nav_home'), '首页')
      this.TabItem(AppTab.STATS, $r('app.media.nav_stats'), '统计')
      this.TabItem(AppTab.SETTINGS, $r('app.media.nav_settings'), '设置')
    }
    .width('100%')
    .height(DesignTokens.bottomNavHeight(390))
    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
    .backgroundColor(this.colors().card)
    .border({ width: { top: 1 }, color: this.colors().divider })
  }
}
