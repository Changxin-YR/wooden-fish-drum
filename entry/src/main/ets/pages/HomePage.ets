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
import { FeedbackText } from '../utils/FeedbackText';

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
  onStartTarget: () => void = (): void => {};
  onRestartTarget: () => void = (): void => {};
  onTargetChange: (targetCount: number) => Promise<boolean> = async (): Promise<boolean> => false;
  onModalStateChange: (visible: boolean) => void = (_visible: boolean): void => {};
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
  @State targetPickerOpen: boolean = false;
  @State targetInput: string = '';
  @State targetError: string = '';
  @State targetSaving: boolean = false;

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

  private openTargetPicker(): void {
    this.targetInput = `${this.settings.targetCount}`;
    this.targetError = '';
    this.targetPickerOpen = true;
    this.onModalStateChange(true);
  }

  private async applyTarget(value: number): Promise<void> {
    if (!Number.isInteger(value) || value <= 0 || value > 1000000000) {
      this.targetError = '请输入 1 至 1000000000 的正整数';
      return;
    }
    this.targetSaving = true;
    const saved: boolean = await this.onTargetChange(value);
    this.targetSaving = false;
    if (!saved) {
      this.targetError = '目标保存失败，请重试';
      return;
    }
    this.targetPickerOpen = false;
    this.onModalStateChange(false);
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
      Text(FeedbackText.todayTitle(this.settings.feedbackText))
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
      automaticActive: this.practice.automaticActive,
      targetActive: this.practice.targetActive,
      targetCompleted: this.practice.targetCompleted,
      targetCount: this.practice.targetCount,
      sessionCount: this.practice.sessionCount,
      selectedTool: this.practice.selectedTool,
      dark: this.dark,
      compact: compact,
      onStartAuto: (intervalMs: number): void => this.onStartAuto(intervalMs),
      onStartTarget: (): void => this.onStartTarget(),
      onRestartTarget: (): void => this.onRestartTarget(),
      onOpenTargetPicker: (): void => this.openTargetPicker(),
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
    Stack({ alignContent: Alignment.Center }) {
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

      if (this.targetPickerOpen) {
        Row().width('100%').height('100%').backgroundColor('#73000000')
          .onClick((): void => {
            if (!this.targetSaving) {
              this.targetPickerOpen = false;
              this.onModalStateChange(false);
            }
          })
          .accessibilityText('关闭目标选择')
        Column({ space: 12 }) {
          Text('设置本轮目标').fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.colors().primary)
          Row({ space: 6 }) {
            ForEach([108, 1000, 10000], (value: number) => {
              Button(value.toLocaleString()).layoutWeight(1).height(48).type(ButtonType.Normal)
                .fontColor(this.settings.targetCount === value ? this.colors().selectedText : this.colors().primary)
                .backgroundColor(this.settings.targetCount === value ? this.colors().accent : this.colors().accentSoft)
                .borderRadius(8).onClick((): void => { this.applyTarget(value); })
            }, (value: number): string => `${value}`)
          }.width('100%')
          TextInput({ text: this.targetInput, placeholder: '输入任意正整数' })
            .width('100%').height(48).type(InputType.Number).fontColor(this.colors().primary)
            .backgroundColor(this.colors().accentSoft).borderRadius(8)
            .onChange((value: string): void => { this.targetInput = value; this.targetError = ''; })
          if (this.targetError.length > 0) {
            Text(this.targetError).width('100%').fontSize(12).fontColor('#B85C3A')
          }
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).height(48).enabled(!this.targetSaving).onClick((): void => {
              this.targetPickerOpen = false;
              this.onModalStateChange(false);
            })
            Button(this.targetSaving ? '保存中…' : '保存并开始').layoutWeight(1).height(48)
              .enabled(!this.targetSaving).backgroundColor(this.colors().accent).onClick((): void => {
                const raw: string = this.targetInput.trim();
                if (!/^\d+$/.test(raw)) {
                  this.targetError = '请输入正整数';
                  return;
                }
                this.applyTarget(Number(raw));
              })
          }
        }
        .width(this.viewportWidth < 600 ? '88%' : 420).padding(20)
        .backgroundColor(this.colors().card).borderRadius(8)
        .shadow({ radius: 18, color: '#4017130F', offsetY: 6 })
      }
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.viewportWidth = Number(newValue.width);
    })
  }
}
