const SOURCE_WIDTH: number = 604;
const SOURCE_HEIGHT: number = 1095;
const CANVAS_HEIGHT: number = 330;
const IMAGE_WIDTH: number = CANVAS_HEIGHT * SOURCE_WIDTH / SOURCE_HEIGHT;
const BEAD_COUNT: number = 27;

class BeadPoint {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

@Component
export struct BeadsView {
  @Prop count: number = 0;
  @Prop dark: boolean = false;
  @Prop reducedMotion: boolean = false;
  onGesture: (gestureId: number) => void = (_gestureId: number): void => {};
  @State suppressNextClick: boolean = false;
  private gestureSequence: number = 0;
  private activeGestureId: number = -1;

  private beadPoints(): BeadPoint[] {
    const points: BeadPoint[] = [];
    for (let index: number = 0; index < BEAD_COUNT; index++) {
      const angle: number = Math.PI * 2 * index / BEAD_COUNT - Math.PI / 2;
      points.push(new BeadPoint(
        302 + Math.cos(angle) * 222,
        275 + Math.sin(angle) * 218
      ));
    }
    return points;
  }

  private activeIndex(): number {
    return this.count <= 0 ? -1 : (this.count - 1) % BEAD_COUNT;
  }

  private nextGestureId(): number {
    this.gestureSequence++;
    return this.gestureSequence;
  }

  private handleClick(): void {
    if (this.suppressNextClick) {
      this.suppressNextClick = false;
      return;
    }
    this.onGesture(this.nextGestureId());
  }

  private beginPan(): void {
    this.suppressNextClick = true;
    this.activeGestureId = this.nextGestureId();
    this.onGesture(this.activeGestureId);
  }

  private continuePan(): void {
    if (this.activeGestureId >= 0) {
      this.onGesture(this.activeGestureId);
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.practice_beads'))
        .width(IMAGE_WIDTH)
        .height(CANVAS_HEIGHT)
        .objectFit(ImageFit.Contain)

      ForEach(this.beadPoints(), (point: BeadPoint, index: number) => {
        if (index === this.activeIndex()) {
          Circle()
            .width(22)
            .height(22)
            .fill('#70FFF8EC')
            .border({ width: 3, color: this.dark ? '#F2D5A6' : '#9A612C' })
            .shadow({ radius: 7, color: '#99F2C078' })
            .scale({ x: this.reducedMotion ? 1 : 1.08, y: this.reducedMotion ? 1 : 1.08 })
            .position({
              x: point.x * IMAGE_WIDTH / SOURCE_WIDTH - 11,
              y: point.y * CANVAS_HEIGHT / SOURCE_HEIGHT - 11
            })
        }
      }, (_point: BeadPoint, index: number): string => `${index}`)
    }
    .width(IMAGE_WIDTH)
    .height(CANVAS_HEIGHT)
    .onClick((): void => this.handleClick())
    .gesture(
      PanGesture({ direction: PanDirection.All, distance: 6 })
        .onActionStart((): void => this.beginPan())
        .onActionUpdate((): void => this.continuePan())
        .onActionEnd((): void => {
          this.activeGestureId = -1;
        })
    )
    .accessibilityText('念珠练习区，点击或轻扫计数')
    .accessibilityDescription('每次手势只计数一次')
  }
}
