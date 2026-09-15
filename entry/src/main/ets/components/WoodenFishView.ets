import { DesignTokens } from '../constants/DesignTokens';

@Component
export struct WoodenFishView {
  @Prop dark: boolean;
  @Prop @Watch('onHitSequenceChanged') hitSequence: number;
  @Prop label: string;
  @Prop floatingEnabled: boolean = true;
  @Prop disabled: boolean = false;
  onHit: () => void = (): void => {};
  @State fishScale: number = 1;
  @State malletAngle: number = 2;
  @State malletOffsetX: number = 0;
  @State malletOffsetY: number = 0;
  @State contactShadowOpacity: number = 0;
  @State viewWidth: number = 390;
  @State waveScale: number = 0.72;
  @State waveOpacity: number = 0;
  @State floatingTexts: string[] = [];
  private lastAnimatedSequence: number = 0;
  private animationGeneration: number = 0;

  private floatingTextDistanceFromNewest(index: number): number {
    return this.floatingTexts.length - 1 - index;
  }

  private floatingTextOffsetY(index: number): number {
    return -48 * this.floatingTextDistanceFromNewest(index);
  }

  private floatingTextOpacity(index: number): number {
    const distance: number = this.floatingTextDistanceFromNewest(index);
    if (distance <= 0) {
      return 1;
    }
    if (distance === 1) {
      return 0.76;
    }
    return 0.52;
  }

  private malletPositionY(): number {
    return this.dark ? -35 : (this.viewWidth >= 600 ? 8 : 38);
  }

  private contactShadowPositionY(): number {
    return this.dark ? 17 : (this.viewWidth >= 600 ? 45 : 78);
  }

  private contactMalletAngle(): number {
    return this.viewWidth >= 600 ? 1 : -2;
  }

  private contactMalletOffsetY(): number {
    return this.viewWidth >= 600 ? 0 : 5;
  }

  private onHitSequenceChanged(): void {
    if (this.hitSequence <= this.lastAnimatedSequence) {
      return;
    }
    this.lastAnimatedSequence = this.hitSequence;
    this.playHitAnimation();
    if (this.floatingEnabled) {
      const entry: string = `${this.hitSequence}:${this.label}`;
      const next: string[] = this.floatingTexts.concat([entry]);
      this.floatingTexts = next.slice(Math.max(0, next.length - 3));
      setTimeout((): void => {
        this.floatingTexts = this.floatingTexts.filter((item: string): boolean => item !== entry);
      }, 760);
    }
  }

  private playHitAnimation(): void {
    this.animationGeneration += 1;
    const generation: number = this.animationGeneration;
    this.getUIContext().animateTo({ duration: 110, curve: Curve.EaseIn }, (): void => {
      this.fishScale = 0.982;
      this.malletAngle = this.contactMalletAngle();
      this.malletOffsetX = -4;
      this.malletOffsetY = this.contactMalletOffsetY();
      this.waveScale = 0.72;
      this.waveOpacity = 0.52;
      this.contactShadowOpacity = 0.42;
    });
    setTimeout((): void => {
      if (generation !== this.animationGeneration) {
        return;
      }
      this.getUIContext().animateTo({ duration: 55, curve: Curve.EaseInOut }, (): void => {
        this.fishScale = 0.968;
        this.malletAngle = this.contactMalletAngle();
        this.malletOffsetX = -4;
        this.malletOffsetY = this.contactMalletOffsetY();
        this.waveScale = 0.82;
        this.waveOpacity = 0.56;
        this.contactShadowOpacity = 0.52;
      });
    }, 110);
    setTimeout((): void => {
      if (generation !== this.animationGeneration) {
        return;
      }
      this.getUIContext().animateTo({ duration: 125, curve: Curve.EaseOut }, (): void => {
        this.fishScale = 1.025;
        this.malletAngle = 4;
        this.malletOffsetX = 2;
        this.malletOffsetY = -2;
        this.waveScale = 1.08;
        this.waveOpacity = 0.26;
        this.contactShadowOpacity = 0.14;
      });
    }, 165);
    setTimeout((): void => {
      if (generation !== this.animationGeneration) {
        return;
      }
      this.getUIContext().animateTo({ duration: 170, curve: Curve.EaseOut }, (): void => {
        this.fishScale = 1;
        this.malletAngle = 2;
        this.malletOffsetX = 0;
        this.malletOffsetY = 0;
        this.waveScale = 1.3;
        this.waveOpacity = 0;
        this.contactShadowOpacity = 0;
      });
    }, 290);
  }

  @Builder
  Mallet() {
    Image($r('app.media.muyu_mallet'))
    .width(190)
    .height(66)
    .objectFit(ImageFit.Contain)
    .rotate({ angle: this.malletAngle, centerX: '90%', centerY: '50%' })
    .translate({ x: this.malletOffsetX, y: this.malletOffsetY })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image(this.dark ? $r('app.media.muyu_body_dark') : $r('app.media.muyu_body_light'))
        .width('100%')
        .height(280)
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
        .position({ x: '20%', y: 170 })

      Row()
        .width(54)
        .height(12)
        .backgroundColor(this.dark ? '#8A5A3829' : '#704427')
        .borderRadius('50%')
        .opacity(this.contactShadowOpacity)
        .shadow({ radius: 7, color: this.dark ? '#A66C4838' : '#80533120', offsetY: 1 })
        .position({ x: '44%', y: this.contactShadowPositionY() })

      Row() {
        this.Mallet()
      }
      .position({ x: '46%', y: this.malletPositionY() })

      Stack({ alignContent: Alignment.TopStart }) {
        ForEach(this.floatingTexts, (item: string, index: number) => {
          Text(item.substring(item.indexOf(':') + 1))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.dark ? '#F1D0AD' : '#8A5635')
            .padding({ left: 18, right: 18, top: 10, bottom: 10 })
            .backgroundColor(this.dark ? '#CC2A2724' : '#EFFFFDF8')
            .borderRadius(22)
            .opacity(this.floatingTextOpacity(index))
            .translate({ y: this.floatingTextOffsetY(index) })
        }, (item: string): string => item)
      }
      .width('100%')
      .height(44)
      .position({ x: 16, y: 8 })
    }
    .width('100%')
    .height(280)
    .backgroundColor(this.dark ? DesignTokens.darkBackground : DesignTokens.homeLightBackground)
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.viewWidth = Number(newValue.width);
    })
    .onClick((): void => {
      if (this.disabled) {
        const entry: string = `${Date.now()}:功德圆满`;
        const next: string[] = this.floatingTexts.concat([entry]);
        this.floatingTexts = next.slice(Math.max(0, next.length - 3));
        setTimeout((): void => {
          this.floatingTexts = this.floatingTexts.filter((item: string): boolean => item !== entry);
        }, 760);
        return;
      }
      this.onHit();
    })
    .accessibilityText(this.disabled ? '木鱼，今日目标已完成，功德圆满' : '木鱼，点击敲击积累功德')
  }
}
