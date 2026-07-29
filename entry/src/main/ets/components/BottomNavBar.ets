import { AppTab } from '../models/Enums';

@Component
export struct BottomNavBar {
  @Prop selected: AppTab;
  onChange: (tab: AppTab) => void = (): void => {};

  @Builder
  TabItem(tab: AppTab, icon: string, label: string) {
    Column({ space: 2 }) {
      Text(icon)
        .fontSize(24)
        .fontColor(this.selected === tab ? '#8A5635' : '#8B857E')
      Text(label)
        .fontSize(12)
        .fontColor(this.selected === tab ? '#8A5635' : '#8B857E')
    }
    .layoutWeight(1)
    .height(64)
    .justifyContent(FlexAlign.Center)
    .onClick((): void => this.onChange(tab))
  }

  build() {
    Row() {
      this.TabItem(AppTab.HOME, '⌂', '首页')
      this.TabItem(AppTab.STATS, '▥', '统计')
      this.TabItem(AppTab.SETTINGS, '⚙', '设置')
    }
    .width('100%')
    .backgroundColor('#FFFDF8')
    .border({ width: { top: 1 }, color: '#E8E2D8' })
  }
}
