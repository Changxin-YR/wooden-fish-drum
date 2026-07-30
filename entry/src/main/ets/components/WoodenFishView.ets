@Component
export struct WoodenFishView {
  @Prop dark: boolean;
  @Prop @Watch('onHitSequenceChanged') hitSequence: number;
  @Prop label: string;
  @Prop floatingEnabled: boolean = true;
  onHit: () => void = (): void => {};
  @State fishScale: number = 1;
  @State malletAngle: number = -12;
  @State malletOffsetX: number = 0;
  @State malletOffsetY: number = 0;
  @State waveScale: number = 0.72;
  @State waveOpacity: number = 0;
  @State floatingTexts: string[] = [];
  private lastAnimatedSequence: number = 0;

  private onHitSequenceChanged(): void {
    if (this.hitSequence <= this.lastAnimatedSequence) {
      return;
    }
    this.lastAnimatedSequence = this.hitSequence;
    this.playHitAnimation();
    if (this.floatingEnabled) {
      const next: string[] = this.floatingTexts.concat([`${this.hitSequence}:${this.label}`]);
      this.floatingTexts = next.slice(Math.max(0, next.length - 3));
    }
  }

  private playHitAnimation(): void {
    this.getUIContext().animateTo({ duration: 90, curve: Curve.EaseIn }, (): void => {
      this.fishScale = 0.965;
      this.malletAngle = -38;
      this.malletOffsetX = -18;
      this.malletOffsetY = -8;
      this.waveScale = 0.72;
      this.waveOpacity = 0.68;
    });
    this.getUIContext().animateTo({ duration: 140, delay: 90, curve: Curve.EaseOut }, (): void => {
      this.fishScale = 1.025;
      this.malletAngle = -6;
      this.malletOffsetX = 4;
      this.malletOffsetY = 3;
      this.waveScale = 1.08;
      this.waveOpacity = 0.26;
    });
    this.getUIContext().animateTo({ duration: 170, delay: 230, curve: Curve.EaseOut }, (): void => {
      this.fishScale = 1;
      this.malletAngle = -12;
      this.malletOffsetX = 0;
      this.malletOffsetY = 0;
      this.waveScale = 1.3;
      this.waveOpacity = 0;
    });
  }

  @Builder
  Mallet() {
    Row() {
      Row()
        .width(42)
        .height(42)
        .backgroundColor('#9C653B')
        .borderRadius(21)
        .shadow({ radius: 8, color: '#5526150B', offsetY: 4 })
      Row()
        .width(112)
        .height(16)
        .linearGradient({
          angle: 0,
          colors: [['#6F3D20', 0], ['#B77B4A', 0.5], ['#7D4728', 1]]
        })
        .borderRadius(8)
        .margin({ left: -2 })
    }
    .width(152)
    .height(50)
    .rotate({ angle: this.malletAngle, centerX: '100%', centerY: '50%' })
    .translate({ x: this.malletOffsetX, y: this.malletOffsetY })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image(this.dark ? $r('app.media.muyu_body_dark') : $r('app.media.muyu_body_light'))
        .width('100%')
        .height(this.dark ? 300 : 250)
        .objectFit(ImageFit.Cover)
        .borderRadius(24)
        .scale({ x: this.fishScale, y: this.fishScale })

      Row()
        .width(220)
        .height(76)
        .border({ width: 2, color: this.dark ? '#4DD8B28C' : '#4DA9824B' })
        .borderRadius('50%')
        .opacity(this.waveOpacity)
        .scale({ x: this.waveScale, y: this.waveScale })
        .position({ x: '20%', y: this.dark ? 190 : 155 })

      Row() {
        this.Mallet()
      }
      .position({ x: '53%', y: this.dark ? 198 : 158 })

      Column({ space: 8 }) {
        ForEach(this.floatingTexts, (item: string) => {
          Text(item.substring(item.indexOf(':') + 1))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.dark ? '#F1D0AD' : '#8A5635')
            .padding({ left: 18, right: 18, top: 10, bottom: 10 })
            .backgroundColor(this.dark ? '#CC2A2724' : '#EFFFFDF8')
            .borderRadius(22)
        }, (item: string): string => item)
      }
      .margin({ top: 8 })
    }
    .width('100%')
    .height(this.dark ? 300 : 250)
    .onClick((): void => this.onHit())
  }
}
