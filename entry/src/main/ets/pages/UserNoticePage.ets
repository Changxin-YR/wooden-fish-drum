import { DesignTokens } from '../constants/DesignTokens';

@Component
export struct UserNoticePage {
  @Prop dark: boolean = false;
  onBack: () => void = (): void => {};

  private pageBackground(): string { return this.dark ? DesignTokens.darkBackground : DesignTokens.lightBackground; }
  private card(): string { return this.dark ? DesignTokens.darkCard : DesignTokens.lightCard; }
  private primary(): string { return this.dark ? DesignTokens.darkText : DesignTokens.lightText; }
  private secondary(): string { return this.dark ? DesignTokens.darkSecondary : DesignTokens.lightSecondary; }

  @Builder
  Notice(index: string, title: string, body: string) {
    Row({ space: 14 }) {
      Text(index).width(38).height(38).fontSize(14).fontWeight(FontWeight.Bold).textAlign(TextAlign.Center)
        .fontColor(this.dark ? DesignTokens.accentLight : DesignTokens.wood)
        .backgroundColor(this.dark ? '#3B3530' : '#F7EFE4').borderRadius(19)
      Column({ space: 5 }) {
        Text(title).fontSize(17).fontWeight(FontWeight.Medium).fontColor(this.primary())
        Text(body).fontSize(14).lineHeight(22).fontColor(this.secondary())
      }
      .layoutWeight(1).constraintSize({ minWidth: 0 }).alignItems(HorizontalAlign.Start)
    }
    .width('100%').padding(18).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Button('‹').width(48).height(48).fontSize(30).type(ButtonType.Normal)
          .backgroundColor(Color.Transparent).fontColor(this.primary()).onClick((): void => this.onBack())
          .accessibilityText('返回设置')
        Text('用户须知').fontSize(24).fontWeight(FontWeight.Bold).fontColor(this.primary())
      }
      .width('100%').padding({ left: 8, right: 20, top: 12, bottom: 8 })
      Scroll() {
        Column({ space: 14 }) {
          this.Notice('01', '工具定位', '本应用是本地练习与计时工具，用于记录木鱼、念珠和一炷香的个人练习过程。')
          this.Notice('02', '不作功效承诺', '应用中的“静心”“专注”等文字仅描述使用场景，不代表宗教仪式、医疗诊断、治疗、康复或心理健康功效。')
          this.Notice('03', '合理使用', '请根据自身情况控制音量、振动和连续使用时间。若使用过程中感到不适，请立即停止使用。')
          this.Notice('04', '数据责任', '应用不提供账号和云备份。请在清除数据或卸载前确认不再需要本地记录。')
          this.Notice('05', '未成年人', '未成年人应在监护人知情和指导下使用，并避免长时间连续操作设备。')
        }
        .width('100%').padding({ left: 20, right: 20, bottom: 24 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(this.pageBackground())
  }
}
