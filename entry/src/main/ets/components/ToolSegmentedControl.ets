import { ToolType } from '../models/Enums';
import { DesignTokens } from '../constants/DesignTokens';
import { ThemeColors, ThemePalette } from '../constants/ThemePalette';

@Component
export struct ToolSegmentedControl {
  @Prop selected: ToolType = ToolType.WOODEN_FISH;
  @Prop dark: boolean = false;
  @Prop compact: boolean = false;
  onChange: (toolType: ToolType) => void = (): void => {};

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

  @Builder
  ToolButton(toolType: ToolType, icon: Resource, label: string) {
    Button() {
      Row({ space: 8 }) {
        Image(icon).width(28).height(28).objectFit(ImageFit.Contain)
        Text(label).fontSize(15).fontWeight(FontWeight.Medium)
        if (this.selected === toolType) {
          Text('✓').fontSize(13).fontWeight(FontWeight.Bold)
        }
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .layoutWeight(1)
    .height(DesignTokens.toolBarHeight(390) - 4)
    .type(ButtonType.Normal)
    .fontColor(this.selected === toolType ? this.colors().selectedText : this.colors().primary)
    .backgroundColor(this.selected === toolType ? this.colors().accent : Color.Transparent)
    .borderRadius(16)
    .border({
      width: this.selected === toolType ? 1 : 0,
      color: this.selected === toolType ? this.colors().accent : Color.Transparent
    })
    .onClick((): void => this.onChange(toolType))
    .accessibilityText(`${label}${this.selected === toolType ? '，已选择' : ''}`)
  }

  build() {
    Row({ space: 4 }) {
      this.ToolButton(ToolType.WOODEN_FISH, $r('app.media.practice_wooden_fish'), '木鱼')
      this.ToolButton(ToolType.BEADS, $r('app.media.practice_beads'), '念珠')
      this.ToolButton(ToolType.INCENSE, $r('app.media.practice_incense'), '一炷香')
    }
    .width('100%')
    .height(DesignTokens.toolBarHeight(390))
    .padding(2)
    .backgroundColor(this.colors().card)
    .border({ width: 1, color: this.colors().divider })
    .borderRadius(18)
  }
}
