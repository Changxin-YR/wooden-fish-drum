import { SCENE_MODE_CONFIGS } from '../constants/UserModeConfigs';
import { SceneMode, ToolType } from '../models/Enums';
import { ToolSegmentedControl } from '../components/ToolSegmentedControl';

@Component
export struct ModeSelectPage {
  @Prop dark: boolean = false;
  @State step: number = 1;
  @State selectedScene: SceneMode = SceneMode.DAILY;
  @State selectedTool: ToolType = ToolType.WOODEN_FISH;
  onComplete: (sceneMode: SceneMode, toolType: ToolType) => void = (): void => {};

  private pageBackground(): string {
    return this.dark ? '#171513' : '#FBFAF7';
  }

  private primaryText(): string {
    return this.dark ? '#F3ECE4' : '#3D2A1D';
  }

  private secondaryText(): string {
    return this.dark ? '#B8AEA5' : '#786B61';
  }

  @Builder
  SceneCard(sceneMode: SceneMode, symbol: string) {
    Row({ space: 16 }) {
      Text(symbol)
        .width(48)
        .height(48)
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedScene === sceneMode ? '#FFFFFF' : '#9A612C')
        .backgroundColor(this.selectedScene === sceneMode ? '#9A612C' :
          (this.dark ? '#332D28' : '#F5EEE5'))
        .borderRadius(8)
      Column({ space: 5 }) {
        Text(SCENE_MODE_CONFIGS[sceneMode].title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.primaryText())
        Text(SCENE_MODE_CONFIGS[sceneMode].description)
          .fontSize(13)
          .fontColor(this.secondaryText())
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text(this.selectedScene === sceneMode ? '已选择' : '选择')
        .fontSize(12)
        .fontColor(this.selectedScene === sceneMode ? '#9A612C' : this.secondaryText())
    }
    .width('100%')
    .constraintSize({ minHeight: 82 })
    .padding(16)
    .backgroundColor(this.dark ? '#24211E' : '#FFFFFF')
    .borderRadius(8)
    .border({
      width: this.selectedScene === sceneMode ? 2 : 1,
      color: this.selectedScene === sceneMode ? '#A66A35' : (this.dark ? '#423B35' : '#E5DDD3')
    })
    .onClick((): void => {
      this.selectedScene = sceneMode;
      this.selectedTool = SCENE_MODE_CONFIGS[sceneMode].recommendedTool;
    })
  }

  @Builder
  StepIndicator() {
    Row({ space: 8 }) {
      Row().width(this.step === 1 ? 32 : 12).height(4).borderRadius(2)
        .backgroundColor(this.step === 1 ? '#9A612C' : '#D8CEC3')
      Row().width(this.step === 2 ? 32 : 12).height(4).borderRadius(2)
        .backgroundColor(this.step === 2 ? '#9A612C' : '#D8CEC3')
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 22 }) {
          Column({ space: 10 }) {
            Text('静心木鱼')
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())
            Text('单机版 · 离线使用')
              .fontSize(14)
              .fontColor(this.secondaryText())
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          this.StepIndicator()

          if (this.step === 1) {
            Column({ space: 8 }) {
              Text('选择使用场景')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.primaryText())
              Text('只改变默认外观与反馈，后续可在设置中修改')
                .fontSize(14)
                .fontColor(this.secondaryText())
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            Column({ space: 12 }) {
              this.SceneCard(SceneMode.PROGRAMMER, '码')
              this.SceneCard(SceneMode.MINDFUL, '静')
              this.SceneCard(SceneMode.DAILY, '日')
            }
          } else {
            Column({ space: 8 }) {
              Text('选择默认工具')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.primaryText())
              Text('进入应用后仍可随时切换')
                .fontSize(14)
                .fontColor(this.secondaryText())
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            ToolSegmentedControl({
              selected: this.selectedTool,
              dark: this.dark,
              onChange: (toolType: ToolType): void => {
                this.selectedTool = toolType;
              }
            })
            Column({ space: 12 }) {
              Text(this.selectedTool === ToolType.WOODEN_FISH ? '木鱼节律' :
                (this.selectedTool === ToolType.BEADS ? '念珠计数' : '静心计时'))
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.primaryText())
              Text(this.selectedTool === ToolType.WOODEN_FISH ? '轻触计数，支持稳定自动节律' :
                (this.selectedTool === ToolType.BEADS ? '点击或轻扫，记录每一次推进' :
                  '选择时长，用一段安静时间整理节奏'))
                .fontSize(15)
                .fontColor(this.secondaryText())
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .constraintSize({ minHeight: 180 })
            .justifyContent(FlexAlign.Center)
            .padding(24)
            .backgroundColor(this.dark ? '#24211E' : '#FFFFFF')
            .borderRadius(8)
          }
        }
        .width('100%')
        .constraintSize({ maxWidth: 640 })
        .padding({ left: 24, right: 24, top: 52, bottom: 24 })
      }
      .layoutWeight(1)

      Row({ space: 12 }) {
        if (this.step === 2) {
          Button('返回')
            .height(52)
            .layoutWeight(1)
            .type(ButtonType.Normal)
            .fontColor(this.primaryText())
            .backgroundColor(this.dark ? '#302B27' : '#EFE8DF')
            .borderRadius(8)
            .onClick((): void => {
              this.step = 1;
            })
        }
        Button(this.step === 1 ? '下一步' : '开始使用')
          .height(52)
          .layoutWeight(2)
          .type(ButtonType.Normal)
          .fontColor('#FFFFFF')
          .backgroundColor('#9A612C')
          .borderRadius(8)
          .onClick((): void => {
            if (this.step === 1) {
              this.step = 2;
            } else {
              this.onComplete(this.selectedScene, this.selectedTool);
            }
          })
      }
      .width('100%')
      .constraintSize({ maxWidth: 640 })
      .padding({ left: 24, right: 24, top: 12, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.pageBackground())
  }
}
