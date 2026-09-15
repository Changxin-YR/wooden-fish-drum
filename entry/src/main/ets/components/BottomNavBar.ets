import { AppTab } from '../models/Enums';
import { DesignTokens } from '../constants/DesignTokens';

@Component
export struct BottomNavBar {
  @Prop selected: AppTab;
  @Prop dark: boolean;
  onChange: (tab: AppTab) => void = (): void => {};

  @Builder
  TabItem(tab: AppTab, icon: Resource, label: string) {
    Column({ space: 2 }) {
      Image(icon)
        .width(30)
        .height(34)
        .objectFit(ImageFit.Cover)
        .borderRadius(9)
        .opacity(this.selected === tab ? 1.0 : 0.45)
      Text(label)
        .fontSize(12)
        .fontColor(this.selected === tab ? (this.dark ? DesignTokens.accentLight : DesignTokens.wood) :
          (this.dark ? DesignTokens.darkSecondary : DesignTokens.lightSecondary))
    }
    .layoutWeight(1)
    .height(64)
    .justifyContent(FlexAlign.Center)
    .onClick((): void => this.onChange(tab))
    .accessibilityText(label)
  }

  build() {
    Row() {
      this.TabItem(AppTab.HOME, $r('app.media.nav_home'), '首页')
      this.TabItem(AppTab.STATS, $r('app.media.nav_stats'), '统计')
      this.TabItem(AppTab.SETTINGS, $r('app.media.nav_settings'), '设置')
    }
    .width('100%')
    .backgroundColor(this.dark ? DesignTokens.darkCard : DesignTokens.lightCard)
    .border({ width: { top: 1 }, color: this.dark ? DesignTokens.darkDivider : DesignTokens.lightDivider })
  }
}
