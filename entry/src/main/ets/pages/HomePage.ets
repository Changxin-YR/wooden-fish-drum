import { PracticeControlDock } from '../components/PracticeControlDock';
import { BeadsView } from '../components/BeadsView';
import { IncenseView } from '../components/IncenseView';
import { TodaySummaryCard } from '../components/TodaySummaryCard';
import { ToolSegmentedControl } from '../components/ToolSegmentedControl';
import { WoodenFishView } from '../components/WoodenFishView';
import { DesignTokens } from '../constants/DesignTokens';
import { ThemeColors, ThemePalette } from '../constants/ThemePalette';
import { AppSettings, StatsSummary } from '../models/AppModels';
import { PracticeState } from '../models/PracticeModels';
import { PracticeStatus, ToolType } from '../models/Enums';
import { PracticeLayout } from '../utils/PracticeLayout';

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

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

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

  private practiceMessage(): string {
    if (this.practice.lastMilestone > 0) {
      return `已到 ${this.practice.lastMilestone} 颗 · 继续安住当下`;
    }
    if (this.practice.status === PracticeStatus.RUNNING) {
      return '练习进行中';
    }
    if (this.practice.status === PracticeStatus.PAUSED) {
      return '已暂停';
    }
    return '愿你此刻安定专注';
  }

  @Builder
  Header(compact: boolean) {
    Column({ space: compact ? 5 : 8 }) {
      Text('静心木鱼')
        .width('100%')
        .fontSize(DesignTokens.titleSize(this.viewportWidth))
        .fontWeight(FontWeight.Bold)
        .fontColor(this.colors().primary)
      Row({ space: 8 }) {
        Text('▢').fontSize(13).fontWeight(FontWeight.Bold).fontColor(this.colors().accent)
        Text('单机版 · 离线使用').fontSize(13).fontColor(this.colors().secondary)
      }
      .height(compact ? 32 : 40)
      .padding({ left: 14, right: 14 })
      .backgroundColor(this.colors().card)
      .border({ width: 1, color: this.colors().divider })
      .borderRadius(24)
      .alignSelf(ItemAlign.Start)
    }
    .width('100%')
  }

  @Builder
  PracticeCanvas(compact: boolean) {
    Column({ space: 1 }) {
      if (this.practice.selectedTool === ToolType.WOODEN_FISH) {
        WoodenFishView({
          dark: this.dark,
          hitSequence: this.practice.hitSequence,
          label: this.settings.feedbackText,
          floatingEnabled: this.settings.feedbackTextEnabled,
          reducedMotion: this.settings.reducedMotion,
          compact: compact,
          canvasHeight: PracticeLayout.resolve(this.viewportWidth).canvasHeight,
          onHit: (): void => this.onHit()
        })
      } else if (this.practice.selectedTool === ToolType.BEADS) {
        BeadsView({
          count: this.countValue(),
          dark: this.dark,
          reducedMotion: this.settings.reducedMotion,
          compact: compact,
          canvasHeight: PracticeLayout.resolve(this.viewportWidth).canvasHeight,
          onGesture: (gestureId: number): void => this.onBeadsGesture(gestureId)
        })
      } else {
        IncenseView({
          targetSeconds: this.practice.incenseTargetSeconds,
          remainingSeconds: this.practice.incenseRemainingSeconds,
          status: this.practice.status,
          dark: this.dark,
          reducedMotion: this.settings.reducedMotion,
          compact: compact,
          canvasHeight: PracticeLayout.resolve(this.viewportWidth).canvasHeight
        })
      }

      Text(this.toolLabel())
        .fontSize(13)
        .fontColor(this.colors().secondary)
      Text(this.practice.selectedTool === ToolType.INCENSE ? this.incenseTimeText() : `${this.countValue()}`)
        .fontSize(this.practice.selectedTool === ToolType.INCENSE ? 24 : (compact ? 34 : 52))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.colors().primary)
      if (!compact) {
        Text(this.practiceMessage())
          .width('100%')
          .height(48)
          .fontSize(14)
          .fontColor(this.colors().primary)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.colors().accentSoft)
          .borderRadius(DesignTokens.radiusControl)
      }
    }
    .width('100%')
  }

  @Builder
  Controls(compact: boolean) {
    PracticeControlDock({
      settings: this.settings,
      status: this.practice.status,
      selectedTool: this.practice.selectedTool,
      dark: this.dark,
      compact: compact,
      onStartAuto: (intervalMs: number): void => this.onStartAuto(intervalMs),
      onPause: (): void => this.onPause(),
      onResume: (): void => this.onResume(),
      onStop: (): void => this.onStop(),
      onIntervalChange: (intervalMs: number): void => this.onIntervalChange(intervalMs),
      onSoundToggle: (enabled: boolean): void => this.onSoundToggle(enabled),
      onVolumeChange: (volume: number): void => this.onVolumeChange(volume),
      onVibrationToggle: (enabled: boolean): void => this.onVibrationToggle(enabled),
      incenseTargetSeconds: this.practice.incenseTargetSeconds,
      message: this.practiceMessage(),
      onStartIncense: (durationSeconds: number): void => this.onStartIncense(durationSeconds),
      onPauseIncense: (): void => this.onPauseIncense(),
      onResumeIncense: (): void => this.onResumeIncense(),
      onStopIncense: (): void => this.onStopIncense()
    })
  }

  @Builder
  PhoneContent() {
    Column({ space: PracticeLayout.resolve(this.viewportWidth).pageSpacing }) {
      this.Header(true)
      TodaySummaryCard({ summary: this.summary, dark: this.dark, compact: true })
      ToolSegmentedControl({
        selected: this.practice.selectedTool,
        dark: this.dark,
        compact: true,
        onChange: (toolType: ToolType): void => this.onToolChange(toolType)
      })
      this.PracticeCanvas(true)
      this.Controls(true)
    }
    .width('100%')
  }

  @Builder
  WideContent() {
    Column({ space: 18 }) {
      this.Header(false)
      TodaySummaryCard({ summary: this.summary, dark: this.dark })
      ToolSegmentedControl({
        selected: this.practice.selectedTool,
        dark: this.dark,
        onChange: (toolType: ToolType): void => this.onToolChange(toolType)
      })
      Row({ space: 24 }) {
        Column() { this.PracticeCanvas(false) }.layoutWeight(3)
        Column() { this.Controls(false) }.layoutWeight(2)
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
    .padding({ left: DesignTokens.pageInset(this.viewportWidth), right: DesignTokens.pageInset(this.viewportWidth),
      top: this.viewportWidth < 600 ? 10 : 22,
      bottom: this.viewportWidth < 600 ? 12 : 24 })
    .scrollBar(BarState.Off)
    .backgroundColor(this.colors().page)
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.viewportWidth = Number(newValue.width);
    })
  }
}
