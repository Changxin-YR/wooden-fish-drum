import { common } from '@kit.AbilityKit';
import { BottomNavBar } from '../components/BottomNavBar';
import { DesignTokens } from '../constants/DesignTokens';
import { JsonCodec } from '../data/JsonCodec';
import { AppSettings, DailyRecord, SessionState, StatsSummary } from '../models/AppModels';
import { AppTab, SessionMode, SoundType, ThemeMode } from '../models/Enums';
import { HomePage } from './HomePage';
import { SettingsPage } from './SettingsPage';
import { StatsPage } from './StatsPage';
import { appStore, preferencesStore, sessionService } from '../stores/AppRuntime';
import { audioService } from '../services/AudioService';
import { vibrationService } from '../services/VibrationService';
import { windowChromeService } from '../services/WindowChromeService';
import { ThemeResolver } from '../utils/ThemeResolver';

@Entry
@Component
struct Index {
  @StorageLink('systemDark') @Watch('onSystemDarkChange') systemDark: boolean = false;
  @State ready: boolean = false;
  @State storageError: boolean = false;
  @State selectedTab: AppTab = AppTab.HOME;
  @State settings: AppSettings = JsonCodec.createDefaultSettings();
  @State homeTextCount: number = 0;
  @State summary: StatsSummary = new StatsSummary();
  @State recentRecords: DailyRecord[] = [];
  @State allRecords: DailyRecord[] = [];
  @State session: SessionState = new SessionState();
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
      this.storageError = true;
    }
    await appStore.initialize();
    sessionService.setCallbacks((automatic: boolean): void => {
      this.handleRecordedHit(automatic);
    });
    this.syncFromStore();
    this.ready = true;
    audioService.initialize(hostContext);
  }

  aboutToDisappear(): void {
    sessionService.onBackground();
    audioService.release();
  }

  private syncFromStore(): void {
    this.syncSettingsFromStore();
    this.summary = appStore.summary;
    this.recentRecords = appStore.recentRecords;
    this.allRecords = appStore.allRecords;
    this.refreshSessionState();
  }

  private rootBackground(): string {
    if (this.isDark()) {
      return DesignTokens.darkBackground;
    }
    return this.selectedTab === AppTab.HOME ? DesignTokens.homeLightBackground : DesignTokens.lightBackground;
  }

  private syncSettingsFromStore(): void {
    this.settings = appStore.settingsSnapshot();
    this.homeTextCount = appStore.currentTextCount();
    this.syncSystemBars();
  }

  private syncSystemBars(): void {
    windowChromeService.update(this.selectedTab, this.isDark());
  }

  private onSystemDarkChange(): void {
    this.syncSystemBars();
  }

  private persistSettings(operation: Promise<boolean>): void {
    operation.then((saved: boolean): void => {
      if (!saved) {
        this.storageError = true;
      }
    });
  }

  private refreshSessionState(): void {
    this.session = sessionService.state.snapshot();
  }

  private async handleRecordedHit(automatic: boolean): Promise<void> {
    this.refreshSessionState();
    if (this.settings.soundEnabled) {
      audioService.play(this.settings.soundType, this.settings.volume);
    }
    if (this.settings.vibrationEnabled) {
      vibrationService.impact();
    }
    await appStore.recordHit(automatic);
    this.syncFromStore();
  }

  private handleManualHit(): void {
    if (sessionService.recordManualHit()) {
      this.refreshSessionState();
    }
  }

  private handleSessionChange(mode: SessionMode): void {
    sessionService.selectMode(mode, this.settings.targetCount, this.settings.autoInterval);
    this.refreshSessionState();
  }

  private async handleTargetChange(count: number): Promise<void> {
    this.settings.targetCount = count;
    appStore.settings.targetCount = count;
    await appStore.persistSettings();
    if (sessionService.state.targetCompleted || sessionService.state.mode !== SessionMode.TARGET) {
      sessionService.selectMode(SessionMode.TARGET, count, this.settings.autoInterval);
    } else {
      sessionService.state.targetCount = count;
      if (sessionService.state.currentCount >= count) {
        sessionService.state.running = false;
        sessionService.state.targetCompleted = true;
      }
    }
    this.refreshSessionState();
  }

  private handleAutoPause(): void {
    if (sessionService.state.paused) {
      sessionService.resume();
    } else {
      sessionService.pause();
    }
    this.refreshSessionState();
  }

  private isDark(): boolean {
    return ThemeResolver.isDark(this.settings.themeMode, this.systemDark);
  }

  private updateSetting(action: string, value: boolean): void {
    if (action === 'sound') {
      appStore.settings.soundEnabled = value;
    } else if (action === 'vibration') {
      appStore.settings.vibrationEnabled = value;
    } else {
      appStore.settings.floatingTextEnabled = value;
    }
    this.syncSettingsFromStore();
    this.persistSettings(appStore.persistSettings());
  }

  @Builder
  CurrentPage() {
    if (this.selectedTab === AppTab.HOME) {
      HomePage({
        settings: this.settings,
        summary: this.summary,
        session: this.session,
        homeTextCount: this.homeTextCount,
        dark: this.isDark(),
        onHit: (): void => this.handleManualHit(),
        onSessionChange: (mode: SessionMode): void => this.handleSessionChange(mode),
        onTargetChange: (count: number): void => {
          this.handleTargetChange(count);
        },
        onAutoPause: (): void => this.handleAutoPause()
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
          this.syncSettingsFromStore();
          audioService.play(type, appStore.settings.volume);
          this.persistSettings(appStore.persistSettings());
        },
        onVolumeChange: (value: number, mode: SliderChangeMode): void => {
          appStore.settings.volume = value;
          this.syncSettingsFromStore();
          if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
            this.persistSettings(appStore.persistSettings());
          }
        },
        onVibrationToggle: (enabled: boolean): void => {
          this.updateSetting('vibration', enabled);
        },
        onFloatingToggle: (enabled: boolean): void => {
          this.updateSetting('floating', enabled);
        },
        onThemeChange: (mode: ThemeMode): void => {
          const operation: Promise<boolean> = appStore.setThemeMode(mode);
          this.syncSettingsFromStore();
          this.persistSettings(operation);
        },
        onCustomText: (value: string): void => {
          const operation: Promise<boolean> = appStore.saveCustomText(value);
          this.syncSettingsFromStore();
          this.persistSettings(operation);
        },
        onClearStats: (): void => {
          appStore.clearStats().then((saved: boolean): void => {
            if (!saved) {
              this.storageError = true;
            }
            this.syncFromStore();
          });
        }
      })
    }
  }

  build() {
    if (!this.ready) {
      Column()
      .width('100%')
      .height('100%')
      .backgroundColor(this.rootBackground())
    } else {
      Stack({ alignContent: Alignment.Top }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor(this.rootBackground())
        Column() {
          if (this.storageError) {
            Row() {
              Text('本地存储异常，数据可能无法保存')
                .fontSize(13)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding({ top: 8, bottom: 8, left: 16, right: 16 })
            .backgroundColor('#D4793C')
            .justifyContent(FlexAlign.Center)
          }
          Column() {
            this.CurrentPage()
          }
          .width('100%')
          .layoutWeight(1)
          BottomNavBar({
            selected: this.selectedTab,
            dark: this.isDark(),
            onChange: (tab: AppTab): void => {
              this.selectedTab = tab;
              this.syncSystemBars();
              if (tab === AppTab.STATS) {
                appStore.refreshStats().then((): void => this.syncFromStore());
              }
            }
          })
        }
        .width('100%')
        .height('100%')
        .constraintSize({ maxWidth: this.contentMaxWidth() })
        .backgroundColor(this.rootBackground())
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
