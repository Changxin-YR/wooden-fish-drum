import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import audio from '@ohos.multimedia.audio';
import { SoundType } from '../models/Enums';

export class AudioService {
  private context: common.Context | null = null;
  private pool: media.SoundPool | null = null;
  private soundIds: Map<SoundType, number> = new Map<SoundType, number>();

  async initialize(context: common.Context): Promise<void> {
    this.context = context;
    try {
      const rendererInfo: audio.AudioRendererInfo = {
        usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
        rendererFlags: 0
      };
      this.pool = await media.createSoundPool(8, rendererInfo);
      await this.load(SoundType.DEEP, 'sounds/deep.wav');
      await this.load(SoundType.CRISP, 'sounds/crisp.wav');
      await this.load(SoundType.SOFT, 'sounds/soft.wav');
    } catch {
      this.pool = null;
      this.soundIds.clear();
    }
  }

  async play(type: SoundType, volume: number): Promise<boolean> {
    const soundId: number | undefined = this.soundIds.get(type);
    if (this.pool === null || soundId === undefined) {
      return false;
    }
    try {
      await this.pool.play(soundId, {
        loop: 0,
        rate: audio.AudioRendererRate.RENDER_RATE_NORMAL,
        leftVolume: Math.max(0, Math.min(1, volume)),
        rightVolume: Math.max(0, Math.min(1, volume)),
        priority: 1
      });
      return true;
    } catch {
      return false;
    }
  }

  async release(): Promise<void> {
    if (this.pool !== null) {
      try {
        await this.pool.release();
      } catch {
      }
    }
    this.pool = null;
    this.soundIds.clear();
  }

  private async load(type: SoundType, path: string): Promise<void> {
    if (this.context === null || this.pool === null) {
      return;
    }
    const descriptor = await this.context.resourceManager.getRawFd(path);
    try {
      const soundId: number = await this.pool.load(descriptor.fd, descriptor.offset, descriptor.length);
      this.soundIds.set(type, soundId);
    } finally {
      await this.context.resourceManager.closeRawFd(path);
    }
  }
}

export const audioService: AudioService = new AudioService();
