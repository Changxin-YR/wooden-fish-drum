import { common } from '@kit.AbilityKit';
import { BottomNavBar } from '../components/BottomNavBar';
import { JsonCodec } from '../data/JsonCodec';
import { AppSettings, DailyRecord, SessionState, StatsSummary } from '../models/AppModels';
import { AppTab, SessionMode, ThemeMode, UserMode } from '../models/Enums';
import { HomePage } from './HomePage';
import { ModeSelectPage } from './ModeSelectPage';
import { SettingsPage } from './SettingsPage';
import { StatsPage } from './StatsPage';
import { appStore, preferencesStore, sessionService } from '../stores/AppRuntime';
import { audioService } from '../services/AudioService';
import { vibrationService } from '../services/VibrationService';

@Entry
@Component
struct Index {
  @State ready: boolean = false;
  @State initialized: boolean = false;
  @State selectedTab: AppTab = AppTab.HOME;
  @State settings: AppSettings = JsonCodec.createDefaultSettings();
  @State summary: StatsSummary = new StatsSummary();
  @State recentRecords: DailyRecord[] = [];
  @State session: SessionState = new SessionState();

  async aboutToAppear(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    try {
      await preferencesStore.initialize(context);
    } catch {
    }
    await audioService.initialize(context);
    await appStore.initialize();
    sessionService.setCallbacks((automatic: boolean): void => {
      this.handleRecordedHit(automatic);
    }, (): void => {
      this.refreshSessionState();
    });
    this.syncFromStore();
    this.ready = true;
  }

  aboutToDisappear(): void {
    sessionService.onBackground();
    audioService.release();
  }

  private syncFromStore(): void {
    this.settings = JsonCodec.decodeSettings(JsonCodec.encodeSettings(appStore.settings));
    this.initialized = this.settings.initialized;
    this.summary = appStore.summary;
    this.recentRecords = appStore.recentRecords;
    this.refreshSessionState();
  }

  private refreshSessionState(): void {
    const source: SessionState = sessionService.state;
    const next: SessionState = new SessionState();
    next.mode = source.mode;
    next.running = source.running;
    next.paused = source.paused;
    next.currentCount = source.currentCount;
    next.targetCount = source.targetCount;
    next.remainingSeconds = source.remainingSeconds;
    next.startedAt = source.startedAt;
    this.session = next;
  }

  private async handleRecordedHit(automatic: boolean): Promise<void> {
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
    sessionService.stop();
    if (mode === SessionMode.FREE) {
      sessionService.startFree();
    } else if (mode === SessionMode.TARGET) {
      sessionService.startTarget(108);
    } else if (mode === SessionMode.TIMER) {
      sessionService.startTimer(300);
    } else {
      sessionService.startAuto(this.settings.autoInterval);
    }
    this.refreshSessionState();
  }

  private async selectInitialMode(mode: UserMode): Promise<void> {
    await appStore.selectInitialMode(mode);
    await appStore.refreshStats();
    this.syncFromStore();
  }

  private async changeMode(mode: UserMode): Promise<void> {
    await appStore.switchMode(mode);
    this.syncFromStore();
  }

  private async updateSetting(action: string, value: boolean): Promise<void> {
    if (action === 'sound') {
      appStore.settings.soundEnabled = value;
    } else if (action === 'vibration') {
      appStore.settings.vibrationEnabled = value;
    } else {
      appStore.settings.floatingTextEnabled = value;
    }
    await appStore.persistSettings();
    this.syncFromStore();
  }

  @Builder
  CurrentPage() {
    if (this.selectedTab === AppTab.HOME) {
      HomePage({
        settings: this.settings,
        summary: this.summary,
        session: this.session,
        onHit: (): void => this.handleManualHit(),
        onSessionChange: (mode: SessionMode): void => this.handleSessionChange(mode)
      })
    } else if (this.selectedTab === AppTab.STATS) {
      StatsPage({ summary: this.summary, records: this.recentRecords })
    } else {
      SettingsPage({
        settings: this.settings,
        onModeChange: (mode: UserMode): void => {
          this.changeMode(mode);
        },
        onSoundToggle: (enabled: boolean): void => {
          this.updateSetting('sound', enabled);
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
        LoadingProgress().color('#8A5635')
        Text('正在静心准备…').fontSize(14).fontColor('#817970')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F6F1E8')
    } else if (!this.initialized) {
      ModeSelectPage({
        onConfirm: (mode: UserMode): void => {
          this.selectInitialMode(mode);
        }
      })
    } else {
      Column() {
        this.CurrentPage()
        BottomNavBar({
          selected: this.selectedTab,
          onChange: (tab: AppTab): void => {
            this.selectedTab = tab;
            if (tab === AppTab.STATS) {
              appStore.refreshStats().then((): void => this.syncFromStore());
            }
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F6F1E8')
    }
  }
}
