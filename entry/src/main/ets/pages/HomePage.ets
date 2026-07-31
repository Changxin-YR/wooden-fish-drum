import { PracticeControlDock } from '../components/PracticeControlDock';
import { BeadsView } from '../components/BeadsView';
import { IncenseView } from '../components/IncenseView';
import { TodaySummaryCard } from '../components/TodaySummaryCard';
import { ToolSegmentedControl } from '../components/ToolSegmentedControl';
import { WoodenFishView } from '../components/WoodenFishView';
import { DesignTokens } from '../constants/DesignTokens';
import { AppSettings, StatsSummary } from '../models/AppModels';
import { PracticeState } from '../models/PracticeModels';
import { PracticeStatus, ToolType } from '../models/Enums';

@Component
export struct HomePage {
  @Prop settings: AppSettings;
  @Prop summary: StatsSummary;
  @Prop practice: PracticeState;
  @Prop dark: boolean;
  onHit: () => void = (): void => {};
  onBeadsGesture: (gestureId: number) => void = (_gestureId: number): void => {};
  onToolChange: (toolType: ToolType) => void = (_toolType: ToolType): void => {};
  onStartAuto: (intervalMs: number) => void = (_intervalMs: number): void => {};
  onPause: () => void = (): void => {};
  onResume: () => void = (): void => {};
  onStop: () => void = (): void => {};
  onIntervalChange: (intervalMs: number) => void = (_intervalMs: number): void => {};
  onSoundToggle: (enabled: boolean) => void = (_enabled: boolean): void => {};
  onVolumeChange: (volume: number) => void = (_volume: number): void => {};
  onVibrationToggle: (enabled: boolean) => void = (_enabled: boolean): void => {};
  onStartIncense: (durationSeconds: number) => void = (_durationSeconds: number): void => {};
  onPauseIncense: () => void = (): void => {};
  onResumeIncense: () => void = (): void => {};
  onStopIncense: () => void = (): void => {};
  @State viewportWidth: number = 390;

  private pageBackground(): string {
    return this.dark ? DesignTokens.darkBackground : '#FBF8F3';
  }

  private primaryText(): string {
    return this.dark ? DesignTokens.darkText : '#4E301C';
  }

  private secondaryText(): string {
    return this.dark ? DesignTokens.darkSecondary : '#8B7C6E';
  }

  private countValue(): number {
    return this.practice.manualCount + this.practice.automaticCount;
  }

  private toolLabel(): string {
    if (this.practice.selectedTool === ToolType.BEADS) {
      return '念珠次数';
    }
    if (this.practice.selectedTool === ToolType.INCENSE) {
      return '静心计时';
    }
    return '功课次数';
  }

  private incenseTimeText(): string {
    if (this.practice.incenseTargetSeconds === 0) {
      return '尚未开始';
    }
    if (this.practice.status === PracticeStatus.COMPLETED) {
      return '已完成';
    }
    const seconds: number = Math.max(0, this.practice.incenseRemainingSeconds);
    return `${Math.floor(seconds / 60).toString().padStart(2, '0')}:${(seconds % 60)
      .toString().padStart(2, '0')}`;
  }

  @Builder
  Header() {
    Column({ space: 10 }) {
      Text('静心木鱼')
        .width('100%')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Row({ space: 8 }) {
        Text('叶').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#8B6846')
        Text('单机版 · 离线使用').fontSize(13).fontColor(this.secondaryText())
      }
      .constraintSize({ minHeight: 48 })
      .padding({ left: 14, right: 14 })
      .backgroundColor(this.dark ? '#2A2622' : '#FFF9F1')
      .border({ width: 1, color: this.dark ? DesignTokens.darkDivider : '#E7D6C2' })
      .borderRadius(24)
      .alignSelf(ItemAlign.Start)
    }
    .width('100%')
  }

  @Builder
  PracticeCanvas() {
    Column({ space: 2 }) {
      if (this.practice.selectedTool === ToolType.WOODEN_FISH) {
        WoodenFishView({
          dark: this.dark,
          hitSequence: this.practice.hitSequence,
          label: this.settings.feedbackText,
          floatingEnabled: this.settings.feedbackTextEnabled,
          reducedMotion: this.settings.reducedMotion,
          onHit: (): void => this.onHit()
        })
      } else if (this.practice.selectedTool === ToolType.BEADS) {
        BeadsView({
          count: this.countValue(),
          dark: this.dark,
          reducedMotion: this.settings.reducedMotion,
          onGesture: (gestureId: number): void => this.onBeadsGesture(gestureId)
        })
      } else {
        IncenseView({
          targetSeconds: this.practice.incenseTargetSeconds,
          remainingSeconds: this.practice.incenseRemainingSeconds,
          status: this.practice.status,
          dark: this.dark,
          reducedMotion: this.settings.reducedMotion
        })
      }

      Text(this.toolLabel())
        .fontSize(14)
        .fontColor(this.secondaryText())
      Text(this.practice.selectedTool === ToolType.INCENSE ? this.incenseTimeText() : `${this.countValue()}`)
        .fontSize(this.practice.selectedTool === ToolType.INCENSE ? 24 : 54)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text(this.practice.lastMilestone > 0 ? `已到 ${this.practice.lastMilestone} 颗 · 继续安住当下` :
        (this.practice.status === PracticeStatus.RUNNING ? '练习进行中' :
          (this.practice.status === PracticeStatus.PAUSED ? '已暂停' : '愿你此刻安定专注')))
        .width('100%')
        .height(48)
        .fontSize(14)
        .fontColor(this.primaryText())
        .textAlign(TextAlign.Center)
        .backgroundColor(this.dark ? '#2B2723' : '#FCF5EA')
        .borderRadius(DesignTokens.radiusControl)
    }
    .width('100%')
  }

  @Builder
  Controls() {
    PracticeControlDock({
      settings: this.settings,
      status: this.practice.status,
      selectedTool: this.practice.selectedTool,
      dark: this.dark,
      onStartAuto: (intervalMs: number): void => this.onStartAuto(intervalMs),
      onPause: (): void => this.onPause(),
      onResume: (): void => this.onResume(),
      onStop: (): void => this.onStop(),
      onIntervalChange: (intervalMs: number): void => this.onIntervalChange(intervalMs),
      onSoundToggle: (enabled: boolean): void => this.onSoundToggle(enabled),
      onVolumeChange: (volume: number): void => this.onVolumeChange(volume),
      onVibrationToggle: (enabled: boolean): void => this.onVibrationToggle(enabled),
      incenseTargetSeconds: this.practice.incenseTargetSeconds,
      onStartIncense: (durationSeconds: number): void => this.onStartIncense(durationSeconds),
      onPauseIncense: (): void => this.onPauseIncense(),
      onResumeIncense: (): void => this.onResumeIncense(),
      onStopIncense: (): void => this.onStopIncense()
    })
  }

  @Builder
  PhoneContent() {
    Column({ space: 16 }) {
      this.Header()
      TodaySummaryCard({ summary: this.summary, dark: this.dark })
      ToolSegmentedControl({
        selected: this.practice.selectedTool,
        dark: this.dark,
        onChange: (toolType: ToolType): void => this.onToolChange(toolType)
      })
      this.PracticeCanvas()
      this.Controls()
    }
    .width('100%')
  }

  @Builder
  WideContent() {
    Column({ space: 18 }) {
      this.Header()
      TodaySummaryCard({ summary: this.summary, dark: this.dark })
      ToolSegmentedControl({
        selected: this.practice.selectedTool,
        dark: this.dark,
        onChange: (toolType: ToolType): void => this.onToolChange(toolType)
      })
      Row({ space: 24 }) {
        Column() { this.PracticeCanvas() }.layoutWeight(3)
        Column() { this.Controls() }.layoutWeight(2)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
  }

  build() {
    Scroll() {
      if (this.viewportWidth >= 600) {
        this.WideContent()
      } else {
        this.PhoneContent()
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 24 })
    .scrollBar(BarState.Off)
    .backgroundColor(this.pageBackground())
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.viewportWidth = Number(newValue.width);
    })
  }
}
