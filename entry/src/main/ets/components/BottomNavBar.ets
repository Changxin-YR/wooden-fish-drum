import { AppTab } from '../models/Enums';

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
      Text(label)
        .fontSize(12)
        .fontColor(this.selected === tab ? (this.dark ? '#D8B28C' : '#8A5635') :
          (this.dark ? '#AAA198' : '#8B857E'))
    }
    .layoutWeight(1)
    .height(64)
    .justifyContent(FlexAlign.Center)
    .onClick((): void => this.onChange(tab))
  }

  build() {
    Row() {
      this.TabItem(AppTab.HOME, $r('app.media.nav_home'), '首页')
      this.TabItem(AppTab.STATS, $r('app.media.nav_stats'), '统计')
      this.TabItem(AppTab.SETTINGS, $r('app.media.nav_settings'), '设置')
    }
    .width('100%')
    .backgroundColor(this.dark ? '#24211E' : '#FFFDF8')
    .border({ width: { top: 1 }, color: this.dark ? '#3B3530' : '#E8E2D8' })
  }
}
