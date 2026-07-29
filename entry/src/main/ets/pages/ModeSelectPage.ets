import { ModeSelectCard } from '../components/ModeSelectCard';
import { USER_MODE_CONFIGS } from '../constants/UserModeConfigs';
import { UserMode } from '../models/Enums';

@Component
export struct ModeSelectPage {
  @State selectedMode: UserMode = UserMode.PROGRAMMER;
  onConfirm: (mode: UserMode) => void = (): void => {};

  build() {
    Column() {
      Scroll() {
        Column({ space: 20 }) {
          Image($r('app.media.muyu_brand'))
            .width(230)
            .height(146)
            .objectFit(ImageFit.Cover)

          Text('功 德 木 鱼')
            .fontSize(38)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5E3516')

          Text('敲击木鱼 · 积累功德 · 净心自修')
            .fontSize(15)
            .fontColor('#8A5635')

          Text('请选择适合您的使用模式')
            .fontSize(20)
            .fontColor('#2E2924')
            .margin({ top: 12 })

          ModeSelectCard({
            config: USER_MODE_CONFIGS[UserMode.PROGRAMMER],
            selected: this.selectedMode === UserMode.PROGRAMMER,
            image: $r('app.media.mode_programmer'),
            onSelect: (mode: UserMode): void => {
              this.selectedMode = mode;
            }
          })
          ModeSelectCard({
            config: USER_MODE_CONFIGS[UserMode.MONK],
            selected: this.selectedMode === UserMode.MONK,
            image: $r('app.media.mode_monk'),
            onSelect: (mode: UserMode): void => {
              this.selectedMode = mode;
            }
          })
          ModeSelectCard({
            config: USER_MODE_CONFIGS[UserMode.GENERAL],
            selected: this.selectedMode === UserMode.GENERAL,
            image: $r('app.media.mode_general'),
            onSelect: (mode: UserMode): void => {
              this.selectedMode = mode;
            }
          })

          Button('开始使用')
            .width('100%')
            .height(56)
            .fontSize(20)
            .fontColor(Color.White)
            .backgroundColor('#9A612C')
            .borderRadius(28)
            .onClick((): void => this.onConfirm(this.selectedMode))

          Text('ⓘ 所选模式可在「设置」中随时切换')
            .fontSize(12)
            .fontColor('#B09A83')
            .margin({ bottom: 20 })
        }
        .width('100%')
        .padding({ left: 22, right: 22, top: 28 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F1E8')
  }
}
