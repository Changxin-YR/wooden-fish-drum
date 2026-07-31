import { DesignTokens } from '../constants/DesignTokens';

@Component
export struct OpenSourceLicensePage {
  @Prop dark: boolean = false;
  onBack: () => void = (): void => {};

  private pageBackground(): string { return this.dark ? DesignTokens.darkBackground : DesignTokens.lightBackground; }
  private card(): string { return this.dark ? DesignTokens.darkCard : DesignTokens.lightCard; }
  private primary(): string { return this.dark ? DesignTokens.darkText : DesignTokens.lightText; }
  private secondary(): string { return this.dark ? DesignTokens.darkSecondary : DesignTokens.lightSecondary; }

  build() {
    Column() {
      Row({ space: 10 }) {
        Button('‹').width(48).height(48).fontSize(30).type(ButtonType.Normal)
          .backgroundColor(Color.Transparent).fontColor(this.primary()).onClick((): void => this.onBack())
          .accessibilityText('返回设置')
        Text('开源与许可').fontSize(24).fontWeight(FontWeight.Bold).fontColor(this.primary())
      }
      .width('100%').padding({ left: 8, right: 20, top: 12, bottom: 8 })
      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            Text('正式运行包').width('100%').fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.primary())
            Text('当前 entry 正式运行模块未引入第三方业务 SDK。界面、存储、音频与振动能力由 HarmonyOS 系统 API 提供。')
              .width('100%').fontSize(14).lineHeight(23).fontColor(this.secondary())
          }
          .width('100%').padding(18).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
          Column({ space: 8 }) {
            Text('开发与测试依赖').width('100%').fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.primary())
            Text('Hypium 1.0.0：用于 ohosTest 自动化测试，不进入正式 entry HAP 的运行功能。仓库保留其测试框架快照和说明文件。')
              .width('100%').fontSize(14).lineHeight(23).fontColor(this.secondary())
          }
          .width('100%').padding(18).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
          Text('正式发布前将再次以 release 产物依赖清单为准核验许可信息。')
            .width('100%').fontSize(12).lineHeight(20).fontColor(this.secondary()).textAlign(TextAlign.Center)
        }
        .width('100%').padding({ left: 20, right: 20, bottom: 24 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(this.pageBackground())
  }
}
