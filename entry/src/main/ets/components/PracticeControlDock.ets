import { AppSettings } from '../models/AppModels';
import { PracticeStatus, ToolType } from '../models/Enums';
import { DesignTokens } from '../constants/DesignTokens';
import { ThemeColors, ThemePalette } from '../constants/ThemePalette';
import { PracticeLayout } from '../utils/PracticeLayout';

@Component
export struct PracticeControlDock {
  @Prop settings: AppSettings;
  @Prop status: PracticeStatus = PracticeStatus.IDLE;
  @Prop selectedTool: ToolType = ToolType.WOODEN_FISH;
  @Prop dark: boolean = false;
  @Prop compact: boolean = false;
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
  @Prop incenseTargetSeconds: number = 0;
  @Prop message: string = '';
  @State selectedIncenseSeconds: number = 900;

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

  private audioThumbnail(): Resource {
    return this.dark ? $r('app.media.theme_mountain_dark') : $r('app.media.theme_mountain_light');
  }

  private isAutomaticActive(): boolean {
    return this.status === PracticeStatus.RUNNING || this.status === PracticeStatus.PAUSED;
  }

  @Builder
  ModeButton(automatic: boolean, label: string) {
    Button() {
      Row({ space: 8 }) {
        Text(automatic ? '↻' : '手').fontSize(17).fontWeight(FontWeight.Bold)
        Text(label).fontSize(15).fontWeight(FontWeight.Medium)
      }
    }
    .layoutWeight(1)
    .height(48)
    .type(ButtonType.Normal)
    .fontColor((automatic === this.isAutomaticActive()) ? this.colors().selectedText : this.colors().secondary)
    .backgroundColor((automatic === this.isAutomaticActive()) ? this.colors().accent : Color.Transparent)
    .borderRadius(24)
    .onClick((): void => {
      if (automatic) {
        if (this.status === PracticeStatus.RUNNING) {
          this.onPause();
        } else if (this.status === PracticeStatus.PAUSED) {
          this.onResume();
        } else {
          this.onStartAuto(this.settings.autoIntervalMs);
        }
      } else {
        this.onStop();
      }
    })
  }

  @Builder
  IntervalButton(intervalMs: number, label: string) {
    Button(label)
      .layoutWeight(1)
      .height(48)
      .type(ButtonType.Normal)
      .fontSize(14)
      .fontColor(this.settings.autoIntervalMs === intervalMs ? this.colors().selectedText : this.colors().secondary)
      .backgroundColor(this.settings.autoIntervalMs === intervalMs ? this.colors().accent : Color.Transparent)
      .borderRadius(24)
      .border({
        width: this.settings.autoIntervalMs === intervalMs ? 1 : 0,
        color: this.settings.autoIntervalMs === intervalMs ? this.colors().accent : Color.Transparent
      })
      .onClick((): void => this.onIntervalChange(intervalMs))
  }

  @Builder
  IncensePreset(durationSeconds: number, label: string) {
    Button(label)
      .layoutWeight(1)
      .height(48)
      .type(ButtonType.Normal)
      .fontSize(13)
      .fontColor((this.status === PracticeStatus.RUNNING || this.status === PracticeStatus.PAUSED ?
        this.incenseTargetSeconds : this.selectedIncenseSeconds) ===
        durationSeconds ? this.colors().selectedText : this.colors().secondary)
      .backgroundColor((this.status === PracticeStatus.RUNNING || this.status === PracticeStatus.PAUSED ?
        this.incenseTargetSeconds : this.selectedIncenseSeconds) ===
        durationSeconds ? this.colors().accent : Color.Transparent)
      .borderRadius(24)
      .onClick((): void => {
        if (this.status === PracticeStatus.IDLE || this.status === PracticeStatus.COMPLETED) {
          this.selectedIncenseSeconds = durationSeconds;
        }
      })
  }

  build() {
    Column({ space: this.compact ? 5 : 14 }) {
      if (this.selectedTool !== ToolType.INCENSE) {
        Row({ space: 4 }) {
          this.ModeButton(false, '手动')
          this.ModeButton(true, this.status === PracticeStatus.PAUSED ? '继续' :
            (this.status === PracticeStatus.RUNNING ? '暂停' : '自动'))
        }
        .width('100%')
        .padding(this.compact ? 0 : 4)
        .backgroundColor(this.colors().card)
        .border({ width: 1, color: this.colors().divider })
        .borderRadius(28)

        Row({ space: 4 }) {
          this.IntervalButton(1000, '1.0秒')
          this.IntervalButton(1500, '1.5秒')
          this.IntervalButton(2000, '2.0秒')
        }
        .width('100%')
        .padding(this.compact ? 0 : 4)
        .backgroundColor(this.colors().card)
        .border({ width: 1, color: this.colors().divider })
        .borderRadius(28)
      } else {
        Row({ space: 2 }) {
          this.IncensePreset(300, '5分')
          this.IncensePreset(600, '10分')
          this.IncensePreset(900, '15分')
          this.IncensePreset(1200, '20分')
          this.IncensePreset(1800, '30分')
        }
        .width('100%')
        .padding(this.compact ? 0 : 4)
        .backgroundColor(this.colors().card)
        .border({ width: 1, color: this.colors().divider })
        .borderRadius(28)
        Row({ space: 10 }) {
          Button(this.status === PracticeStatus.RUNNING ? '暂停' :
            (this.status === PracticeStatus.PAUSED ? '继续' : '选择时长开始'))
            .layoutWeight(1)
            .height(48)
            .type(ButtonType.Normal)
            .fontColor(this.colors().selectedText)
            .backgroundColor(this.colors().accent)
            .borderRadius(24)
            .onClick((): void => {
              if (this.status === PracticeStatus.RUNNING) {
                this.onPauseIncense();
              } else if (this.status === PracticeStatus.PAUSED) {
                this.onResumeIncense();
              } else {
                this.onStartIncense(this.selectedIncenseSeconds);
              }
            })
          Button('结束')
            .width(80)
            .height(48)
            .type(ButtonType.Normal)
            .fontColor(this.colors().secondary)
            .backgroundColor(this.colors().accentSoft)
            .borderRadius(24)
            .enabled(this.status === PracticeStatus.RUNNING || this.status === PracticeStatus.PAUSED)
            .onClick((): void => this.onStopIncense())
        }
        .width('100%')
      }

      if (PracticeLayout.resolve(this.compact ? 440 : 600).messageInControlDock) {
        Text(this.message)
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontColor(this.colors().primary)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.colors().card)
          .border({ width: 1, color: this.colors().divider })
          .borderRadius(DesignTokens.radiusControl)
      }

      Row({ space: this.compact ? 4 : 12 }) {
        Image(this.audioThumbnail())
          .width(this.compact ? 46 : 52)
          .height(this.compact ? 46 : 52)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
        Column({ space: 2 }) {
          Text(this.settings.selectedSoundId === 'deep' ? '低沉木音' :
            (this.settings.selectedSoundId === 'crisp' ? '清脆木音' : '柔和木音'))
            .fontSize(this.compact ? 12 : 14).fontWeight(FontWeight.Medium).fontColor(this.colors().primary)
            .maxLines(1)
          Text(this.settings.tapSoundEnabled ? '敲击音已开启' : '敲击音已关闭')
            .fontSize(this.compact ? 9 : 11).fontColor(this.colors().secondary)
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ minWidth: this.compact ? 56 : 88, maxWidth: this.compact ? 64 : 120 })
        Button(this.status === PracticeStatus.RUNNING ? 'Ⅱ' : '▶')
          .width(48).height(48).type(ButtonType.Circle)
          .fontSize(17).fontColor(this.colors().selectedText).backgroundColor(this.colors().accent)
          .onClick((): void => {
            if (this.status === PracticeStatus.RUNNING) {
              this.onPause();
            } else if (this.status === PracticeStatus.PAUSED) {
              this.onResume();
            } else if (this.selectedTool !== ToolType.INCENSE) {
              this.onStartAuto(this.settings.autoIntervalMs);
            }
          })
        Button(this.settings.tapSoundEnabled ? '音' : '静')
          .width(48).height(48).type(ButtonType.Circle)
          .fontSize(14)
          .fontColor(this.settings.tapSoundEnabled ? this.colors().selectedText : this.colors().secondary)
          .backgroundColor(this.settings.tapSoundEnabled ? this.colors().accent : this.colors().accentSoft)
          .onClick((): void => this.onSoundToggle(!this.settings.tapSoundEnabled))
          .accessibilityText(this.settings.tapSoundEnabled ? '关闭敲击音' : '开启敲击音')
        Slider({ value: this.settings.tapVolume * 100, min: 0, max: 100, step: 5 })
          .layoutWeight(1)
          .constraintSize({ minWidth: PracticeLayout.resolve(this.compact ? 440 : 600).consoleSliderMinWidth })
          .selectedColor(this.colors().accent)
          .blockColor(this.colors().accent)
          .trackColor(this.colors().divider)
          .onChange((value: number): void => this.onVolumeChange(value / 100))
        Column({ space: 0 }) {
          Text('振动').fontSize(9).fontColor(this.colors().secondary)
          Toggle({ type: ToggleType.Switch, isOn: this.settings.vibrationEnabled })
            .width(44)
            .selectedColor(this.colors().accent)
            .hitTestBehavior(HitTestMode.None)
        }
        .width(48)
        .height(PracticeLayout.resolve(this.compact ? 440 : 600).minimumTouchTarget)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => this.onVibrationToggle(!this.settings.vibrationEnabled))
        .accessibilityText(this.settings.vibrationEnabled ? '关闭振动' : '开启振动')
      }
      .width('100%')
      .constraintSize({ minHeight: this.compact ? 64 : 72 })
      .padding({ left: this.compact ? 8 : 14, right: this.compact ? 8 : 14,
        top: this.compact ? 8 : 10, bottom: this.compact ? 8 : 10 })
      .backgroundColor(this.colors().card)
      .borderRadius(DesignTokens.radiusCard)
      .border({ width: 1, color: this.colors().divider })
    }
    .width('100%')
  }
}
