import { DesignTokens } from '../constants/DesignTokens';
import { GENERAL_AVAILABLE_TEXTS } from '../constants/UserModeConfigs';
import { AppSettings } from '../models/AppModels';
import { SettingsRoute, SoundType, ThemeMode, ToolType } from '../models/Enums';

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
  onFeedbackToggle: (enabled: boolean) => void = (): void => {};
  onReducedMotionToggle: (enabled: boolean) => void = (): void => {};
  onThemeChange: (mode: ThemeMode) => void = (): void => {};
  onCustomText: (value: string) => void = (): void => {};
  onClearToday: () => void = (): void => {};
  onClearAll: () => void = (): void => {};
  onNavigate: (route: SettingsRoute) => void = (): void => {};
  @State showTextEditor: boolean = false;
  @State customText: string = '';
  @State clearScope: ClearScope = ClearScope.NONE;

  private pageBackground(): string { return this.dark ? DesignTokens.darkBackground : DesignTokens.lightBackground; }
  private card(): string { return this.dark ? DesignTokens.darkCard : DesignTokens.lightCard; }
  private primary(): string { return this.dark ? DesignTokens.darkText : DesignTokens.lightText; }
  private secondary(): string { return this.dark ? DesignTokens.darkSecondary : DesignTokens.lightSecondary; }
  private divider(): string { return this.dark ? DesignTokens.darkDivider : DesignTokens.lightDivider; }
  private selectedBackground(): string { return this.dark ? '#493B30' : '#F5E8D8'; }

  @Builder
  GroupTitle(symbol: string, title: string) {
    Row({ space: 9 }) {
      Text(symbol).fontSize(18).fontColor(this.dark ? DesignTokens.accentLight : DesignTokens.wood)
      Text(title).fontSize(17).fontWeight(FontWeight.Medium).fontColor(this.primary())
    }
    .width('100%').constraintSize({ minHeight: 42 })
  }

  @Builder
  Label(title: string, detail: string) {
    Column({ space: 3 }) {
      Text(title).fontSize(15).fontColor(this.primary()).maxLines(1)
      if (detail.length > 0) {
        Text(detail).fontSize(11).fontColor(this.secondary()).maxLines(2)
      }
    }
    .layoutWeight(1).constraintSize({ minWidth: 0 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  SwitchRow(symbol: string, title: string, detail: string, enabled: boolean, action: string) {
    Row({ space: 12 }) {
      Text(symbol).width(36).fontSize(18).textAlign(TextAlign.Center)
        .fontColor(this.dark ? DesignTokens.accentLight : DesignTokens.wood)
      this.Label(title, detail)
      Stack({ alignContent: Alignment.Center }) {
        Toggle({ type: ToggleType.Switch, isOn: enabled }).width(48)
          .selectedColor(DesignTokens.accent).hitTestBehavior(HitTestMode.None)
      }
      .width(48).height(48)
      .onClick((): void => {
        if (action === 'sound') this.onSoundToggle(!enabled);
        else if (action === 'vibration') this.onVibrationToggle(!enabled);
        else if (action === 'feedback') this.onFeedbackToggle(!enabled);
        else this.onReducedMotionToggle(!enabled);
      })
      .accessibilityText(`${title}，${enabled ? '已开启' : '已关闭'}`)
    }
    .width('100%').constraintSize({ minHeight: 58 })
  }

  @Builder
  ChoiceButton(label: string, selected: boolean, action: string) {
    Text(selected ? `✓ ${label}` : label)
      .layoutWeight(1).height(48).fontSize(13).fontWeight(selected ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(selected ? (this.dark ? DesignTokens.accentLight : DesignTokens.wood) : this.secondary())
      .textAlign(TextAlign.Center).backgroundColor(selected ? this.selectedBackground() : Color.Transparent)
      .border({ width: selected ? 1 : 0, color: DesignTokens.accent }).borderRadius(DesignTokens.radiusControl)
      .onClick((): void => {
        if (action === 'wooden_fish') this.onToolChange(ToolType.WOODEN_FISH);
        else if (action === 'beads') this.onToolChange(ToolType.BEADS);
        else if (action === 'incense') this.onToolChange(ToolType.INCENSE);
        else if (action === '1000') this.onIntervalChange(1000);
        else if (action === '1500') this.onIntervalChange(1500);
        else if (action === '2000') this.onIntervalChange(2000);
        else if (action === 'deep') this.onSoundTypeChange(SoundType.DEEP);
        else if (action === 'crisp') this.onSoundTypeChange(SoundType.CRISP);
        else if (action === 'soft') this.onSoundTypeChange(SoundType.SOFT);
        else if (action === 'system') this.onThemeChange(ThemeMode.SYSTEM);
        else if (action === 'light') this.onThemeChange(ThemeMode.LIGHT);
        else this.onThemeChange(ThemeMode.DARK);
      })
      .accessibilityText(`${label}${selected ? '，已选' : ''}`)
  }

  @Builder
  NavigationRow(symbol: string, title: string, detail: string, route: SettingsRoute) {
    Row({ space: 12 }) {
      Text(symbol).width(36).fontSize(18).textAlign(TextAlign.Center)
        .fontColor(this.dark ? DesignTokens.accentLight : DesignTokens.wood)
      this.Label(title, detail)
      Text('›').fontSize(26).fontColor(this.secondary())
    }
    .width('100%').constraintSize({ minHeight: 56 }).onClick((): void => this.onNavigate(route))
    .accessibilityText(`打开${title}`)
  }

  @Builder
  PracticeGroup() {
    Column() {
      this.GroupTitle('坐', '练习设置')
      Text('默认工具').width('100%').fontSize(12).fontColor(this.secondary()).margin({ bottom: 5 })
      Row({ space: 3 }) {
        this.ChoiceButton('木鱼', this.settings.selectedTool === ToolType.WOODEN_FISH, 'wooden_fish')
        this.ChoiceButton('念珠', this.settings.selectedTool === ToolType.BEADS, 'beads')
        this.ChoiceButton('一炷香', this.settings.selectedTool === ToolType.INCENSE, 'incense')
      }.width('100%')
      Divider().color(this.divider()).margin({ top: 8, bottom: 8 })
      Text('自动间隔').width('100%').fontSize(12).fontColor(this.secondary()).margin({ bottom: 5 })
      Row({ space: 3 }) {
        this.ChoiceButton('1.0 秒', this.settings.autoIntervalMs === 1000, '1000')
        this.ChoiceButton('1.5 秒', this.settings.autoIntervalMs === 1500, '1500')
        this.ChoiceButton('2.0 秒', this.settings.autoIntervalMs === 2000, '2000')
      }.width('100%')
    }
    .width('100%').padding(16).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
  }

  @Builder
  AudioGroup() {
    Column() {
      this.GroupTitle('♪', '音频设置')
      this.SwitchRow('音', '敲击音', '使用本地短音频，不访问网络', this.settings.tapSoundEnabled, 'sound')
      Divider().color(this.divider())
      Text('音色').width('100%').fontSize(12).fontColor(this.secondary()).margin({ top: 10, bottom: 5 })
      Row({ space: 3 }) {
        this.ChoiceButton('低沉', this.settings.selectedSoundId === SoundType.DEEP, 'deep')
        this.ChoiceButton('清脆', this.settings.selectedSoundId === SoundType.CRISP, 'crisp')
        this.ChoiceButton('柔和', this.settings.selectedSoundId === SoundType.SOFT, 'soft')
      }.width('100%')
      Row({ space: 10 }) {
        Text('敲击音量').fontSize(14).fontColor(this.primary())
        Slider({ value: this.settings.tapVolume * 100, min: 0, max: 100, step: 5 }).layoutWeight(1)
          .constraintSize({ minWidth: 80 }).selectedColor(DesignTokens.accent)
          .onChange((value: number): void => this.onVolumeChange(value / 100))
        Text(`${Math.round(this.settings.tapVolume * 100)}%`).width(42).fontSize(12).fontColor(this.secondary())
      }.width('100%').constraintSize({ minHeight: 56 })
    }
    .width('100%').padding(16).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
  }

  @Builder
  DisplayGroup() {
    Column() {
      this.GroupTitle('目', '显示设置')
      Row({ space: 3 }) {
        this.ChoiceButton('跟随系统', this.settings.themeMode === ThemeMode.SYSTEM, 'system')
        this.ChoiceButton('浅色', this.settings.themeMode === ThemeMode.LIGHT, 'light')
        this.ChoiceButton('深色', this.settings.themeMode === ThemeMode.DARK, 'dark')
      }.width('100%')
      Divider().color(this.divider()).margin({ top: 8 })
      Row({ space: 12 }) {
        Text('Aa').width(36).fontSize(17).textAlign(TextAlign.Center)
          .fontColor(this.dark ? DesignTokens.accentLight : DesignTokens.wood)
        this.Label('系统字体缩放', '跟随 HarmonyOS 字体大小设置')
        Text('已启用').fontSize(12).fontColor(this.secondary())
      }.width('100%').constraintSize({ minHeight: 56 })
      Divider().color(this.divider())
      this.SwitchRow('静', '减少动画', '保留计数与状态反馈，减少位移动效', this.settings.reducedMotion, 'motion')
    }
    .width('100%').padding(16).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
  }

  @Builder
  FeedbackGroup() {
    Column() {
      this.GroupTitle('触', '文字与触感')
      this.SwitchRow('T', '反馈文字', '敲击后显示当前反馈文字', this.settings.feedbackTextEnabled, 'feedback')
      Divider().color(this.divider())
      Row({ space: 12 }) {
        Text('文').width(36).fontSize(18).textAlign(TextAlign.Center)
          .fontColor(this.dark ? DesignTokens.accentLight : DesignTokens.wood)
        this.Label('反馈内容', this.settings.feedbackText)
        Text('›').fontSize(26).fontColor(this.secondary())
      }
      .width('100%').constraintSize({ minHeight: 56 }).onClick((): void => {
        this.customText = this.settings.feedbackText;
        this.showTextEditor = true;
      }).accessibilityText('编辑反馈文字')
      Divider().color(this.divider())
      this.SwitchRow('振', '振动反馈', '仅在开启时调用系统振动能力', this.settings.vibrationEnabled, 'vibration')
    }
    .width('100%').padding(16).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
  }

  @Builder
  DataGroup() {
    Column() {
      this.GroupTitle('数', '数据管理')
      Row({ space: 12 }) {
        Text('今').width(36).fontSize(18).textAlign(TextAlign.Center).fontColor('#B2773F')
        this.Label('清除今日数据', '删除今日统计与今日练习记录')
        Text('›').fontSize(26).fontColor(this.secondary())
      }.width('100%').constraintSize({ minHeight: 56 }).onClick((): void => { this.clearScope = ClearScope.TODAY; })
      Divider().color(this.divider())
      Row({ space: 12 }) {
        Text('删').width(36).fontSize(18).textAlign(TextAlign.Center).fontColor('#B85C3A')
        this.Label('清除全部本地数据', '删除设置、统计和练习历史并返回首次引导')
        Text('›').fontSize(26).fontColor(this.secondary())
      }.width('100%').constraintSize({ minHeight: 56 }).onClick((): void => { this.clearScope = ClearScope.ALL; })
    }
    .width('100%').padding(16).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
  }

  @Builder
  ComplianceGroup() {
    Column() {
      this.GroupTitle('盾', '关于与合规')
      this.NavigationRow('隐', '隐私说明', '无账号、无上传、无广告或统计 SDK', SettingsRoute.PRIVACY)
      Divider().color(this.divider())
      this.NavigationRow('须', '用户须知', '不作宗教、医疗或心理健康功效承诺', SettingsRoute.NOTICE)
      Divider().color(this.divider())
      this.NavigationRow('开', '开源与许可', '查看运行包和测试依赖说明', SettingsRoute.LICENSES)
      Divider().color(this.divider())
      this.NavigationRow('i', '版本信息', '应用信息与发布资料说明', SettingsRoute.ABOUT)
    }
    .width('100%').padding(16).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Scroll() {
        Column({ space: 14 }) {
          Text('设置').width('100%').fontSize(30).fontWeight(FontWeight.Bold).fontColor(this.primary())
          Row({ space: 12 }) {
            Text('叶').width(42).height(42).fontSize(16).fontWeight(FontWeight.Bold).textAlign(TextAlign.Center)
              .fontColor(this.dark ? DesignTokens.accentLight : DesignTokens.wood)
              .backgroundColor(this.dark ? '#3B3530' : '#F7EFE4').borderRadius(21)
            this.Label('无需登录，数据仅保存在本机', '离线使用 · 无广告 · 仅保留必要权限')
          }
          .width('100%').padding(14).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
          this.PracticeGroup()
          this.AudioGroup()
          this.DisplayGroup()
          this.FeedbackGroup()
          this.DataGroup()
          this.ComplianceGroup()
          Text('仅申请振动权限 · 不申请网络权限').width('100%').fontSize(12)
            .fontColor(this.secondary()).textAlign(TextAlign.Center).margin({ bottom: 20 })
        }
        .width('100%').padding({ left: 20, right: 20, top: 20 })
      }
      .width('100%').height('100%').scrollBar(BarState.Off).backgroundColor(this.pageBackground())

      if (this.showTextEditor) {
        Column({ space: 14 }) {
          Text('反馈文字').fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.primary())
          Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
            ForEach(GENERAL_AVAILABLE_TEXTS, (value: string) => {
              Text(value).fontSize(14).fontColor(this.customText === value ? '#FFFFFF' : this.primary())
                .padding({ left: 14, right: 14, top: 9, bottom: 9 })
                .backgroundColor(this.customText === value ? DesignTokens.accent : this.selectedBackground())
                .borderRadius(18).margin({ right: 8, bottom: 8 }).onClick((): void => { this.customText = value; })
            })
          }.width('100%')
          TextInput({ text: this.customText, placeholder: '请输入 1-12 个字符' }).height(50)
            .onChange((value: string): void => { this.customText = value; })
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).height(48).onClick((): void => { this.showTextEditor = false; })
            Button('保存').layoutWeight(1).height(48).backgroundColor(DesignTokens.accent).onClick((): void => {
              this.showTextEditor = false;
              this.onCustomText(this.customText);
            })
          }
        }
        .width('88%').padding(20).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
        .shadow({ radius: 18, color: '#4017130F', offsetY: 6 })
      }

      if (this.clearScope !== ClearScope.NONE) {
        Column({ space: 14 }) {
          Text(this.clearScope === ClearScope.TODAY ? '清除今日数据？' : '清除全部本地数据？')
            .fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.primary())
          Text(this.clearScope === ClearScope.TODAY ? '将删除今日统计和今日练习记录。此操作不可恢复。' :
            '将删除设置、统计和全部练习历史，并返回首次引导。此操作不可恢复。')
            .fontSize(14).lineHeight(22).fontColor(this.secondary())
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).height(48).onClick((): void => { this.clearScope = ClearScope.NONE; })
            Button('确认清除').layoutWeight(1).height(48).backgroundColor('#B85C3A').onClick((): void => {
              const scope: ClearScope = this.clearScope;
              this.clearScope = ClearScope.NONE;
              if (scope === ClearScope.TODAY) this.onClearToday();
              else this.onClearAll();
            })
          }
        }
        .width('88%').padding(20).backgroundColor(this.card()).borderRadius(DesignTokens.radiusCard)
        .shadow({ radius: 18, color: '#4017130F', offsetY: 6 })
      }
    }
    .width('100%').height('100%')
  }
}
