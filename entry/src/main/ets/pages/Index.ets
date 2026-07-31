import { common } from '@kit.AbilityKit';
import { BottomNavBar } from '../components/BottomNavBar';
import { DesignTokens } from '../constants/DesignTokens';
import { JsonCodec } from '../data/JsonCodec';
import { AppSettings, DailyRecord, StatsSummary } from '../models/AppModels';
import { AppTab, PracticeStatus, SceneMode, SoundType, ThemeMode, ToolType } from '../models/Enums';
import { PracticeEvent, PracticeSessionDraft, PracticeState } from '../models/PracticeModels';
import { HomePage } from './HomePage';
import { SettingsPage } from './SettingsPage';
import { StatsPage } from './StatsPage';
import { ModeSelectPage } from './ModeSelectPage';
import { appStore, practiceController, preferencesStore } from '../stores/AppRuntime';
import { audioService } from '../services/AudioService';
import { vibrationService } from '../services/VibrationService';
import { ThemeResolver } from '../utils/ThemeResolver';

@Entry
@Component
struct Index {
  @StorageLink('systemDark') systemDark: boolean = false;
  @State ready: boolean = false;
  @State selectedTab: AppTab = AppTab.HOME;
  @State settings: AppSettings = JsonCodec.createDefaultSettings();
  @State summary: StatsSummary = new StatsSummary();
  @State recentRecords: DailyRecord[] = [];
  @State allRecords: DailyRecord[] = [];
  @State practice: PracticeState = new PracticeState();
  @State viewportWidth: number = 390;

  private contentMaxWidth(): number {
    if (this.viewportWidth >= 1024) {
      return 1180;
    }
    if (this.viewportWidth >= 600) {
      return 920;
    }
    return 560;
  }

  async aboutToAppear(): Promise<void> {
    const hostContext: common.Context | undefined = this.getUIContext().getHostContext();
    if (hostContext === undefined) {
      this.ready = true;
      return;
    }
    try {
      await preferencesStore.initialize(hostContext);
    } catch {
    }
    await audioService.initialize(hostContext);
    await appStore.initialize();
    practiceController.setEventCallback((event: PracticeEvent): void => {
      this.handlePracticeEvent(event);
    });
    practiceController.setSessionCallback((draft: PracticeSessionDraft): void => {
      appStore.savePracticeSession(draft);
    });
    this.syncFromStore();
    this.ready = true;
  }

  aboutToDisappear(): void {
    practiceController.onBackground();
    audioService.release();
  }

  private syncFromStore(): void {
    this.settings = JsonCodec.decodeSettings(JsonCodec.encodeSettings(appStore.settings));
    this.summary = appStore.summary;
    this.recentRecords = appStore.recentRecords;
    this.allRecords = appStore.allRecords;
    practiceController.selectTool(this.settings.selectedTool);
    this.refreshPracticeState();
  }

  private refreshPracticeState(): void {
    const source: PracticeState = practiceController.state;
    const next: PracticeState = new PracticeState();
    next.selectedTool = source.selectedTool;
    next.status = source.status;
    next.manualCount = source.manualCount;
    next.automaticCount = source.automaticCount;
    next.hitSequence = source.hitSequence;
    next.lastMilestone = source.lastMilestone;
    this.practice = next;
  }

  private async handlePracticeEvent(event: PracticeEvent): Promise<void> {
    this.refreshPracticeState();
    if (this.settings.tapSoundEnabled) {
      audioService.play(this.settings.selectedSoundId, this.settings.tapVolume);
    }
    if (this.settings.vibrationEnabled) {
      vibrationService.impact(event.milestone > 0 ? 70 : 35);
    }
    await appStore.recordHit(event.toolType, event.automatic);
    this.syncFromStore();
  }

  private handleManualHit(): void {
    practiceController.recordManual();
    this.refreshPracticeState();
  }

  private handleBeadsGesture(gestureId: number): void {
    practiceController.recordBeadsGesture(gestureId);
    this.refreshPracticeState();
  }

  private handleToolChange(toolType: ToolType): void {
    practiceController.selectTool(toolType);
    appStore.settings.selectedTool = toolType;
    appStore.persistSettings().then((): void => this.syncFromStore());
    this.refreshPracticeState();
  }

  private handleStartAuto(intervalMs: number): void {
    practiceController.startAuto(intervalMs, this.settings.autoDurationSeconds);
    this.refreshPracticeState();
  }

  private handlePause(): void {
    practiceController.pause();
    this.refreshPracticeState();
  }

  private handleResume(): void {
    practiceController.resume();
    this.refreshPracticeState();
  }

  private handleStop(): void {
    practiceController.stop();
    this.refreshPracticeState();
  }

  private updateInterval(intervalMs: number): void {
    appStore.settings.autoIntervalMs = intervalMs;
    appStore.settings.autoInterval = intervalMs;
    appStore.persistSettings().then((): void => this.syncFromStore());
  }

  private updateVolume(volume: number): void {
    appStore.settings.tapVolume = volume;
    appStore.settings.volume = volume;
    appStore.persistSettings().then((): void => this.syncFromStore());
  }

  private isDark(): boolean {
    return ThemeResolver.isDark(this.settings.themeMode, this.systemDark);
  }

  private completeOnboarding(sceneMode: SceneMode, toolType: ToolType): void {
    appStore.completeOnboarding(sceneMode, toolType).then((): void => this.syncFromStore());
  }

  private async updateSetting(action: string, value: boolean): Promise<void> {
    if (action === 'sound') {
      appStore.settings.soundEnabled = value;
      appStore.settings.tapSoundEnabled = value;
    } else if (action === 'vibration') {
      appStore.settings.vibrationEnabled = value;
    } else {
      appStore.settings.floatingTextEnabled = value;
      appStore.settings.feedbackTextEnabled = value;
    }
    await appStore.persistSettings();
    this.syncFromStore();
  }

  @Builder
  CurrentPage() {
    if (!this.settings.initialized) {
      ModeSelectPage({
        dark: this.isDark(),
        onComplete: (sceneMode: SceneMode, toolType: ToolType): void => {
          this.completeOnboarding(sceneMode, toolType);
        }
      })
    } else if (this.selectedTab === AppTab.HOME) {
      HomePage({
        settings: this.settings,
        summary: this.summary,
        practice: this.practice,
        dark: this.isDark(),
        onHit: (): void => this.handleManualHit(),
        onBeadsGesture: (gestureId: number): void => this.handleBeadsGesture(gestureId),
        onToolChange: (toolType: ToolType): void => this.handleToolChange(toolType),
        onStartAuto: (intervalMs: number): void => this.handleStartAuto(intervalMs),
        onPause: (): void => this.handlePause(),
        onResume: (): void => this.handleResume(),
        onStop: (): void => this.handleStop(),
        onIntervalChange: (intervalMs: number): void => this.updateInterval(intervalMs),
        onSoundToggle: (enabled: boolean): void => {
          this.updateSetting('sound', enabled);
        },
        onVolumeChange: (volume: number): void => this.updateVolume(volume),
        onVibrationToggle: (enabled: boolean): void => {
          this.updateSetting('vibration', enabled);
        }
      })
    } else if (this.selectedTab === AppTab.STATS) {
      StatsPage({ summary: this.summary, records: this.allRecords, dark: this.isDark() })
    } else {
      SettingsPage({
        settings: this.settings,
        dark: this.isDark(),
        onSoundToggle: (enabled: boolean): void => {
          this.updateSetting('sound', enabled);
        },
        onSoundTypeChange: (type: SoundType): void => {
          appStore.settings.soundType = type;
          appStore.settings.selectedSoundId = type;
          audioService.play(type, appStore.settings.volume);
          appStore.persistSettings().then((): void => this.syncFromStore());
        },
        onVolumeChange: (value: number): void => {
          appStore.settings.volume = value;
          appStore.settings.tapVolume = value;
          appStore.persistSettings().then((): void => this.syncFromStore());
        },
        onVibrationToggle: (enabled: boolean): void => {
          this.updateSetting('vibration', enabled);
        },
        onFloatingToggle: (enabled: boolean): void => {
          this.updateSetting('floating', enabled);
        },
        onThemeChange: (mode: ThemeMode): void => {
          appStore.setThemeMode(mode).then((): void => this.syncFromStore());
        },
        onCustomText: (value: string): void => {
          appStore.saveCustomText(value).then((): void => this.syncFromStore());
        },
        onClearStats: (): void => {
          appStore.clearStats().then((): void => this.syncFromStore());
        }
      })
    }
  }

  build() {
    if (!this.ready) {
      Column({ space: 14 }) {
        Image($r('app.media.app_icon')).width(120).height(120).borderRadius(28)
        LoadingProgress().color(DesignTokens.wood)
        Text('正在静心准备…').fontSize(14).fontColor(DesignTokens.lightSecondary)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.isDark() ? DesignTokens.darkBackground : DesignTokens.lightBackground)
    } else {
      Stack({ alignContent: Alignment.Top }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor(this.isDark() ? DesignTokens.darkBackground : DesignTokens.lightBackground)
        Column() {
          Column() {
            this.CurrentPage()
          }
          .width('100%')
          .layoutWeight(1)
          BottomNavBar({
            selected: this.selectedTab,
            dark: this.isDark(),
            onChange: (tab: AppTab): void => {
              if (this.selectedTab === AppTab.HOME && tab !== AppTab.HOME &&
                this.practice.status === PracticeStatus.RUNNING) {
                practiceController.pause();
                this.refreshPracticeState();
              }
              this.selectedTab = tab;
              if (tab === AppTab.STATS) {
                appStore.refreshStats().then((): void => this.syncFromStore());
              }
            }
          })
        }
        .width('100%')
        .height('100%')
        .constraintSize({ maxWidth: this.contentMaxWidth() })
        .backgroundColor(this.isDark() ? DesignTokens.darkBackground : DesignTokens.lightBackground)
        .shadow(this.viewportWidth >= 600 ?
          { radius: 20, color: '#1A5E3516', offsetY: 0 } :
          { radius: 0, color: Color.Transparent })
      }
      .width('100%')
      .height('100%')
      .onAreaChange((_oldValue: Area, newValue: Area): void => {
        this.viewportWidth = Number(newValue.width);
      })
    }
  }
}
