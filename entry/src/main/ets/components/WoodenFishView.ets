import { ThemeColors, ThemePalette } from '../constants/ThemePalette';

@Component
export struct WoodenFishView {
  @Prop dark: boolean;
  @Prop @Watch('onHitSequenceChanged') hitSequence: number;
  @Prop label: string;
  @Prop floatingEnabled: boolean = true;
  @Prop reducedMotion: boolean = false;
  @Prop compact: boolean = false;
  @Prop canvasHeight: number = 330;
  onHit: () => void = (): void => {};
  @State fishScale: number = 1;
  @State waveScale: number = 0.72;
  @State waveOpacity: number = 0;
  @State floatingTexts: string[] = [];
  private lastAnimatedSequence: number = 0;

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

  private onHitSequenceChanged(): void {
    if (this.hitSequence <= this.lastAnimatedSequence) {
      return;
    }
    this.lastAnimatedSequence = this.hitSequence;
    this.playHitFeedback();
    if (this.floatingEnabled) {
      const entry: string = `${this.hitSequence}:${this.label}`;
      this.floatingTexts = this.floatingTexts.concat([entry]).slice(-3);
      setTimeout((): void => {
        this.floatingTexts = this.floatingTexts.filter((item: string): boolean => item !== entry);
      }, 760);
    }
  }

  private playHitFeedback(): void {
    this.waveScale = 0.72;
    this.waveOpacity = 0.72;
    if (!this.reducedMotion) {
      this.getUIContext().animateTo({ duration: 90, curve: Curve.EaseIn }, (): void => {
        this.fishScale = 0.97;
      });
      this.getUIContext().animateTo({ duration: 180, delay: 90, curve: Curve.EaseOut }, (): void => {
        this.fishScale = 1;
        this.waveScale = 1.35;
        this.waveOpacity = 0;
      });
    } else {
      setTimeout((): void => {
        this.waveOpacity = 0;
      }, 180);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(this.compact ? 130 : 286)
        .height(this.compact ? 130 : 286)
        .border({ width: 2, color: this.colors().accent })
        .borderRadius(this.compact ? 65 : 143)
        .opacity(this.waveOpacity)
        .scale({ x: this.waveScale, y: this.waveScale })

      Image($r('app.media.practice_wooden_fish'))
        .width('94%')
        .height('94%')
        .objectFit(ImageFit.Contain)
        .scale({ x: this.fishScale, y: this.fishScale })

      Column({ space: 8 }) {
        ForEach(this.floatingTexts, (item: string) => {
          Text(item.substring(item.indexOf(':') + 1))
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors().primary)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.colors().card)
            .borderRadius(20)
        }, (item: string): string => item)
      }
      .alignSelf(ItemAlign.Start)
      .margin({ top: 18 })
    }
    .width('100%')
    .height(this.canvasHeight)
    .padding(this.compact ? 4 : 12)
    .onClick((): void => this.onHit())
    .accessibilityText('木鱼练习区，点击计数')
    .accessibilityDescription('整个区域均可点击')
  }
}
