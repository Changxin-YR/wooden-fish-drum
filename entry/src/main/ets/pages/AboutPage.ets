import { ThemeColors, ThemePalette } from '../constants/ThemePalette';

@Component
export struct AboutPage {
  @Prop dark: boolean = false;
  onBack: () => void = (): void => {};

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

  build() {
    Column() {
      Row({ space: 10 }) {
        Button('‹').width(48).height(48).fontSize(30).type(ButtonType.Normal)
          .backgroundColor(Color.Transparent).fontColor(this.colors().primary).onClick((): void => this.onBack())
          .accessibilityText('返回设置')
        Text('关于应用').fontSize(24).fontWeight(FontWeight.Bold).fontColor(this.colors().primary)
      }
      .width('100%').padding({ left: 8, right: 20, top: 12, bottom: 8 })
      Scroll() {
        Column({ space: 18 }) {
          Image($r('app.media.app_icon')).width(104).height(104).borderRadius(24)
          Text($r('app.string.app_name')).fontSize(28).fontWeight(FontWeight.Bold).fontColor(this.colors().primary)
          Text('单机版 · 离线使用').fontSize(14).fontColor(this.colors().secondary)
          Column() {
            Row() {
              Text('版本').fontSize(15).fontColor(this.colors().secondary)
              Blank()
              Text($r('app.string.app_version')).fontSize(15).fontColor(this.colors().primary)
            }.width('100%').constraintSize({ minHeight: 52 })
            Divider().color(this.colors().divider)
            Row() {
              Text('运行方式').fontSize(15).fontColor(this.colors().secondary)
              Blank()
              Text('本地单机').fontSize(15).fontColor(this.colors().primary)
            }.width('100%').constraintSize({ minHeight: 52 })
            Divider().color(this.colors().divider)
            Row() {
              Text('网络权限').fontSize(15).fontColor(this.colors().secondary)
              Blank()
              Text('未申请').fontSize(15).fontColor(this.colors().primary)
            }.width('100%').constraintSize({ minHeight: 52 })
          }
          .width('100%').padding({ left: 18, right: 18 }).backgroundColor(this.colors().card)
          .borderRadius(8).border({ width: 1, color: this.colors().divider })
          Column({ space: 8 }) {
            Text('开源与许可').width('100%').fontSize(18).fontWeight(FontWeight.Medium)
              .fontColor(this.colors().primary)
            Text('正式运行包未引入第三方业务 SDK；界面、存储、音频与振动能力由 HarmonyOS 系统 API 提供。')
              .width('100%').fontSize(13).lineHeight(21).fontColor(this.colors().secondary)
            Divider().color(this.colors().divider)
            Text('Hypium 1.0.0 仅用于 ohosTest 自动化测试，不进入正式 entry HAP 的运行功能。')
              .width('100%').fontSize(13).lineHeight(21).fontColor(this.colors().secondary)
          }
          .width('100%').padding(16).backgroundColor(this.colors().card)
          .borderRadius(8).border({ width: 1, color: this.colors().divider })
          Text('发布签名、备案信息和 AppGallery Connect 上架资料由发布主体在正式提交时核验，本应用不展示未经确认的备案编号。')
            .width('100%').fontSize(13).lineHeight(21).fontColor(this.colors().secondary)
            .textAlign(TextAlign.Center)
        }
        .width('100%').padding({ left: 24, right: 24, top: 28, bottom: 24 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(this.colors().page)
  }
}
