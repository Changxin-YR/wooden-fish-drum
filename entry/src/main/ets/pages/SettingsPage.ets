import { AppSettings } from '../models/AppModels';
import { SoundType, ThemeMode } from '../models/Enums';

@Component
export struct SettingsPage {
  @Prop settings: AppSettings;
  onSoundToggle: (enabled: boolean) => void = (): void => {};
  onSoundTypeChange: (type: SoundType) => void = (): void => {};
  onVolumeChange: (value: number) => void = (): void => {};
  onVibrationToggle: (enabled: boolean) => void = (): void => {};
  onFloatingToggle: (enabled: boolean) => void = (): void => {};
  onThemeChange: (mode: ThemeMode) => void = (): void => {};
  onCustomText: (value: string) => void = (): void => {};
  onClearStats: () => void = (): void => {};
  @State showTextEditor: boolean = false;
  @State showClearConfirm: boolean = false;
  @State customText: string = '';

  private soundLabel(): string {
    if (this.settings.soundType === SoundType.DEEP) {
      return '木鱼 · 低沉';
    }
    if (this.settings.soundType === SoundType.CRISP) {
      return '木鱼 · 清脆';
    }
    return '木鱼 · 柔和';
  }

  private nextSoundType(): SoundType {
    if (this.settings.soundType === SoundType.DEEP) {
      return SoundType.CRISP;
    }
    if (this.settings.soundType === SoundType.CRISP) {
      return SoundType.SOFT;
    }
    return SoundType.DEEP;
  }

  @Builder
  SettingRow(icon: string, title: string, detail: string) {
    Row({ space: 12 }) {
      Text(icon)
        .width(38)
        .height(38)
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontColor('#8A5635')
        .backgroundColor('#F7EFE4')
        .borderRadius(19)
      Column({ space: 3 }) {
        Text(title).fontSize(16).fontColor('#2E2924')
        if (detail.length > 0) {
          Text(detail).fontSize(11).fontColor('#817970')
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
        .fontColor(this.settings.themeMode === mode ? '#8A5635' : '#817970')
      Text(label)
        .fontSize(14)
        .fontColor(this.settings.themeMode === mode ? '#8A5635' : '#817970')
    }
    .layoutWeight(1)
    .height(50)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.settings.themeMode === mode ? '#FBF4EA' : Color.Transparent)
    .border({
      width: this.settings.themeMode === mode ? 1 : 0,
      color: '#A9824B'
    })
    .borderRadius(16)
    .onClick((): void => this.onThemeChange(mode))
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Scroll() {
        Column({ space: 16 }) {
          Text('设置')
            .width('100%')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2E2924')

          Column() {
            Text('敲击反馈')
              .width('100%')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2E2924')
              .margin({ bottom: 8 })
            Row() {
              this.SettingRow('♪', '音效开关', '')
              Toggle({ type: ToggleType.Switch, isOn: this.settings.soundEnabled })
                .selectedColor('#9A612C')
                .onChange((value: boolean): void => this.onSoundToggle(value))
            }
            Divider().color('#EEE7DE')
            Row() {
              this.SettingRow('♬', '音色选择', this.soundLabel())
              Text('›').fontSize(28).fontColor('#8A5635')
            }
            .onClick((): void => {
              this.onSoundTypeChange(this.nextSoundType());
            })
            Divider().color('#EEE7DE')
            Column({ space: 4 }) {
              Row() {
                this.SettingRow('◖', '音量', `${Math.round(this.settings.volume * 100)}%`)
              }
              Slider({
                value: this.settings.volume,
                min: 0,
                max: 1,
                step: 0.05,
                style: SliderStyle.OutSet
              })
                .selectedColor('#9A612C')
                .trackColor('#E8E2D8')
                .onChange((value: number): void => {
                  this.onVolumeChange(value);
                })
            }
            Divider().color('#EEE7DE')
            Row() {
              this.SettingRow('≋', '振动反馈', '')
              Toggle({ type: ToggleType.Switch, isOn: this.settings.vibrationEnabled })
                .selectedColor('#9A612C')
                .onChange((value: boolean): void => this.onVibrationToggle(value))
            }
            Divider().color('#EEE7DE')
            Row() {
              this.SettingRow('T', '浮动文字', '显示敲击功德浮动文字')
              Toggle({ type: ToggleType.Switch, isOn: this.settings.floatingTextEnabled })
                .selectedColor('#9A612C')
                .onChange((value: boolean): void => this.onFloatingToggle(value))
            }
            Divider().color('#EEE7DE')
            Row() {
              this.SettingRow('✎', '自定义文字', this.settings.currentText)
              Text('›').fontSize(28).fontColor('#8A5635')
            }
            .onClick((): void => {
              this.customText = this.settings.currentText;
              this.showTextEditor = true;
            })
          }
          .padding(16)
          .backgroundColor('#FBF7F0')
          .borderRadius(20)

          Column({ space: 10 }) {
            Text('外观')
              .width('100%')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2E2924')
            Row({ space: 3 }) {
              this.ThemeButton(ThemeMode.SYSTEM, '◐', '跟随系统')
              this.ThemeButton(ThemeMode.LIGHT, '☼', '浅色')
              this.ThemeButton(ThemeMode.DARK, '☾', '深色')
            }
            .padding(3)
            .backgroundColor('#FFFDF8')
            .borderRadius(18)
          }
          .padding(16)
          .backgroundColor('#FBF7F0')
          .borderRadius(20)

          Column() {
            Text('数据')
              .width('100%')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2E2924')
              .margin({ bottom: 8 })
            Row() {
              this.SettingRow('⌫', '清除所有数据', '将清除所有敲击记录与统计数据')
              Text('›').fontSize(28).fontColor('#C06D48')
            }
            .onClick((): void => {
              this.showClearConfirm = true;
            })
            Divider().color('#EEE7DE')
            this.SettingRow('ⓘ', '隐私说明', '数据仅保存在本机，不申请网络权限')
            Divider().color('#EEE7DE')
            this.SettingRow('i', '关于应用', '功德木鱼 1.0.0')
          }
          .padding(16)
          .backgroundColor('#FBF7F0')
          .borderRadius(20)
          .margin({ bottom: 20 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 24 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor('#F6F1E8')

      if (this.showTextEditor) {
        Column({ space: 14 }) {
          Text('自定义敲击文字').fontSize(20).fontWeight(FontWeight.Bold)
          TextInput({ text: this.customText, placeholder: '请输入 1-12 个字符' })
            .height(50)
            .onChange((value: string): void => {
              this.customText = value;
            })
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).onClick((): void => {
              this.showTextEditor = false;
            })
            Button('保存').layoutWeight(1).backgroundColor('#9A612C').onClick((): void => {
              this.showTextEditor = false;
              this.onCustomText(this.customText);
            })
          }
        }
        .width('86%')
        .padding(20)
        .backgroundColor('#FFFDF8')
        .borderRadius(22)
      }

      if (this.showClearConfirm) {
        Column({ space: 14 }) {
          Text('清除统计数据？').fontSize(20).fontWeight(FontWeight.Bold)
          Text('此操作不可撤销，但会保留当前设置。')
            .fontSize(14).fontColor('#817970')
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).onClick((): void => {
              this.showClearConfirm = false;
            })
            Button('确认清除').layoutWeight(1).backgroundColor('#B85C3A').onClick((): void => {
              this.showClearConfirm = false;
              this.onClearStats();
            })
          }
        }
        .width('86%')
        .padding(20)
        .backgroundColor('#FFFDF8')
        .borderRadius(22)
      }
    }
    .width('100%')
    .height('100%')
  }
}
