import { AppSettings } from '../models/AppModels';
import { PracticeStatus, ToolType } from '../models/Enums';
import { DesignTokens } from '../constants/DesignTokens';

@Component
export struct PracticeControlDock {
  @Prop settings: AppSettings;
  @Prop status: PracticeStatus = PracticeStatus.IDLE;
  @Prop selectedTool: ToolType = ToolType.WOODEN_FISH;
  @Prop dark: boolean = false;
  onStartAuto: (intervalMs: number) => void = (_intervalMs: number): void => {};
  onPause: () => void = (): void => {};
  onResume: () => void = (): void => {};
  onStop: () => void = (): void => {};
  onIntervalChange: (intervalMs: number) => void = (_intervalMs: number): void => {};
  onSoundToggle: (enabled: boolean) => void = (_enabled: boolean): void => {};
  onVolumeChange: (volume: number) => void = (_volume: number): void => {};
  onVibrationToggle: (enabled: boolean) => void = (_enabled: boolean): void => {};

  private primaryText(): string {
    return this.dark ? DesignTokens.darkText : '#56371F';
  }

  private secondaryText(): string {
    return this.dark ? DesignTokens.darkSecondary : '#81756A';
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
    .fontColor((automatic === this.isAutomaticActive()) ? '#FFFFFF' : this.secondaryText())
    .backgroundColor((automatic === this.isAutomaticActive()) ? '#A66C39' : Color.Transparent)
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
      .fontColor(this.settings.autoIntervalMs === intervalMs ? '#FFFFFF' : this.secondaryText())
      .backgroundColor(this.settings.autoIntervalMs === intervalMs ? '#A66C39' : Color.Transparent)
      .borderRadius(24)
      .border({
        width: this.settings.autoIntervalMs === intervalMs ? 1 : 0,
        color: this.settings.autoIntervalMs === intervalMs ? '#D0A273' : Color.Transparent
      })
      .onClick((): void => this.onIntervalChange(intervalMs))
  }

  build() {
    Column({ space: 14 }) {
      if (this.selectedTool !== ToolType.INCENSE) {
        Row({ space: 4 }) {
          this.ModeButton(false, '手动')
          this.ModeButton(true, this.status === PracticeStatus.PAUSED ? '继续' :
            (this.status === PracticeStatus.RUNNING ? '暂停' : '自动'))
        }
        .width('100%')
        .padding(4)
        .backgroundColor(this.dark ? '#2E2925' : '#F7F1E9')
        .borderRadius(28)

        Row({ space: 4 }) {
          this.IntervalButton(1000, '1.0秒')
          this.IntervalButton(1500, '1.5秒')
          this.IntervalButton(2000, '2.0秒')
        }
        .width('100%')
        .padding(4)
        .backgroundColor(this.dark ? '#2E2925' : '#FAF6F0')
        .borderRadius(28)
      } else {
        Text('选择时长后即可开始一段静心计时')
          .width('100%')
          .height(48)
          .fontSize(14)
          .fontColor(this.secondaryText())
          .textAlign(TextAlign.Center)
      }

      Row({ space: 12 }) {
        Column({ space: 2 }) {
          Text(this.settings.selectedSoundId === 'deep' ? '低沉木音' :
            (this.settings.selectedSoundId === 'crisp' ? '清脆木音' : '柔和木音'))
            .fontSize(14).fontWeight(FontWeight.Medium).fontColor(this.primaryText())
          Text(this.settings.tapSoundEnabled ? '敲击音已开启' : '敲击音已关闭')
            .fontSize(11).fontColor(this.secondaryText())
        }
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ minWidth: 88 })
        Button(this.status === PracticeStatus.RUNNING ? 'Ⅱ' : '▶')
          .width(48).height(48).type(ButtonType.Circle)
          .fontSize(17).fontColor('#FFFFFF').backgroundColor('#A66C39')
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
          .fontColor(this.settings.tapSoundEnabled ? '#FFFFFF' : this.secondaryText())
          .backgroundColor(this.settings.tapSoundEnabled ? '#A66C39' :
            (this.dark ? '#3A3530' : '#EFE9E1'))
          .onClick((): void => this.onSoundToggle(!this.settings.tapSoundEnabled))
          .accessibilityText(this.settings.tapSoundEnabled ? '关闭敲击音' : '开启敲击音')
        Slider({ value: this.settings.tapVolume * 100, min: 0, max: 100, step: 5 })
          .layoutWeight(1)
          .selectedColor('#A66C39')
          .blockColor('#A66C39')
          .trackColor(this.dark ? '#4A433D' : '#E4DDD5')
          .onChange((value: number): void => this.onVolumeChange(value / 100))
        Text('振动').fontSize(12).fontColor(this.secondaryText())
        Toggle({ type: ToggleType.Switch, isOn: this.settings.vibrationEnabled })
          .width(48)
          .selectedColor('#A66C39')
          .onChange((enabled: boolean): void => this.onVibrationToggle(enabled))
      }
      .width('100%')
      .constraintSize({ minHeight: 72 })
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(this.dark ? DesignTokens.darkCard : '#FFFEFC')
      .borderRadius(DesignTokens.radiusCard)
      .border({ width: 1, color: this.dark ? DesignTokens.darkDivider : '#EFE5D9' })
    }
    .width('100%')
  }
}
