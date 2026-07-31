import { ToolType } from '../models/Enums';

@Component
export struct ToolSegmentedControl {
  @Prop selected: ToolType = ToolType.WOODEN_FISH;
  @Prop dark: boolean = false;
  @Prop compact: boolean = false;
  onChange: (toolType: ToolType) => void = (): void => {};

  @Builder
  ToolButton(toolType: ToolType, symbol: string, label: string) {
    Button() {
      Row({ space: 8 }) {
        Text(symbol).fontSize(18).fontWeight(FontWeight.Medium)
        Text(label).fontSize(15).fontWeight(FontWeight.Medium)
        if (this.selected === toolType) {
          Text('✓').fontSize(13).fontWeight(FontWeight.Bold)
        }
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .layoutWeight(1)
    .height(this.compact ? 48 : 52)
    .type(ButtonType.Normal)
    .fontColor(this.selected === toolType ? '#FFFFFF' : (this.dark ? '#E8E0D7' : '#4A3A2D'))
    .backgroundColor(this.selected === toolType ? '#9A612C' : Color.Transparent)
    .borderRadius(8)
    .border({
      width: this.selected === toolType ? 1 : 0,
      color: this.selected === toolType ? '#C99763' : Color.Transparent
    })
    .onClick((): void => this.onChange(toolType))
    .accessibilityText(`${label}${this.selected === toolType ? '，已选择' : ''}`)
  }

  build() {
    Row({ space: 4 }) {
      this.ToolButton(ToolType.WOODEN_FISH, '木', '木鱼')
      this.ToolButton(ToolType.BEADS, '珠', '念珠')
      this.ToolButton(ToolType.INCENSE, '香', '一炷香')
    }
    .width('100%')
    .padding(this.compact ? 3 : 4)
    .backgroundColor(this.dark ? '#2A2622' : '#F3EDE4')
    .borderRadius(8)
  }
}
