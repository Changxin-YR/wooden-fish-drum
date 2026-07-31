import { DesignTokens } from '../constants/DesignTokens';

@Component
export struct PrivacyPolicyPage {
  @Prop dark: boolean = false;
  onBack: () => void = (): void => {};

  private pageBackground(): string { return this.dark ? DesignTokens.darkBackground : DesignTokens.lightBackground; }
  private card(): string { return this.dark ? DesignTokens.darkCard : DesignTokens.lightCard; }
  private primary(): string { return this.dark ? DesignTokens.darkText : DesignTokens.lightText; }
  private secondary(): string { return this.dark ? DesignTokens.darkSecondary : DesignTokens.lightSecondary; }

  @Builder
  Section(title: string, body: string) {
    Column({ space: 8 }) {
      Text(title).width('100%').fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.primary())
      Text(body).width('100%').fontSize(14).lineHeight(23).fontColor(this.secondary())
    }
    .width('100%')
    .padding(18)
    .backgroundColor(this.card())
    .borderRadius(DesignTokens.radiusCard)
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Button('‹').width(48).height(48).fontSize(30).type(ButtonType.Normal)
          .backgroundColor(Color.Transparent).fontColor(this.primary()).onClick((): void => this.onBack())
          .accessibilityText('返回设置')
        Text('隐私说明').fontSize(24).fontWeight(FontWeight.Bold).fontColor(this.primary())
      }
      .width('100%').padding({ left: 8, right: 20, top: 12, bottom: 8 })
      Scroll() {
        Column({ space: 14 }) {
          this.Section('离线与账号', '本应用无需注册或登录，不接入账号系统，不提供云同步。主要功能可在离线状态下使用。')
          this.Section('本地数据', '练习设置、每日统计、练习会话和进行中的一炷香状态仅保存在当前设备的应用私有目录。卸载应用或在设置中清除全部数据后，这些数据将无法恢复。')
          this.Section('网络与第三方服务', '正式运行模块不申请网络权限，不包含广告、支付、分析统计或用户画像 SDK，不会主动上传练习数据。')
          this.Section('系统权限', '应用仅申请振动权限，用于用户开启振动反馈时提供轻微触觉提示。关闭振动反馈后，练习计数和计时仍可正常使用。')
          this.Section('用户控制', '你可以在设置中分别清除今日数据或全部本地数据。清除操作会再次确认，并在执行前说明影响范围。')
          Text('生效版本：1.0').width('100%').fontSize(12).fontColor(this.secondary()).textAlign(TextAlign.Center)
        }
        .width('100%').padding({ left: 20, right: 20, bottom: 24 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(this.pageBackground())
  }
}
