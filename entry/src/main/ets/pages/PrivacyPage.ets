import { DesignTokens } from '../constants/DesignTokens';
import { AppVersion } from '../constants/AppVersion';

@Component
export struct PrivacyPage {
  @Prop dark: boolean;
  onBack: () => void = (): void => {};

  private pageBackground(): string {
    return this.dark ? DesignTokens.darkBackground : DesignTokens.lightBackground;
  }

  private card(): string {
    return this.dark ? DesignTokens.darkCard : DesignTokens.lightCard;
  }

  private primaryText(): string {
    return this.dark ? DesignTokens.darkText : DesignTokens.lightText;
  }

  private secondaryText(): string {
    return this.dark ? DesignTokens.darkSecondary : DesignTokens.lightSecondary;
  }

  @Builder
  Section(title: string, content: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.primaryText())
      Text(content)
        .fontSize(14)
        .fontColor(this.secondaryText())
        .lineHeight(22)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        Text('‹')
          .fontSize(28)
          .fontColor('#8A5635')
          .onClick((): void => this.onBack())
        Text('隐私政策')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })

      Scroll() {
        Column({ space: 20 }) {
          Text(`敲敲木鱼 ${AppVersion.version}`)
            .fontSize(14)
            .fontColor(this.secondaryText())
            .width('100%')

          Column({ space: 16 }) {
            this.Section('概述',
              '敲敲木鱼是一款纯本地运行的敲击计数应用。本应用尊重并保护用户的隐私，不收集、不上传、不分享任何用户数据。')
            this.Section('数据存储',
              '所有数据（包括敲击记录、设置偏好等）均存储在您设备的本地存储中，不会传输至任何服务器或第三方平台。卸载应用将永久删除所有本地数据。')
            this.Section('权限说明',
              '本应用仅申请“振动”权限（ohos.permission.VIBRATE），用于敲击时提供触觉反馈。本应用不申请网络权限，不申请定位权限，不申请存储权限。')
            this.Section('第三方服务',
              '本应用不包含任何第三方SDK、广告服务、数据分析工具或崩溃报告服务。')
            this.Section('儿童隐私',
              '本应用适合所有年龄段用户使用。由于不收集任何个人信息，因此不涉及儿童隐私保护问题。')
            this.Section('更新说明',
              '本隐私政策可能会随应用更新而调整。任何变更将在应用内展示，继续使用本应用即表示您同意更新后的隐私政策。')
            this.Section('联系我们',
              '如您对本隐私政策有任何疑问，请通过应用商店评论区联系我们。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.card())
          .borderRadius(20)
          .margin({ bottom: 20 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
    .backgroundColor(this.pageBackground())
  }
}
