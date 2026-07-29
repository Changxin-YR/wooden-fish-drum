@Component
export struct WoodenFishView {
  @Prop dark: boolean;
  @Prop label: string;
  @Prop floatingEnabled: boolean = true;
  onHit: () => void = (): void => {};
  @State scaleValue: number = 1;
  @State floatingTexts: string[] = [];
  private nextId: number = 0;

  private handleHit(): void {
    this.onHit();
    this.scaleValue = 0.95;
    this.getUIContext().animateTo({ duration: 100 }, (): void => {
      this.scaleValue = 1.02;
    });
    this.getUIContext().animateTo({ duration: 100, delay: 100 }, (): void => {
      this.scaleValue = 1;
    });
    if (this.floatingEnabled) {
      this.nextId++;
      const next: string[] = this.floatingTexts.concat([`${this.label} ${this.nextId}`]);
      this.floatingTexts = next.slice(Math.max(0, next.length - 3));
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image(this.dark ? $r('app.media.muyu_dark') : $r('app.media.muyu_brand'))
        .width('100%')
        .height(this.dark ? 300 : 250)
        .objectFit(ImageFit.Cover)
        .borderRadius(24)
        .scale({ x: this.scaleValue, y: this.scaleValue })

      Column({ space: 8 }) {
        ForEach(this.floatingTexts, (item: string) => {
          Text(item)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.dark ? '#F1D0AD' : '#8A5635')
            .padding({ left: 18, right: 18, top: 10, bottom: 10 })
            .backgroundColor(this.dark ? '#CC2A2724' : '#EFFFFDF8')
            .borderRadius(22)
        })
      }
      .margin({ top: 8 })
    }
    .width('100%')
    .height(this.dark ? 300 : 250)
    .onClick((): void => this.handleHit())
  }
}
