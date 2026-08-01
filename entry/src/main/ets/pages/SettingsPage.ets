import { DesignTokens } from '../constants/DesignTokens';
import { ThemeColors, ThemePalette } from '../constants/ThemePalette';
import { AppSettings } from '../models/AppModels';
import { SettingsRoute, SoundType, ThemeMode, ToolType } from '../models/Enums';
import { FeedbackText } from '../utils/FeedbackText';
import { ThemeResolver } from '../utils/ThemeResolver';

enum ClearScope {
  NONE = 'none',
  TODAY = 'today',
  ALL = 'all'
}

@Component
export struct SettingsPage {
  @Prop settings: AppSettings;
  @Prop dark: boolean = false;
  onToolChange: (toolType: ToolType) => void = (): void => {};
  onIntervalChange: (intervalMs: number) => void = (): void => {};
  onSoundToggle: (enabled: boolean) => void = (): void => {};
  onSoundTypeChange: (type: SoundType) => void = (): void => {};
  onVolumeChange: (value: number) => void = (): void => {};
  onVibrationToggle: (enabled: boolean) => void = (): void => {};
  onFeedbackTextToggle: (enabled: boolean) => void = (): void => {};
  onFeedbackTextSave: (value: string) => Promise<boolean> = async (): Promise<boolean> => false;
  onReducedMotionToggle: (enabled: boolean) => void = (): void => {};
  onThemeChange: (mode: ThemeMode) => void = (): void => {};
  onClearToday: () => void = (): void => {};
  onClearAll: () => void = (): void => {};
  onNavigate: (route: SettingsRoute) => void = (): void => {};
  onModalStateChange: (visible: boolean) => void = (_visible: boolean): void => {};
  @State clearScope: ClearScope = ClearScope.NONE;
  @State customTextOpen: boolean = false;
  @State customTextInput: string = '';
  @State customTextError: string = '';
  @State customTextSaving: boolean = false;
  @State viewportWidth: number = 390;

  private colors(): ThemeColors { return ThemePalette.resolve(this.dark); }

  private selectedBackground(): string { return this.colors().accentSoft; }

  @Builder
  GroupTitle(symbol: string, title: string) {
    Row({ space: 8 }) {
      Text(symbol).width(28).fontSize(17).textAlign(TextAlign.Center).fontColor(this.colors().accent)
      Text(title).fontSize(17).fontWeight(FontWeight.Medium).fontColor(this.colors().primary)
    }
    .width('100%')
    .height(36)
  }

  @Builder
  Label(title: string, detail: string) {
    Column({ space: 2 }) {
      Text(title).fontSize(14).fontColor(this.colors().primary).maxLines(1)
      if (detail.length > 0) {
        Text(detail).fontSize(10).fontColor(this.colors().secondary).maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .layoutWeight(1)
    .constraintSize({ minWidth: 0 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ChoiceButton(label: string, selected: boolean, action: string) {
    Text(selected ? `✓ ${label}` : label)
      .layoutWeight(1)
      .height(48)
      .fontSize(12)
      .fontWeight(selected ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(selected ? this.colors().accent : this.colors().secondary)
      .textAlign(TextAlign.Center)
      .backgroundColor(selected ? this.selectedBackground() : Color.Transparent)
      .border({ width: selected ? 1 : 0, color: this.colors().accent })
      .borderRadius(8)
      .onClick((): void => {
        if (action === 'wooden_fish') this.onToolChange(ToolType.WOODEN_FISH);
        else if (action === 'beads') this.onToolChange(ToolType.BEADS);
        else if (action === 'incense') this.onToolChange(ToolType.INCENSE);
        else if (action === '1000') this.onIntervalChange(1000);
        else if (action === '1500') this.onIntervalChange(1500);
        else if (action === '2000') this.onIntervalChange(2000);
        else if (action === 'deep') this.onSoundTypeChange(SoundType.DEEP);
        else if (action === 'crisp') this.onSoundTypeChange(SoundType.CRISP);
        else this.onSoundTypeChange(SoundType.SOFT);
      })
      .accessibilityText(`${label}${selected ? '，已选' : ''}`)
  }

  @Builder
  SwitchRow(symbol: string, title: string, detail: string, enabled: boolean, action: string) {
    Row({ space: 10 }) {
      Text(symbol).width(28).fontSize(16).textAlign(TextAlign.Center).fontColor(this.colors().accent)
      this.Label(title, detail)
      Stack({ alignContent: Alignment.Center }) {
        Toggle({ type: ToggleType.Switch, isOn: enabled })
          .width(52)
          .selectedColor(this.colors().accent)
          .responseRegion({ x: -4, y: -8, width: 60, height: 48 })
          .onChange((isOn: boolean): void => {
            if (action === 'sound') this.onSoundToggle(isOn);
            else if (action === 'vibration') this.onVibrationToggle(isOn);
            else if (action === 'floating') this.onFeedbackTextToggle(isOn);
            else this.onReducedMotionToggle(isOn);
          })
      }
      .constraintSize({ minWidth: 60, minHeight: 48 })
      .height(48)
      .accessibilityText(`${title}，${enabled ? '已开启' : '已关闭'}`)
    }
    .width('100%')
    .height(48)
  }

  @Builder
  ThemeSwitchRow() {
    Row({ space: 10 }) {
      Text('月').width(28).fontSize(16).textAlign(TextAlign.Center).fontColor(this.colors().accent)
      this.Label('深色模式', '浅色与黑金主题即时切换')
      Stack({ alignContent: Alignment.Center }) {
        Toggle({ type: ToggleType.Switch, isOn: this.dark })
          .width(52)
          .selectedColor(this.colors().accent)
          .hitTestBehavior(HitTestMode.None)
      }
      .constraintSize({ minWidth: 60, minHeight: 48 })
      .height(48)
      .onClick((): void => this.onThemeChange(ThemeResolver.toggle(this.dark)))
      .accessibilityText(`深色模式，${this.dark ? '已开启' : '已关闭'}`)
    }
    .width('100%')
    .height(48)
  }

  @Builder
  NavigationRow(symbol: string, title: string, detail: string, route: SettingsRoute, action: string) {
    Row({ space: 10 }) {
      Text(symbol).width(28).fontSize(16).textAlign(TextAlign.Center).fontColor(this.colors().accent)
      this.Label(title, detail)
      Text('›').fontSize(24).fontColor(this.colors().secondary)
    }
    .width('100%')
    .height(48)
    .onClick((): void => {
      if (action === 'today') {
        this.clearScope = ClearScope.TODAY;
        this.onModalStateChange(true);
      } else if (action === 'all') {
        this.clearScope = ClearScope.ALL;
        this.onModalStateChange(true);
      } else if (action === 'feedback') {
        this.customTextInput = this.settings.feedbackText;
        this.customTextError = '';
        this.customTextOpen = true;
        this.onModalStateChange(true);
      } else {
        this.onNavigate(route);
      }
    })
    .accessibilityText(`打开${title}`)
  }

  @Builder
  PracticeGroup() {
    Column() {
      this.GroupTitle('坐', '练习设置')
      Row({ space: 8 }) {
        Text('默认工具').width(82).fontSize(12).fontColor(this.colors().secondary)
        Row({ space: 2 }) {
          this.ChoiceButton('木鱼', this.settings.selectedTool === ToolType.WOODEN_FISH, 'wooden_fish')
          this.ChoiceButton('念珠', this.settings.selectedTool === ToolType.BEADS, 'beads')
          this.ChoiceButton('一炷香', this.settings.selectedTool === ToolType.INCENSE, 'incense')
        }.layoutWeight(1)
      }.width('100%').height(48)
      Divider().color(this.colors().divider)
      this.SwitchRow('振', '振动反馈', '敲击时提供轻微触觉反馈', this.settings.vibrationEnabled, 'vibration')
      Divider().color(this.colors().divider)
      this.SwitchRow('字', '浮动文字', '在练习画布显示敲击提示', this.settings.feedbackTextEnabled, 'floating')
      Divider().color(this.colors().divider)
      this.NavigationRow('文', '自定义文字', this.settings.feedbackText, SettingsRoute.NONE, 'feedback')
      Divider().color(this.colors().divider)
      Row({ space: 8 }) {
        Text('自动间隔').width(82).fontSize(12).fontColor(this.colors().secondary)
        Row({ space: 2 }) {
          this.ChoiceButton('1.0 秒', this.settings.autoIntervalMs === 1000, '1000')
          this.ChoiceButton('1.5 秒', this.settings.autoIntervalMs === 1500, '1500')
          this.ChoiceButton('2.0 秒', this.settings.autoIntervalMs === 2000, '2000')
        }.layoutWeight(1)
      }.width('100%').height(48)
    }
    .width('100%').padding({ left: 12, right: 12, bottom: 8 })
    .backgroundColor(this.colors().card).borderRadius(8).border({ width: 1, color: this.colors().divider })
  }

  @Builder
  AudioGroup() {
    Column() {
      this.GroupTitle('♪', '音频设置')
      this.SwitchRow('音', '敲击音', '使用本地音频，不访问网络', this.settings.tapSoundEnabled, 'sound')
      Divider().color(this.colors().divider)
      Row({ space: 8 }) {
        Text('音色').width(82).fontSize(12).fontColor(this.colors().secondary)
        Row({ space: 2 }) {
          this.ChoiceButton('低沉', this.settings.selectedSoundId === SoundType.DEEP, 'deep')
          this.ChoiceButton('清脆', this.settings.selectedSoundId === SoundType.CRISP, 'crisp')
          this.ChoiceButton('柔和', this.settings.selectedSoundId === SoundType.SOFT, 'soft')
        }.layoutWeight(1)
      }.width('100%').height(48)
      Row({ space: 8 }) {
        Text('音量').width(82).fontSize(12).fontColor(this.colors().secondary)
        Slider({ value: this.settings.tapVolume * 100, min: 0, max: 100, step: 5 })
          .layoutWeight(1).constraintSize({ minWidth: 80 })
          .selectedColor(this.colors().accent).blockColor(this.colors().accent)
          .trackColor(this.colors().divider)
          .onChange((value: number): void => this.onVolumeChange(value / 100))
        Text(`${Math.round(this.settings.tapVolume * 100)}%`).width(40).fontSize(11)
          .fontColor(this.colors().secondary)
      }.width('100%').height(48)
    }
    .width('100%').padding({ left: 12, right: 12, bottom: 8 })
    .backgroundColor(this.colors().card).borderRadius(8).border({ width: 1, color: this.colors().divider })
  }

  @Builder
  DisplayGroup() {
    Column() {
      this.GroupTitle('☼', '显示设置')
      this.ThemeSwitchRow()
      Divider().color(this.colors().divider)
      this.SwitchRow('静', '减少动画', '降低位移与缩放动效', this.settings.reducedMotion, 'motion')
    }
    .width('100%').padding({ left: 12, right: 12, bottom: 8 })
    .backgroundColor(this.colors().card).borderRadius(8).border({ width: 1, color: this.colors().divider })
  }

  @Builder
  DataGroup() {
    Column() {
      this.GroupTitle('盾', '数据与合规')
      this.NavigationRow('今', '清除今日数据', '清除今日计数与记录', SettingsRoute.NONE, 'today')
      Divider().color(this.colors().divider)
      this.NavigationRow('删', '清除全部本地数据', '删除后无法恢复', SettingsRoute.NONE, 'all')
      Divider().color(this.colors().divider)
      this.NavigationRow('锁', '隐私说明', '', SettingsRoute.PRIVACY, '')
      Divider().color(this.colors().divider)
      this.NavigationRow('文', '用户须知', '', SettingsRoute.NOTICE, '')
      Divider().color(this.colors().divider)
      this.NavigationRow('i', '版本信息', '许可与发布说明', SettingsRoute.ABOUT, '')
    }
    .width('100%').padding({ left: 12, right: 12, bottom: 8 })
    .backgroundColor(this.colors().card).borderRadius(8).border({ width: 1, color: this.colors().divider })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Scroll() {
        Column({ space: 10 }) {
          Text('设置').width('100%').fontSize(DesignTokens.titleSize(this.viewportWidth))
            .fontWeight(FontWeight.Bold).fontColor(this.colors().primary)
          Stack({ alignContent: Alignment.Center }) {
            Image(this.dark ? $r('app.media.theme_mountain_dark') : $r('app.media.theme_mountain_light'))
              .width('48%').height(64).objectFit(ImageFit.Cover).opacity(this.dark ? 0.48 : 0.26)
            Row({ space: 12 }) {
              Image($r('app.media.practice_wooden_fish')).width(44).height(44).objectFit(ImageFit.Contain)
                .backgroundColor(this.colors().accentSoft).borderRadius(22)
              this.Label('无需登录，数据仅保存在本机', '离线使用 · 无广告 · 仅保留必要权限')
            }.width('100%').padding({ left: 12, right: 12 })
          }
          .width('100%').height(64).backgroundColor(this.colors().card)
          .borderRadius(8).border({ width: 1, color: this.colors().divider })
          this.PracticeGroup()
          this.AudioGroup()
          this.DisplayGroup()
          this.DataGroup()
          Text('仅申请振动权限 · 不申请网络权限').width('100%').fontSize(11)
            .fontColor(this.colors().secondary).textAlign(TextAlign.Center).margin({ bottom: 16 })
        }
        .width('100%')
        .padding({ left: DesignTokens.pageInset(this.viewportWidth), right: DesignTokens.pageInset(this.viewportWidth),
          top: 14 })
      }
      .width('100%').height('100%').scrollBar(BarState.Off).backgroundColor(this.colors().page)

      if (this.clearScope !== ClearScope.NONE) {
        Row().width('100%').height('100%').backgroundColor('#73000000')
          .onClick((): void => {
            this.clearScope = ClearScope.NONE;
            this.onModalStateChange(false);
          })
          .accessibilityText('关闭清除确认')
        Column({ space: 14 }) {
          Text(this.clearScope === ClearScope.TODAY ? '清除今日数据？' : '清除全部本地数据？')
            .fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.colors().primary)
          Text(this.clearScope === ClearScope.TODAY ? '将删除今日统计和今日练习记录。此操作不可恢复。' :
            '将删除设置、统计和全部练习历史，并返回首次引导。此操作不可恢复。')
            .fontSize(14).lineHeight(22).fontColor(this.colors().secondary)
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).height(48).onClick((): void => {
              this.clearScope = ClearScope.NONE;
              this.onModalStateChange(false);
            })
            Button('确认清除').layoutWeight(1).height(48).backgroundColor('#B85C3A').onClick((): void => {
              const scope: ClearScope = this.clearScope;
              this.clearScope = ClearScope.NONE;
              this.onModalStateChange(false);
              if (scope === ClearScope.TODAY) this.onClearToday();
              else this.onClearAll();
            })
          }
        }
        .width('88%').padding(20).backgroundColor(this.colors().card).borderRadius(8)
        .shadow({ radius: 18, color: '#4017130F', offsetY: 6 })
      }

      if (this.customTextOpen) {
        Row().width('100%').height('100%').backgroundColor('#73000000')
          .onClick((): void => {
            if (!this.customTextSaving) {
              this.customTextOpen = false;
              this.onModalStateChange(false);
            }
          })
          .accessibilityText('关闭自定义文字')
        Column({ space: 12 }) {
          Text('自定义敲击文字').fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.colors().primary)
          TextInput({ text: this.customTextInput, placeholder: '例如：好运+1' })
            .width('100%').height(48).fontColor(this.colors().primary)
            .backgroundColor(this.colors().accentSoft).borderRadius(8)
            .onChange((value: string): void => {
              this.customTextInput = value;
              this.customTextError = '';
            })
          if (this.customTextError.length > 0) {
            Text(this.customTextError).width('100%').fontSize(12).fontColor('#B85C3A')
          }
          Text('保存后首页标题和敲击浮字立即更新').width('100%').fontSize(12)
            .fontColor(this.colors().secondary)
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).height(48).enabled(!this.customTextSaving)
              .onClick((): void => {
                this.customTextOpen = false;
                this.onModalStateChange(false);
              })
            Button(this.customTextSaving ? '保存中…' : '保存').layoutWeight(1).height(48)
              .backgroundColor(this.colors().accent).enabled(!this.customTextSaving)
              .onClick(async (): Promise<void> => {
                const normalized: string = FeedbackText.normalize(this.customTextInput);
                if (!FeedbackText.isValid(normalized)) {
                  this.customTextError = normalized.length === 0 ? '请输入自定义文字' : '自定义文字不能超过 20 个字符';
                  return;
                }
                this.customTextSaving = true;
                const saved: boolean = await this.onFeedbackTextSave(normalized);
                this.customTextSaving = false;
                if (!saved) {
                  this.customTextError = '保存失败，请重试';
                  return;
                }
                this.customTextOpen = false;
                this.onModalStateChange(false);
              })
          }
        }
        .width('88%').padding(20).backgroundColor(this.colors().card).borderRadius(8)
        .shadow({ radius: 18, color: '#4017130F', offsetY: 6 })
      }
    }
    .width('100%').height('100%')
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.viewportWidth = Number(newValue.width);
    })
  }
}
