import { UserModeConfig } from '../models/AppModels';
import { UserMode } from '../models/Enums';

@Component
export struct ModeSelectCard {
  @Prop config: UserModeConfig;
  @Prop selected: boolean;
  @Prop image: Resource;
  onSelect: (mode: UserMode) => void = (): void => {};

  build() {
    Row({ space: 16 }) {
      Image(this.image)
        .width(112)
        .height(112)
        .objectFit(ImageFit.Cover)
        .borderRadius(16)

      Column({ space: 8 }) {
        Row() {
          Text(this.config.title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2E2924')
          Blank()
          if (this.selected) {
            Text('✓')
              .width(34)
              .height(34)
              .textAlign(TextAlign.Center)
              .fontSize(22)
              .fontColor(Color.White)
              .backgroundColor('#9A612C')
              .borderRadius(17)
          }
        }
        .width('100%')

        Text(this.config.description)
          .fontSize(14)
          .fontColor('#817970')
          .maxLines(2)

        Text(this.config.detail)
          .fontSize(12)
          .fontColor('#8A5635')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#F8F1E6')
          .borderRadius(14)
      }
      .layoutWeight(1)
      .constraintSize({ minWidth: 0 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(14)
    .constraintSize({ minHeight: 144 })
    .backgroundColor(this.selected ? '#FFF9EF' : '#FFFDF8')
    .border({
      width: this.selected ? 2 : 1,
      color: this.selected ? '#9A612C' : '#E8E2D8'
    })
    .borderRadius(20)
    .shadow({ radius: 12, color: '#1A8A5635', offsetY: 5 })
    .onClick((): void => this.onSelect(this.config.mode))
  }
}
