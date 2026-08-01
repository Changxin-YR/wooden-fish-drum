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
  @State malletAngle: number = -32;
  @State malletOffsetX: number = 0;
  @State malletOffsetY: number = 0;
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
        this.malletAngle = 3;
        this.malletOffsetX = -8;
        this.malletOffsetY = 10;
      });
      this.getUIContext().animateTo({ duration: 180, delay: 90, curve: Curve.EaseOut }, (): void => {
        this.fishScale = 1;
        this.malletAngle = -32;
        this.malletOffsetX = 0;
        this.malletOffsetY = 0;
        this.waveScale = 1.35;
        this.waveOpacity = 0;
      });
    } else {
      setTimeout((): void => { this.waveOpacity = 0; }, 180);
    }
  }

  @Builder
  Mallet() {
    Row() {
      Row()
        .width(this.compact ? 30 : 42)
        .height(this.compact ? 30 : 42)
        .backgroundColor(this.dark ? '#A86A3D' : '#9C653B')
        .borderRadius(this.compact ? 15 : 21)
        .shadow({ radius: 8, color: '#5526150B', offsetY: 4 })
      Row()
        .width(this.compact ? 78 : 112)
        .height(this.compact ? 12 : 16)
        .linearGradient({
          angle: 0,
          colors: [['#6F3D20', 0], ['#B77B4A', 0.5], ['#7D4728', 1]]
        })
        .borderRadius(this.compact ? 6 : 8)
        .margin({ left: -2 })
    }
    .width(this.compact ? 106 : 152)
    .height(this.compact ? 36 : 50)
    .rotate({ angle: this.malletAngle, centerX: '100%', centerY: '50%' })
    .translate({ x: this.malletOffsetX, y: this.malletOffsetY })
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

      Image($r('app.media.muyu_body_transparent'))
        .width(this.compact ? '72%' : '82%')
        .height(this.compact ? '88%' : '86%')
        .objectFit(ImageFit.Contain)
        .scale({ x: this.fishScale, y: this.fishScale })

      Row() { this.Mallet() }
        .position({ x: this.compact ? '58%' : '62%', y: this.compact ? 4 : 24 })

      Column({ space: 8 }) {
        ForEach(this.floatingTexts, (item: string) => {
          Text(item.substring(item.indexOf(':') + 1))
            .fontSize(this.compact ? 14 : 17)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors().primary)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.colors().card)
            .borderRadius(20)
        }, (item: string): string => item)
      }
      .alignSelf(ItemAlign.Start)
      .margin({ top: this.compact ? 6 : 18 })
    }
    .width('100%')
    .height(this.canvasHeight)
    .padding(this.compact ? 4 : 12)
    .backgroundColor(this.colors().page)
    .onClick((): void => this.onHit())
    .accessibilityText('木鱼练习区，点击计数')
    .accessibilityDescription('木槌从右上方落下，整个区域均可点击')
  }
}
