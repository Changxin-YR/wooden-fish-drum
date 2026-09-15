import { AppSettings } from '../models/AppModels';
import { SoundType, ThemeMode } from '../models/Enums';
import { GENERAL_AVAILABLE_TEXTS } from '../constants/UserModeConfigs';
import { DesignTokens } from '../constants/DesignTokens';
import { AppVersion } from '../constants/AppVersion';
import { TextValidator } from '../utils/TextValidator';
import { PrivacyPage } from './PrivacyPage';

enum SettingDetailKind {
  STATIC,
  SOUND,
  VOLUME,
  CUSTOM_TEXT
}

@Component
export struct SettingsPage {
  @Prop @Watch('onSettingsChanged') settings: AppSettings;
  @Prop dark: boolean;
  onSoundToggle: (enabled: boolean) => void = (): void => {};
  onSoundTypeChange: (type: SoundType) => void = (): void => {};
  onVolumeChange: (value: number, mode: SliderChangeMode) => void = (): void => {};
  onVibrationToggle: (enabled: boolean) => void = (): void => {};
  onFloatingToggle: (enabled: boolean) => void = (): void => {};
  onThemeChange: (mode: ThemeMode) => void = (): void => {};
  onCustomText: (value: string) => void = (): void => {};
  onClearStats: () => void = (): void => {};
  @State showTextEditor: boolean = false;
  @State showClearConfirm: boolean = false;
  @State showSoundPicker: boolean = false;
  @State showPrivacy: boolean = false;
  @State customText: string = '';
  @State volumeValue: number = 0.7;
  @State textError: string = '';
  @State clearCountdown: number = 0;
  private clearTimerId: number = -1;

  aboutToAppear(): void {
    this.syncVisibleSettings();
  }

  private onSettingsChanged(): void {
    this.syncVisibleSettings();
  }

  private syncVisibleSettings(): void {
    if (!this.showTextEditor) {
      this.customText = this.settings.currentText;
    }
    this.volumeValue = this.settings.volume;
  }

  aboutToDisappear(): void {
    this.stopClearTimer();
  }

  private pageBackground(): string {
    return this.dark ? DesignTokens.darkBackground : DesignTokens.lightBackground;
  }

  private card(): string {
    return this.dark ? DesignTokens.darkCard : DesignTokens.lightCard;
  }

  private field(): string {
    return this.dark ? DesignTokens.darkField : DesignTokens.lightCard;
  }

  private primaryText(): string {
    return this.dark ? DesignTokens.darkText : DesignTokens.lightText;
  }

  private secondaryText(): string {
    return this.dark ? DesignTokens.darkSecondary : DesignTokens.lightSecondary;
  }

  private divider(): string {
    return this.dark ? DesignTokens.darkDivider : DesignTokens.lightDivider;
  }

  private startClearTimer(): void {
    this.clearCountdown = 3;
    this.clearTimerId = setInterval((): void => {
      this.clearCountdown--;
      if (this.clearCountdown <= 0) {
        this.stopClearTimer();
      }
    }, 1000);
  }

  private stopClearTimer(): void {
    if (this.clearTimerId !== -1) {
      clearInterval(this.clearTimerId);
      this.clearTimerId = -1;
    }
    this.clearCountdown = 0;
  }

  private soundLabel(): string {
    if (this.settings.soundType === SoundType.DEEP) {
      return '木鱼 · 低沉';
    }
    if (this.settings.soundType === SoundType.CRISP) {
      return '木鱼 · 清脆';
    }
    return '木鱼 · 柔和';
  }

  @Builder
  SettingRow(icon: string, title: string, detail: string, detailKind: SettingDetailKind) {
    Row({ space: 12 }) {
      Text(icon)
        .width(38)
        .height(38)
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontColor('#8A5635')
        .backgroundColor(this.dark ? '#3B3530' : '#F7EFE4')
        .borderRadius(19)
      Column({ space: 3 }) {
        Text(title).fontSize(16).fontColor(this.primaryText())
        if (detailKind === SettingDetailKind.SOUND) {
          Text(this.soundLabel()).fontSize(11).fontColor(this.secondaryText())
        } else if (detailKind === SettingDetailKind.VOLUME) {
          Text(`${Math.round(this.volumeValue * 100)}%`).fontSize(11).fontColor(this.secondaryText())
        } else if (detailKind === SettingDetailKind.CUSTOM_TEXT) {
          Text(this.customText).fontSize(11).fontColor(this.secondaryText())
        } else if (detail.length > 0) {
          Text(detail).fontSize(11).fontColor(this.secondaryText())
        }
      }
      .layoutWeight(1)
      .constraintSize({ minWidth: 0 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .constraintSize({ minHeight: 58 })
  }

  @Builder
  ThemeButton(mode: ThemeMode, icon: string, label: string) {
    Row({ space: 7 }) {
      Text(icon)
        .fontSize(18)
        .fontColor(this.settings.themeMode === mode ? (this.dark ? '#D8B28C' : '#8A5635') :
          this.secondaryText())
      Text(label)
        .fontSize(14)
        .fontColor(this.settings.themeMode === mode ? (this.dark ? '#D8B28C' : '#8A5635') :
          this.secondaryText())
    }
    .layoutWeight(1)
    .height(50)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.settings.themeMode === mode ? (this.dark ? '#3B3530' : '#FBF4EA') :
      Color.Transparent)
    .border({
      width: this.settings.themeMode === mode ? 1 : 0,
      color: '#A9824B'
    })
    .borderRadius(16)
    .onClick((): void => this.onThemeChange(mode))
  }

  @Builder
  SoundOption(type: SoundType, title: string, detail: string) {
    Row({ space: 12 }) {
      Text(type === SoundType.DEEP ? '●' : (type === SoundType.CRISP ? '◆' : '◌'))
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontColor('#A9824B')
        .backgroundColor(this.dark ? '#3B3530' : '#F7EFE4')
        .borderRadius(20)
      Column({ space: 3 }) {
        Text(title).fontSize(16).fontColor(this.primaryText())
        Text(detail).fontSize(12).fontColor(this.secondaryText())
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text(this.settings.soundType === type ? '✓' : '')
        .fontSize(20)
        .fontColor('#A9824B')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.settings.soundType === type ? (this.dark ? '#3B3530' : '#FBF4EA') :
      Color.Transparent)
    .borderRadius(16)
    .onClick((): void => {
      this.showSoundPicker = false;
      this.onSoundTypeChange(type);
    })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Scroll() {
        Column({ space: 16 }) {
          Text('设置')
            .width('100%')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Column() {
            Text('敲击反馈')
              .width('100%')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.primaryText())
              .margin({ bottom: 8 })
            Row() {
              Row() {
                this.SettingRow('♪', '音效开关', '', SettingDetailKind.STATIC)
              }
              .layoutWeight(1)
              .constraintSize({ minWidth: 0 })
              Toggle({ type: ToggleType.Switch, isOn: this.settings.soundEnabled })
                .width(44)
                .margin({ right: 8 })
                .responseRegion({ x: -4, y: -12, width: 52, height: 48 })
                .selectedColor('#9A612C')
                .onChange((value: boolean): void => this.onSoundToggle(value))
                .accessibilityText('音效开关')
            }
            .width('100%')
            Divider().color(this.divider())
            Row() {
              Row() {
                this.SettingRow('≋', '振动反馈', '', SettingDetailKind.STATIC)
              }
              .layoutWeight(1)
              .constraintSize({ minWidth: 0 })
              Toggle({ type: ToggleType.Switch, isOn: this.settings.vibrationEnabled })
                .width(44)
                .margin({ right: 8 })
                .responseRegion({ x: -4, y: -12, width: 52, height: 48 })
                .selectedColor('#9A612C')
                .onChange((value: boolean): void => this.onVibrationToggle(value))
                .accessibilityText('振动反馈开关')
            }
            .width('100%')
            Divider().color(this.divider())
            Row() {
              Row() {
                this.SettingRow('T', '浮动文字', '显示敲击功德浮动文字', SettingDetailKind.STATIC)
              }
              .layoutWeight(1)
              .constraintSize({ minWidth: 0 })
              Toggle({ type: ToggleType.Switch, isOn: this.settings.floatingTextEnabled })
                .width(44)
                .margin({ right: 8 })
                .responseRegion({ x: -4, y: -12, width: 52, height: 48 })
                .selectedColor('#9A612C')
                .onChange((value: boolean): void => this.onFloatingToggle(value))
                .accessibilityText('浮动文字开关')
            }
            .width('100%')
            Divider().color(this.divider())
            Column({ space: 4 }) {
              Row() {
                this.SettingRow('◖', '音量', '', SettingDetailKind.VOLUME)
              }
              Slider({
                value: this.volumeValue,
                min: 0,
                max: 1,
                step: 0.05,
                style: SliderStyle.OutSet
              })
                .selectedColor('#9A612C')
                .trackColor(this.dark ? DesignTokens.darkDivider : '#E8E2D8')
                .onChange((value: number, mode: SliderChangeMode): void => {
                  this.volumeValue = value;
                  this.onVolumeChange(value, mode);
                })
            }
            Divider().color(this.divider())
            Row() {
              Row() {
                this.SettingRow('♬', '音色选择', '', SettingDetailKind.SOUND)
              }
              .layoutWeight(1)
              .constraintSize({ minWidth: 0 })
              Text('›')
                .fontSize(28)
                .fontColor('#8A5635')
                .width(44)
                .margin({ right: 8 })
                .textAlign(TextAlign.Center)
            }
            .onClick((): void => {
              this.showSoundPicker = true;
            })
            .accessibilityText(`当前音色：${this.soundLabel()}，点击选择音色`)
            Divider().color(this.divider())
            Row() {
              Row() {
                this.SettingRow('✎', '自定义文字', '', SettingDetailKind.CUSTOM_TEXT)
              }
              .layoutWeight(1)
              .constraintSize({ minWidth: 0 })
              Text('›')
                .fontSize(28)
                .fontColor('#8A5635')
                .width(44)
                .margin({ right: 8 })
                .textAlign(TextAlign.Center)
            }
            .onClick((): void => {
              this.customText = this.settings.currentText;
              this.showTextEditor = true;
            })
          }
          .padding(16)
          .backgroundColor(this.card())
          .borderRadius(20)

          Column({ space: 10 }) {
            Text('外观')
              .width('100%')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.primaryText())
            Row({ space: 3 }) {
              this.ThemeButton(ThemeMode.SYSTEM, '◐', '跟随系统')
              this.ThemeButton(ThemeMode.LIGHT, '☼', '浅色')
              this.ThemeButton(ThemeMode.DARK, '☾', '深色')
            }
            .padding(3)
            .backgroundColor(this.field())
            .borderRadius(18)
          }
          .padding(16)
          .backgroundColor(this.card())
          .borderRadius(20)

          Column() {
            Text('数据')
              .width('100%')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.primaryText())
              .margin({ bottom: 8 })
            Row() {
              this.SettingRow('⌫', '清除所有数据', '将清除所有敲击记录与统计数据',
                SettingDetailKind.STATIC)
              Text('›').fontSize(28).fontColor('#C06D48')
            }
            .onClick((): void => {
              this.showClearConfirm = true;
              this.startClearTimer();
            })
            Divider().color(this.divider())
            Row() {
              this.SettingRow('ⓘ', '隐私政策', '数据仅保存在本机，不申请网络权限', SettingDetailKind.STATIC)
              Text('›').fontSize(28).fontColor('#8A5635')
            }
            .onClick((): void => {
              this.showPrivacy = true;
            })
            Divider().color(this.divider())
            this.SettingRow('i', '关于应用', `敲敲木鱼 ${AppVersion.version}`, SettingDetailKind.STATIC)
          }
          .padding(16)
          .backgroundColor(this.card())
          .borderRadius(20)
          .margin({ bottom: 20 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 24 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor(this.pageBackground())

      if (this.showSoundPicker) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#66000000')
          .onClick((): void => {
            this.showSoundPicker = false;
          })
        Column({ space: 10 }) {
          Row() {
            Text('选择音色').fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.primaryText())
            Blank()
            Text('×').fontSize(28).fontColor(this.secondaryText()).onClick((): void => {
              this.showSoundPicker = false;
            })
          }
          Text('选择后立即试听，所有音色均为本地资源。')
            .width('100%')
            .fontSize(12)
            .fontColor(this.secondaryText())
          this.SoundOption(SoundType.DEEP, '低沉木鱼', '厚实、沉稳，适合静心')
          this.SoundOption(SoundType.CRISP, '清脆木鱼', '明亮、清晰，反馈明确')
          this.SoundOption(SoundType.SOFT, '柔和木鱼', '轻柔、耐听，适合长时间使用')
        }
        .width('88%')
        .padding(20)
        .backgroundColor(this.field())
        .borderRadius(22)
        .shadow({ radius: 18, color: '#4017130F', offsetY: 6 })
      }

      if (this.showTextEditor) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#66000000')
          .onClick((): void => {
            this.showTextEditor = false;
            this.customText = this.settings.currentText;
            this.textError = '';
          })
        Column({ space: 14 }) {
          Text('自定义敲击文字').fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.primaryText())
          Text('选择预设或输入自定义文字（1-12个字符）')
            .fontSize(12)
            .fontColor(this.secondaryText())
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(GENERAL_AVAILABLE_TEXTS, (text: string) => {
              Text(text)
                .fontSize(14)
                .fontColor(this.customText === text ? '#FFFFFF' : this.primaryText())
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.customText === text ? '#9A612C' :
                  (this.dark ? '#3B3530' : '#F7EFE4'))
                .borderRadius(20)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => {
                  this.customText = text;
                  this.textError = '';
                })
            })
          }
          .width('100%')
          TextInput({ text: this.customText, placeholder: '请输入 1-12 个字符' })
            .height(50)
            .onChange((value: string): void => {
              this.customText = value;
              this.textError = '';
            })
          if (this.textError.length > 0) {
            Text(this.textError)
              .width('100%')
              .fontSize(12)
              .fontColor('#E05040')
          }
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).onClick((): void => {
              this.showTextEditor = false;
              this.customText = this.settings.currentText;
              this.textError = '';
            })
            Button('保存').layoutWeight(1).backgroundColor('#9A612C').onClick((): void => {
              const normalized: string = TextValidator.normalize(this.customText);
              if (!TextValidator.isValid(normalized)) {
                this.textError = '请输入1-12个有效字符';
                return;
              }
              this.customText = normalized;
              this.textError = '';
              this.showTextEditor = false;
              this.onCustomText(normalized);
            })
          }
        }
        .width('86%')
        .padding(20)
        .backgroundColor(this.field())
        .borderRadius(22)
      }

      if (this.showClearConfirm) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#66000000')
          .onClick((): void => {
            this.showClearConfirm = false;
            this.stopClearTimer();
          })
        Column({ space: 14 }) {
          Text('清除统计数据？').fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.primaryText())
          Text('此操作不可撤销，但会保留当前设置。')
            .fontSize(14).fontColor(this.secondaryText())
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).onClick((): void => {
              this.showClearConfirm = false;
              this.stopClearTimer();
            })
            Button(this.clearCountdown > 0 ? `确认清除 (${this.clearCountdown}s)` : '确认清除')
              .layoutWeight(1)
              .backgroundColor('#B85C3A')
              .enabled(this.clearCountdown === 0)
              .onClick((): void => {
                this.showClearConfirm = false;
                this.stopClearTimer();
                this.onClearStats();
              })
          }
        }
        .width('86%')
        .padding(20)
        .backgroundColor(this.field())
        .borderRadius(22)
      }

      if (this.showPrivacy) {
        PrivacyPage({
          dark: this.dark,
          onBack: (): void => {
            this.showPrivacy = false;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
