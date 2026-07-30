import { common } from '@kit.AbilityKit';
import { BottomNavBar } from '../components/BottomNavBar';
import { JsonCodec } from '../data/JsonCodec';
import { AppSettings, DailyRecord, SessionState, StatsSummary } from '../models/AppModels';
import { AppTab, SessionMode, SoundType, ThemeMode } from '../models/Enums';
import { HomePage } from './HomePage';
import { SettingsPage } from './SettingsPage';
import { StatsPage } from './StatsPage';
import { appStore, preferencesStore, sessionService } from '../stores/AppRuntime';
import { audioService } from '../services/AudioService';
import { vibrationService } from '../services/VibrationService';

@Entry
@Component
struct Index {
  @State ready: boolean = false;
  @State selectedTab: AppTab = AppTab.HOME;
  @State settings: AppSettings = JsonCodec.createDefaultSettings();
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
    }
    await audioService.initialize(hostContext);
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
    this.summary = appStore.summary;
    this.recentRecords = appStore.recentRecords;
    this.allRecords = appStore.allRecords;
    this.refreshSessionState();
  }

  private refreshSessionState(): void {
    const source: SessionState = sessionService.state;
    const next: SessionState = new SessionState();
    next.mode = source.mode;
    next.running = source.running;
    next.paused = source.paused;
    next.targetCompleted = source.targetCompleted;
    next.currentCount = source.currentCount;
    next.targetCount = source.targetCount;
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
    sessionService.selectMode(mode, 108, this.settings.autoInterval);
    this.refreshSessionState();
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
      StatsPage({ summary: this.summary, records: this.allRecords })
    } else {
      SettingsPage({
        settings: this.settings,
        onSoundToggle: (enabled: boolean): void => {
          this.updateSetting('sound', enabled);
        },
        onSoundTypeChange: (type: SoundType): void => {
          appStore.settings.soundType = type;
          appStore.persistSettings().then((): void => this.syncFromStore());
        },
        onVolumeChange: (value: number): void => {
          appStore.settings.volume = value;
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
        LoadingProgress().color('#8A5635')
        Text('正在静心准备…').fontSize(14).fontColor('#817970')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F6F1E8')
    } else {
      Stack({ alignContent: Alignment.Top }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('#EDE7DE')
        Column() {
          Column() {
            this.CurrentPage()
          }
          .width('100%')
          .layoutWeight(1)
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
        .constraintSize({ maxWidth: this.contentMaxWidth() })
        .backgroundColor('#F6F1E8')
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
